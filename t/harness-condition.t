use strict;
use warnings;
use v5.10.1;
use utf8;

use Test::More tests => 4;

require_ok( 'Shunme::Harness::Condition' );
require_ok( 'Shunme::Harness::Condition::Iterator' );

my @test_scripts = qw[ test01.t test02.t ];

my $condition = Shunme::Harness::Condition->new(
        test_scripts => \@test_scripts
        );

subtest 'accessor' => sub {
    plan tests => 2;

    is( $condition->formatter, 'Console', 'formatter' );
    is( $condition->eventloop, 'Parallel::Poll', 'eventloop' );

};

subtest 'iterator' => sub {
    plan tests => 3;

    my $iterator = $condition->make_test_scripts_iterator;

    is( $iterator->next, 'test01.t', 'test01' );
    is( $iterator->next, 'test02.t', 'test02' );
    is( $iterator->next, undef, 'iterator finished' );
};
