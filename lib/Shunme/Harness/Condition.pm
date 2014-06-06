package Shunme::Harness::Condition;

use strict;
use warnings;
use v5.10.1;
use utf8;

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = {
        test_scripts    => $params{test_scripts},

        formatter       => $params{formatter} // 'Console',
        eventloop       => $params{eventloop} // 'Parallel::Select',
    };

    bless $self, $class;

    return $self;
}

sub formatter { return $_[0]->{formatter} }
sub eventloop { return $_[0]->{eventloop} }

sub make_test_scripts_iterator {
    my $self = shift;

    require Shunme::Harness::Condition::Iterator;

    return Shunme::Harness::Condition::Iterator->new( condition => $self );
}

sub get_test_script_at {
    my $self   = shift;
    my %params = @_;

    if ( defined $self->{test_scripts}[$params{index_test_script}] ) {
        return $self->{test_scripts}[$params{index_test_script}];
    } else {
        return;
    }
}

1;
