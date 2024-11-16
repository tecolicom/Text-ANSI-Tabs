requires 'perl', 'v5.14';

requires 'List::Util', '1.45';
requires 'Text::ANSI::Fold', '2.25';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Text::Tabs';
};

