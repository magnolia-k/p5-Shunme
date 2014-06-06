use strict;
use warnings;
use v5.10.1;
use utf8;

use Test::More tests => 1;
use Test::Output;

use FindBin qw[$Bin];

require Shunme::TAP::Source;
require Shunme::Formatter;

subtest 'success' => sub {
    my $script  = File::Spec->catfile( $Bin, 'test_stuff', '01-success.test' );

    my $source = Shunme::TAP::Source->new( test_script => $script );
    my $tap    = $source->execute_test_script;

    my $formatter = Shunme::Formatter->create_formatter( module => 'Console' );

    stdout_like {
        $formatter->format_tap_output( tap => $tap )
    } qr/01-success\.test/, 'test output';
};
