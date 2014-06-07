package Shunme::TAP::Source;

use strict;
use warnings;
use v5.10.1;
use utf8;

use IPC::Cmd qw[run_forked];
use Carp;
use autodie;
use Encode;

if ( ! IPC::Cmd->can_use_run_forked ) {
    croak "This platform don't support 'run_forked' method.";
}

require Shunme::TAP;

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = {
        test_script => $params{test_script},
        script_type => undef,

        library     => $params{library},

        timeout     => $params{timeout} // 60 x 10, # Default timeout 10 minutes
    };

    bless $self, $class;

    $self->_initialize;

    return $self;
}

sub _initialize {
    my $self = shift;

    if ( -T $self->{test_script} ) {
        open my $fh, '<', $self->{test_script};
        my $shebang = <$fh>;
        close $fh;

        if ( $shebang =~ /^#!(.*)/ ) {
            if ( $1 =~ /perl/ ) {
                $self->{type} = 'perl';
            }
        } else {
            $self->{type} = 'perl';
        }
    }

    if ( ! $self->{type} ) {
        if ( -x $self->{test_script} ) {
            $self->{type} = 'executable';
        } else {
            croak "Can't determine script's type.";
        }
    }
}

sub execute_test_script {
    my $self = shift;

    my $cmd;
    if ( $self->{type} eq 'perl' ) {

        $cmd = $^X . ' ';

        if ( $self->{library} ) {
            $cmd .= '-I' . join( ',', @{ $self->{library} } ) . ' ';
        }

        $cmd .= $self->{test_script};

    } else {
        $cmd = $self->{test_script};
    }

    my $result = run_forked( $cmd, { timeout => $self->{timeout} } );

    my $tap = Shunme::TAP->new(
        test_script => $self->{test_script},
        exit_code   => $result->{exit_code},
        stdout_ref  => \decode( 'UTF-8', $result->{stdout} ),
        stderr_ref  => \decode( 'UTF-8', $result->{stderr} ),
        );

    return $tap;
}

1;
