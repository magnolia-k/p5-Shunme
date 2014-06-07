package Shunme::App;

use strict;
use warnings;
use v5.10.1;
use utf8;

use Getopt::Long qw[GetOptionsFromArray];
use Carp;
use File::Spec;

sub new {
    my $class = shift;

    my $self = {
        argv    => [],
        cmd     => undef,
        verbose => undef,
        library => {
            lib     => undef,
            blib    => undef,
            include => [],
        },
    };

    bless $self, $class;

    return $self;
}

sub parse_options {
    my $self = shift;
    my @argv = @_;

    GetOptionsFromArray( \@argv,
            'v|verbose' => sub { $self->{verbose}++         },
            'b|blib'    => sub { $self->{library}{blib}++   },
            'l|lib'     => sub { $self->{library}{lib}++    },
            );

    $self->{argv} = \@argv;
}

sub run {
    my $self = shift;

    if ( ! $self->{cmd} ) {
        $self->{cmd} = 'runtests';
    }

    my $method = '_run_cmd_' . $self->{cmd};
    my $exit_code;
    if ( $self->can( $method ) ) {
        $exit_code = $self->$method;
    } else {
        croak "Can't find method:$method";
    }

    return $exit_code;
}

sub _run_cmd_runtests {
    my $self = shift;

    my @test_scripts = $self->_gather_test_scripts;
   
    require Shunme::Harness::Condition;
    my $condition = Shunme::Harness::Condition->new(
           test_scripts => \@test_scripts,
           verbose      => $self->{verbose},
           library      => $self->{library},
           );

    require Shunme::Harness;
    my $harness = Shunme::Harness->new( condition => $condition );

    my $exit_code = $harness->run_tests;

    return $exit_code;
}

sub _gather_test_scripts {
    my $self = shift;

    # quick hack
    if ( ! -d 't' ) {
        croak "Can't find directory:t";
    }

    opendir( my $dh, 't' );
    my @list = readdir $dh;
    closedir( $dh );

    my @test_scripts;
    for my $file ( @list ) {
        next unless ( $file =~ /\.t$/ );

        push @test_scripts, File::Spec->catfile( 't', $file );
    }

    return @test_scripts;
}

1;
