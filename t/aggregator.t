use strict;
use warnings;
use v5.10.1;
use utf8;

use Test::More tests => 4;

require_ok( 'Shunme::Aggregator' );

subtest 'Pass' => sub {

    my $aggregator = Shunme::Aggregator->new;

    $aggregator->start_aggregation;
   
    my $summary1 = { ran_tests => 2, failed_tests => 0, exit_code => 0 };
    $aggregator->add( tap_summary => $summary1 );

    my $summary2 = { ran_tests => 3, failed_tests => 0, exit_code => 0 };
    $aggregator->add( tap_summary => $summary2 );

    $aggregator->stop_aggregation;

    plan tests => 5;

    my $summary = $aggregator->summary;
    is( $summary->{test_scripts}, 2, 'number of test scripts' );
    is( $summary->{ran_tests}, 5, 'number of ran tests' );
    is( $summary->{failed_tests}, 0, 'number of failed tests' );
    like( $summary->{elapsed_time_str}, qr/wallclock secs/, 'elapsed time' );
    is( $summary->{result_str}, 'Pass', 'result str' );
};

subtest 'Fail' => sub {

    my $aggregator = Shunme::Aggregator->new;

    $aggregator->start_aggregation;
   
    my $summary1 = { ran_tests => 2, failed_tests => 0, exit_code => 0 };
    $aggregator->add( tap_summary => $summary1 );

    my $summary2 = { ran_tests => 3, failed_tests => 1, exit_code => 1 };
    $aggregator->add( tap_summary => $summary2 );

    $aggregator->stop_aggregation;

    plan tests => 5;

    my $summary = $aggregator->summary;
    is( $summary->{test_scripts}, 2, 'number of test scripts' );
    is( $summary->{ran_tests}, 5, 'number of tests' );
    is( $summary->{failed_tests}, 1, 'number of failed tests' );
    like( $summary->{elapsed_time_str}, qr/wallclock secs/, 'elapsed time' );
    is( $summary->{result_str}, 'Fail', 'result str' );
};

subtest 'No Tests' => sub {

    my $aggregator = Shunme::Aggregator->new;

    $aggregator->start_aggregation;
   
    $aggregator->stop_aggregation;

    plan tests => 5;

    my $summary = $aggregator->summary;
    is( $summary->{test_scripts}, 0, 'number of test scripts' );
    is( $summary->{ran_tests}, 0, 'number of tests' );
    is( $summary->{failed_tests}, 0, 'number of failed tests' );
    like( $summary->{elapsed_time_str}, qr/wallclock secs/, 'elapsed time' );
    is( $summary->{result_str}, 'No Tests', 'result str' );
};
