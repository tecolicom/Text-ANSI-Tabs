
# NAME

Text::ANSI::Tabs - Tab expand and unexpand with ANSI sequence

# SYNOPSIS

    use Text::ANSI::Tabs qw(:all);
    use Text::ANSI::Tabs qw(ansi_expand ansi_unexpand);
    ansi_expand($text);
    ansi_unexpand($text);

    use Text::ANSI::Tabs;
    Text::ANSI::Tabs::expand($text);
    Text::ANSI::Tabs::unexpand($text);

# VERSION

Version 0.06

# DESCRIPTION

ANSI sequence and Unicode wide characters aware version of Text::Tabs.

# FUNCTION

There are exportable functions start with **ansi\_** prefix, and
unexportable functions without them.

- **expand**(_text_, ...)
- **ansi\_expand**(_text_, ...)

    Expand tabs.  Interface is compatible with [Text::Tabs](https://metacpan.org/pod/Text::Tabs)::expand().

    Default tabstop is 8, and can be accessed through
    `$Text::ANSI::Tabs::tabstop` variable.

    Option for underlying **ansi\_fold** can be passed by first parameter as
    an array reference, as well as `Text::ANSI::Fold->configure` call.

        my $opt = [ tabhead => 'T', tabspace => '_' ];
        ansi_expand($opt, @text);

        Text::ANSI::Fold->configure(tabhead => 'T', tabspace => '_');
        ansi_expand(@text);

- **unexpand**(_text_, ...)
- **ansi\_unexpand**(_text_, ...)

    Unexpand tabs.  Interface is compatible with
    [Text::Tabs](https://metacpan.org/pod/Text::Tabs)::unexpand().  Default tabstop is same as `ansi_expand`.

    Please be aware that, current implementation may leave some redundant
    color designation code.

# SEE ALSO

[Text::ANSI::Fold::Util](https://metacpan.org/pod/Text::ANSI::Fold::Util),
[Text::ANSI::Fold::Tabs](https://metacpan.org/pod/Text::ANSI::Fold::Tabs),
[https://github.com/kaz-utashiro/Text-ANSI-Fold-Util](https://github.com/kaz-utashiro/Text-ANSI-Fold-Util)

[Text::ANSI::Fold](https://metacpan.org/pod/Text::ANSI::Fold),
[https://github.com/kaz-utashiro/Text-ANSI-Fold](https://github.com/kaz-utashiro/Text-ANSI-Fold)

[Text::Tabs](https://metacpan.org/pod/Text::Tabs)

# LICENSE

Copyright 2021 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Kazumasa Utashiro <kaz@utashiro.com>
