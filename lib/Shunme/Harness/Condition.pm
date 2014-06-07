package Shunme::Harness::Condition;

use strict;
use warnings;
use v5.10.1;
use utf8;

use Carp;

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = {
        test_scripts    => $params{test_scripts},
        verbose         => $params{verbose},
        library         => [],

        formatter       => $params{formatter} // 'Console',
        eventloop       => $params{eventloop} // 'Parallel::Select',
    };

    bless $self, $class;

    $self->_initialize( $params{library} );

    return $self;
}

sub _initialize {
    my ( $self, $library ) = @_;

    # validate for blib
    if ( $library->{blib} ) {
        if ( ! -d 'blib' ) {
            croak "Can't find 'blib' directory.";
        }

        push @{ $self->{library} }, 'blib';
    }  

    # validate for lib
    if ( $library->{lib} ) {
        if ( ! -d 'lib' ) {
            croak "Can't find 'lib' directory.";
        }

        push @{ $self->{library} }, 'lib';
    }
}

sub formatter   { return $_[0]->{formatter} }
sub eventloop   { return $_[0]->{eventloop} }

sub verbose     { return $_[0]->{verbose}   }
sub library     { return $_[0]->{library}   }

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
