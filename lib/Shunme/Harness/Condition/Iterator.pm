package Shunme::Harness::Condition::Iterator;

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

        index_test_script   => 0,
    };

    bless $self, $class;

    return $self;
}

sub next_exist {
    my $self = shift;

    my $condition = $self->{condition};

    my $test_script = $condition->get_test_script_at(
            index_test_script   => $self->{index_test_script}
            );

    return $test_script;
}

sub next {
    my $self = shift;

    my $condition = $self->{condition};

    my $test_script = $condition->get_test_script_at(
            index_test_script   => $self->{index_test_script}
            );

    if ( $test_script ) {
        $self->{index_test_script}++;
    }

    return $test_script;
}

1;
