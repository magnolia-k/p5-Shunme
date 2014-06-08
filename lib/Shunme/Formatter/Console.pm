package Shunme::Formatter::Console;

use strict;
use warnings;
use v5.10.1;
use utf8;

use Carp;

use parent qw[Shunme::Formatter];

sub format_tap_output {
    my $self   = shift;
    my %params = @_;

    if ( $self->{verbose} ) {
        print $params{tap}->stdout;
        print $params{tap}->stderr;
    } else {
        my $summary = $params{tap}->summary;

        if ( $summary->{failed_tests} == 0 ) {
            my $plan = $summary->{planned_tests} ? $summary->{planned_tests} :
                '?';
            say $params{tap}->test_script . "\t" . $summary->{ran_tests} . '/' . $plan;
        } else {
            say $params{tap}->test_script;
            print $params{tap}->stderr;
        }
    }

}

sub finish {
    my $self   = shift;
    my %params = @_;

    say 'finish!';
}

1;
