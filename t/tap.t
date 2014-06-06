use strict;
use warnings;
use v5.10.1;
use utf8;

use Test::More tests => 3;

require_ok( 'Shunme::TAP' );

subtest 'success' => sub {

    my $stdout = <<'STDOUT';
1..2
ok 1 - first test
ok 2 - second test
STDOUT

    my $stderr = '';

    my $tap = Shunme::TAP->new(
            test_script => 'test.t',
            exit_code   => 0,
            stdout_ref  => \$stdout,
            stderr_ref  => \$stderr,
            );

    my $summary = $tap->summary;

    plan tests => 4;

    is( $summary->{exit_code}, 0, 'exit code' );
    is( $summary->{failed_tests}, 0, 'fail test' );
    is( $summary->{ran_tests}, 2, 'number of test' );
    is( $summary->{planned_tests}, 2, 'plan' );
};

subtest 'failure' => sub {

    my $stdout = <<'STDOUT';
1..2
ok 1 - first test
not ok 2 - second test
STDOUT

    my $stderr = <<'STDERR';
#   Failed test 'second test'
#   at test.t line 7.
# Looks like you failed 1 test of 2.
STDERR

    my $tap = Shunme::TAP->new(
            test_script => 'test.t',
            exit_code   => 1,
            stdout_ref  => \$stdout,
            stderr_ref  => \$stderr,
            );

    my $summary = $tap->summary;

    plan tests => 4;

    is( $summary->{exit_code}, 1, 'exit code' );
    is( $summary->{fail}, 1, 'fail test' );
    is( $summary->{tests}, 2, 'number of test' );
    is( $summary->{plan}{number}, 2, 'plan' );
};
