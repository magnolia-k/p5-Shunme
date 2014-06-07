on 'configure' => sub {
    requires    'ExtUtils::MakeMaker',  '6.98';
};

on 'build' => sub {
    requires    'ExtUtils::MakeMaker',  '6.98';
};

on 'test' => sub {
    requires    'Test::Exception',      '0';
    requires    'Test::Output',         '0';
};


requires    'Test::Simple', '1.001002';
requires    'TAP::Tree',    'v0.0.4';
requires    'JSON',         '0';
