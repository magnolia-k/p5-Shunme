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
            my $skipped = '';
            if ( ! defined $summary->{planned_tests} ) {
                $plan = '?';
            } elsif ( $summary->{is_skipped_all} ) {
                $plan = '0';
                $skipped .= ' ' . $summary->{skip_all_msg};
            } else {
                $plan = $summary->{planned_tests};
            }

            if ( $summary->{is_skipped_all} ) {
                say $self->format_line( $params{tap}->test_script ) . $skipped;
            } else {
                say $self->format_line( $params{tap}->test_script ) . " " .
                    $summary->{ran_tests} . '/' . $plan;
            }

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

    if ( $length >= 30 ) {
        return $str;
    }

    my $tmp = $str . ' ' . '.' x ( 29 - $length );

    return $tmp;
}

sub finish {
    my $self   = shift;
    my %params = @_;

    say 'finish!';
}

1;
