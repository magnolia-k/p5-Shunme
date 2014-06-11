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

            my $plan;
            if ( ! defined $summary->{planned_tests} ) {
                $plan = '?';
            } elsif ( $summary->{planned_tests} == 0 ) {
                $plan = '0';
            } else {
                $plan = $summary->{planned_tests};
            }

            say $self->format_line( $params{tap}->test_script ) . " " .
                $summary->{ran_tests} . '/' . $plan;
        } else {
            say $params{tap}->test_script;
            print $params{tap}->stderr;
        }
    }

}

sub format_line {
    my $self = shift;
    my $str  = shift;

    my $length;
    {
        no utf8;
        $length = length( $str );
    }

    if ( $length >= 50 ) {
        return $str;
    }

    my $tmp = $str . ' ' . '.' x ( 49 - $length );

    return $tmp;
}

sub finish {
    my $self   = shift;
    my %params = @_;

    say 'finish!';
}

1;
