package Shunme::Aggregator;

use strict;
use warnings;
use v5.10.1;
use Carp;

use Benchmark;

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = {
        tap_summaries   => [],

        total => {
            test_scripts    => 0,
            ran_tests       => 0,
            failed_tests    => 0,
        },

        start_time      => undef,
        end_time        => undef,
    };

    bless $self, $class;

    return $self;
}

sub start_aggregation   { $_[0]->{start_time} = Benchmark->new };
sub stop_aggregation    { $_[0]->{end_time}   = Benchmark->new };

sub add {
    my $self   = shift;
    my %params = @_;

    if( ! defined $params{tap_summary} ) {
        croak "Parameter 'tap_summary' is not defined.";
    }

    push @{ $self->{tap_summaries} }, $params{tap_summary};

    $self->{total}{test_scripts}++;
    $self->{total}{ran_tests}    += $params{tap_summary}->{ran_tests};
    $self->{total}{failed_tests} += $params{tap_summary}->{failed_tests};
}

sub exit_code {
    my $self = shift;

    my $failed = 0;
    for my $tap_summary ( @{ $self->{tap_summaries} } ) {
        $failed++ if ( $tap_summary->{exit_code} != 0 );
    }

    return ( defined $failed ) ? 0 : 1;
}

sub summary {
    my $self = shift;
    
    unless ( $self->{start_time} && $self->{end_time} ) {
        croak "Benchmark is not aggregated.";
    }

    my $elapsed_time = timediff( $self->{end_time}, $self->{start_time} );

    my $result_str;
    if ( ! $self->{total}{ran_tests} ) {
        $result_str = 'No Tests';
    } elsif ( $self->{total}{failed_tests} ) {
        $result_str = 'Fail';
    } else {
        $result_str = 'Pass';
    }

    my $summary = {
        test_scripts        => $self->{total}{test_scripts},
        ran_tests           => $self->{total}{ran_tests},
        failed_tests        => $self->{total}{failed_tests},
        elapsed_time_str    => timestr( $elapsed_time ),
        result_str          => $result_str,
    };

    return $summary;
}

1;
