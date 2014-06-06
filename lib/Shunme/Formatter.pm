package Shunme::Formatter;

use strict;
use warnings;
use v5.10.1;
use utf8;

use Module::Load::Conditional qw[can_load];
use Carp;

sub create_formatter {
    my $pkg    = shift;
    my %params = @_;

    my $module = 'Shunme::Formatter::' . $params{module};

    can_load( modules => { $module => 0 } ) or croak "Can't load $module";

    my $formatter = $module->new( %params );

    return $formatter;
}

sub new {
    my $class  = shift;
    my %params = @_;
    
    my $self = {
        verbose => $params{verbose},
    };

    bless $self, $class;

    return $self;
}

sub start {
    my $self = shift;

    # virtual method
}

sub format_tap_output {
    my $self = shift;

    # virtual method
}

sub finish {
    my $self = shift;

    # virtual method
}

1;
