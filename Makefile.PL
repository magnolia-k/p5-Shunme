use 5.006;

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Shunme',
    AUTHOR           => q{magnolia <magnolia.k@me.com>},
    VERSION_FROM     => 'lib/Shunme.pm',
    ABSTRACT_FROM    => 'lib/Shunme.pm',
    LICENSE          => 'perl_5',
    MIN_PERL_VERSION => 5.010001,

    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.98,
    },

    BUILD_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.98,
    },

    TEST_REQUIRES => {
        'Test::Exception' => 0,
        'Test::Output' => 0,
    },

    PREREQ_PM => {
        'Test::Simple'  => '1.001002',
        'TAP::Tree'     => 'v0.0.4',
        'JSON'          => 0,
    },

    "EXE_FILES" => [
        "bin/uma",
        ],

    );
