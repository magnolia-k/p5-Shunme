package Shunme::Harness;

use strict;
use warnings;
use v5.10.1;
use utf8;

use Carp;

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = {
        condition   => $params{condition},
    };

    bless $self, $class;

    return $self;
}

sub run_tests {
    my $self = shift;
    
    my $iterator = $self->{condition}->make_test_scripts_iterator;

    require Shunme::Formatter;
    my $formatter = Shunme::Formatter->create_formatter(
            module  => $self->{condition}->formatter,
            verbose => $self->{condition}->verbose,
            );

    require Shunme::EventLoop;
    my $eventloop = Shunme::EventLoop->create_eventloop(
            module      => $self->{condition}->eventloop,
            formatter   => $formatter,
            iterator    => $iterator,
            library     => $self->{condition}->library,
            );

    my $aggregated = $eventloop->execute_eventloop;

    return $aggregated->exit_code;
}

1;
