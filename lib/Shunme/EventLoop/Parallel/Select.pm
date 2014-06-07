package Shunme::EventLoop::Parallel::Select;

use strict;
use warnings;
use v5.10.1;
use utf8;

use parent qw[Shunme::EventLoop];

use Socket;
use IO::Handle;
use IO::Select;
use POSIX 'WNOHANG';

use Carp;

$SIG{CHLD} = \&finish;
$SIG{PIPE} = 'IGNORE';

my $selector = IO::Select->new;
our $obj;
sub initialize {
    my $self = shift;

    $obj = $self;

    $self->{max_worker} = 10;
}


sub execute_eventloop {
    my $self = shift;

    $self->{aggregator}->start_aggregation;

    while ( 1 ) {

        # Max Worker Check
        while ( ( keys %{ $self->{children} } ) >= $self->{max_worker} ) {
            select( undef, undef, undef, 0.25 );
        }

        if ( my $test_script = $self->{iterator}->next ) {

            my ( $ch, $pa );
            socketpair( $ch, $pa, AF_UNIX, SOCK_STREAM, PF_UNSPEC )
                or croak "socketpair: $!";

            my $pid = fork;
            croak "Can't fork" unless defined $pid;

            if ( $pid ) {

                close $pa;

                $selector->add( $ch );
                $self->{children}{$pid} = { fd => $ch, json_msg => '' };

            } else {

                close $ch;

                delete $self->{children};

                $SIG{CHLD} = 'DEFAULT';
                $self->execute_test_script( $test_script, $pa );
                close $pa;
                exit;

            }
        }

        if ( my @ready = $selector->can_read( 0 ) ) {

            for my $fh ( @ready ) {

                my $ch_id;
                for my $child ( keys %{ $self->{children} } ) {
                    if ( $self->{children}{$child}{fd} && $self->{children}{$child}{fd} == $fh ) {
                        $ch_id = $child;
                        last;
                    }
                }

                my $buf;
                while ( $fh->sysread( $buf, 40960 ) ) {
                    $self->{children}{$ch_id}->{json_msg} .= $buf;
                }

            }

        }

        last unless ( $self->{iterator}->next_exist or keys %{ $self->{children} } );
    }

    $self->{aggregator}->stop_aggregation;

    my $summary =  $self->{aggregator}->summary;

    say 'Result:' . $summary->{result_str};
    say "Files=$summary->{test_scripts}, Tests=$summary->{ran_tests}, $summary->{elapsed_time_str}"; 

    return $self->{aggregator};
}

require Shunme::TAP;
sub execute_test_script {
    my $self = shift;
    my $test_script = shift;
    my $pa = shift;

    my $tap = Shunme::TAP->create_from(
            test_script => $test_script,
            library     => $self->{library},
            );
    my $json = $tap->to_msg_json;

    $pa->syswrite( $json );
}

sub finish {
    my $self = $obj;

    while( ( my $child = waitpid( -1, WNOHANG ) ) > 0 ) {
        my $buf;
        while ( $self->{children}{$child}->{fd}->sysread( $buf, 40960 ) ) {
            $self->{children}{$child}->{json_msg} .= $buf;
        }

        $selector->remove( $self->{children}{$child}->{fd} );
        close $self->{children}{$child}->{fd};

        if ( $self->{children}{$child}->{json_msg} ) {
            my $json = $self->{children}{$child}->{json_msg};
            require Shunme::TAP;
            my $tap = Shunme::TAP->from_msg_json( $json );

            $self->{formatter}->format_tap_output( tap => $tap );
            $self->{aggregator}->add( tap_summary => $tap->summary );
        }

        delete $self->{children}{$child};
    }

}

1;
