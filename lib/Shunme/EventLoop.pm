package Shunme::EventLoop;

use strict;
use warnings;
use v5.10.1;
use utf8;

use Module::Load::Conditional qw[can_load];
use Carp;

require Shunme::Aggregator;

sub create_eventloop {
    my $pkg    = shift;
    my %params = @_;

    my $module = 'Shunme::EventLoop::' . $params{module};

    can_load( modules => { $module => 0 } ) or croak "Can't load $module";

    my $eventloop = $module->new( %params );

    return $eventloop;

}

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = {
        iterator    => $params{iterator},
        formatter   => $params{formatter},
        aggregator  => Shunme::Aggregator->new,

        max_worker  => 10,
    };

    bless $self, $class;

    $self->initialize if $self->can( 'initialize' );

    return $self;
}

1;
