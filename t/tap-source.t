use strict;
use warnings;
use v5.10.1;
use utf8;

use Test::More tests => 3;

use FindBin qw[$Bin];

require_ok( 'Shunme::TAP::Source' );

subtest 'success' => sub {
    my $script  = File::Spec->catfile( $Bin, 'test_stuff', '01-success.test' );

    my $source = Shunme::TAP::Source->new( test_script => $script );
    my $tap    = $source->execute_test_script;

    my $summary = $tap->summary;

    plan tests => 2;
    is( $summary->{exit_code}, 0, 'success' );
    is( $summary->{tests}, 2, 'number of tests' );
};

subtest 'failure' => sub {
    my $script  = File::Spec->catfile( $Bin, 'test_stuff', '02-failure.test' );

    my $source = Shunme::TAP::Source->new( test_script => $script );
    my $tap    = $source->execute_test_script;

    my $summary = $tap->summary;

    plan tests => 2;
    is( $summary->{exit_code}, 1, 'failure' );
    is( $summary->{tests}, 2, 'number of tests' );
};

