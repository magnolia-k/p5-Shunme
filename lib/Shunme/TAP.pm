package Shunme::TAP;

use strict;
use warnings;
use v5.10.1;
use utf8;

use Carp;
use Storable qw[freeze thaw];

require Shunme::TAP::Source;
require TAP::Tree;

sub create_from {
    my $pkg    = shift;
    my %params = @_;

    if ( ! $params{test_script} ) {
        croak "Parameter 'test_script' is not defined.";
    }

    my $tap = Shunme::TAP::Source->new( test_script => $params{test_script} );

    return $tap->execute_test_script;
}

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = {
        test_script => $params{test_script},
        tap_tree    => $params{tap_tree},
        exit_code   => $params{exit_code},
        stdout_ref  => $params{stdout_ref},
        stderr_ref  => $params{stderr_ref},
        merged_ref  => $params{merged_ref},
    };

    bless $self, $class;

    $self->_initialize;

    return $self;
}

sub _initialize {
    my $self = shift;

    if ( ! $self->{tap_tree} ) {
        $self->{tap_tree} = TAP::Tree->new(
                tap_ref => $self->{stdout_ref},
                utf8    => 1,
                );

        $self->{tap_tree}->parse;

        return $self;
    }
}

sub summary {
    my $self = shift;

    my $tap_summary = $self->{tap_tree}->summary;

    return +{ %{ $tap_summary }, exit_code => $self->{exit_code} };
}

# accsessor methods
sub test_script { return $_[0]->{test_script}   }
sub tap_tree    { return $_[0]->{tap_tree}      }
sub exit_code   { return $_[0]->{exit_code}     }
sub stdout      { return decode( 'UTF-8', ${ $_[0]->{stdout_ref} } )  }
sub stderr      { return decode( 'UTF-8', ${ $_[0]->{stderr_ref} } )  }

# serialize methods
sub serialize {
    my $self = shift;

    my $tap_ref = {
        test_script => $self->{test_script},
        exit_code   => $self->{exit_code},
        tap_tree    => $self->{tap_tree}->tap_tree,
        stdout      => ${ $self->{stdout_ref} },
        stderr      => ${ $self->{stderr_ref} },
    };

    return freeze( $tap_ref );
}

sub create_from_serialized {
    my $pkg    = shift;
    my $serial = shift;

    my $tap_ref = thaw( $serial );

    my $tap = Shunme::TAP->new(
        test_script => $tap_ref->{test_script},
        exit_code   => $tap_ref->{exit_code},
        tap_tree    => TAP::Tree->new(
            tap_tree => $tap_ref->{tap_tree},
            utf8 => 1
            ),
        stdout_ref   => \$tap_ref->{stdout},
        stderr_ref   => \$tap_ref->{stderr},
        );

    return $tap;
}

1;
