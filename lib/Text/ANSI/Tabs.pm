package Text::ANSI::Tabs;
our $VERSION = "1.06";

=encoding utf-8

=head1 NAME

Text::ANSI::Tabs - Tab expand and unexpand with ANSI sequence

=head1 SYNOPSIS

    use Text::ANSI::Tabs qw(:all);
    use Text::ANSI::Tabs qw(ansi_expand ansi_unexpand);
    ansi_expand($text);
    ansi_unexpand($text);

    use Text::ANSI::Tabs;
    Text::ANSI::Tabs::expand($text);
    Text::ANSI::Tabs::unexpand($text);

=head1 VERSION

Version 1.06

=cut

use v5.14;
use utf8;
use warnings;
use Data::Dumper;

BEGIN {
    *ansi_expand   = \&expand;
    *ansi_unexpand = \&unexpand;
}

use Exporter qw(import);
our @EXPORT_OK = qw(
    &ansi_expand &ansi_unexpand $tabstop
    &configure
    );
our %EXPORT_TAGS = ( all => [ @EXPORT_OK ] );

use Text::ANSI::Fold qw(
    $csi_re
    $reset_re
    $erase_re
    );
my  $end_re = qr{ $reset_re | $erase_re }x;

my $fold = Text::ANSI::Fold->new;

our $tabstop = 8;
our $min_space = 2;
our $REMOVE_REDUNDANT = 1;

sub configure {
    my $class = shift;
    @_ % 2 and die "invalid parameter.\n";
    my @fold_opt;
    while (my($k, $v) = splice(@_, 0, 2)) {
	if ($k eq 'tabstop') {
	    $tabstop = $v;
	}
	elsif ($k eq 'minimum') {
	    $v =~ /^\d+$/ and $v > 0
		or die "$v: invalid value for minimum space.\n";
	    $min_space = $v;
	} else {
	    push @fold_opt, $k => $v;
	}
    }
    $fold->configure(@fold_opt) if @fold_opt;
    return $fold;
}

sub IsEOL {
    <<"END";
0000\t0000
000A\t000D
2028\t2029
END
}

sub expand {
    $fold->configure(width => -1, expand => 1, tabstop => $tabstop,
		     ref $_[0] eq 'ARRAY' ? @{+shift} : ());
    my @l = map {
	s{^ (?>.*\t) (?: [^\e\n]* $end_re+ )? }{
	    join '', $fold->text(${^MATCH})->chops();
	}xmgepr;
    } @_;
    wantarray ? @l : $l[0];
}

sub unexpand {
    my @opt = ref $_[0] eq 'ARRAY' ? @{+shift} : ();
    my @l = map {
	s{ ^(.*[ ].*) }{ _unexpand($1) }xmger
    } @_;
    if ($REMOVE_REDUNDANT) {
	for (@l) {
	    1 while s/ (?<c>$csi_re+) [^\e\n]* \K $end_re+ \g{c} //xg;
	}
    }
    wantarray ? @l : $l[0];
}

sub _unexpand {
    local $_ = shift;
    my $ret = '';
    my $margin = 0;
    while (/ /) {
	my $width = $tabstop + $margin;
	my($a, $b, $w) = $fold->fold($_, width => $width);
	if ($w == $width) {
	    $a =~ s/([ ]{$min_space,})(?= $end_re* $)/\t/x;
	}
	$margin = $width - $w;
	$ret .= $a;
	$_ = $b;
    }
    $ret . $_;
}

1;

__END__

=head1 DESCRIPTION

ANSI sequence and Unicode wide characters aware version of Text::Tabs.

It assumes that the ANSI decoration is completed within a single line,
and cannot correctly process data where the effect continues over
multiple lines.

=head1 FUNCTION

There are exportable functions start with C<ansi_> prefix, and
unexportable functions without them.

=over 7

=item B<expand>(I<text>, ...)

=item B<ansi_expand>(I<text>, ...)

Expand tabs.  Interface is compatible with L<Text::Tabs>::expand().

Default tabstop is 8, and can be accessed through
C<$Text::ANSI::Tabs::tabstop> variable.

Option for the underlying C<Text::ANSI::Fold> object can be passed by
first parameter as an array reference, as well as C<<
Text::ANSI::Tabs->configure >> call.

    my $opt = [ tabhead => 'T', tabspace => '_' ];
    ansi_expand($opt, @text);

    Text::ANSI::Tabs->configure(tabstyle => 'bar');
    ansi_expand(@text);

See L<Text::ANSI::Fold> for detail.

=item B<unexpand>(I<text>, ...)

=item B<ansi_unexpand>(I<text>, ...)

Unexpand tabs.  Interface is compatible with
L<Text::Tabs>::unexpand().  Default tabstop is same as C<ansi_expand>.

Please be aware that, current implementation may add and/or remove
some redundant color designation code.

=back

=head1 METHODS

=over 7

=item B<configure>

Configure and return the underlying C<Text::ANSI::Fold> object.
Related parameters are those:

=over 4

=item B<tabstop> => I<num>

Set the value of variable C<$Text::ANSI::Tabs::tabstop> to I<num>.

=item B<tabhead> => I<char>

=item B<tabspace> => I<char>

Tab character is converted to B<tabhead> and following B<tabspace>
characters.  Both are white space by default.

=item B<tabstyle> => I<style>

Set tab expansion style.  This parameter set both B<tabhead> and
B<tabspace> at once according to the given style name.  Each style has
two values for tabhead and tabspace.

If two style names are combined, like C<symbol,space>, use
C<symbols>'s tabhead and C<space>'s tabspace.

=item B<minimum> => I<num>

By default, B<unexpand> converts two or more consecutive whitespace
characters into tab characters.  This parameter specifies the minimum
number of whitespace characters to be converted to tabs.  Specifying
it to 1 will convert all possible whitespace characters.

=back

See L<Text::ANSI::Fold> for detail.

=back

=head1 SEE ALSO

L<App::ansiexpand>,
L<https://github.com/tecolicom/App-ansiexpand>

L<Text::ANSI::Tabs>,
L<https://github.com/tecolicom/Text-ANSI-Tabs>

L<Text::ANSI::Fold::Util>,
L<https://github.com/tecolicom/Text-ANSI-Fold-Util>

L<Text::ANSI::Fold>,
L<https://github.com/tecolicom/Text-ANSI-Fold>

L<Text::Tabs>

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright 2021-2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

#  LocalWords:  ansi utf substr unexpand exportable unexportable
#  LocalWords:  tabstop tabhead tabspace Kazumasa Utashiro tabstyle
#  LocalWords:  whitespace
