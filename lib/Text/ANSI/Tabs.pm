package Text::ANSI::Tabs;
our $VERSION = "0.06";

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

Version 0.06

=cut

use v5.14;
use utf8;
use warnings;
use Data::Dumper;

use Exporter qw(import);
our @EXPORT_OK = qw(&ansi_expand &ansi_unexpand $tabstop);
our %EXPORT_TAGS = ( all => [ @EXPORT_OK ] );

sub ansi_expand   { goto &expand }
sub ansi_unexpand { goto &unexpand }

use Text::ANSI::Fold qw(ansi_fold);

our $tabstop = 8;
our $spacechar = ' ';

sub expand {
    my @opt = ref $_[0] eq 'ARRAY' ? @{+shift} : ();
    my @l = map {
	s{^(.*\t)}{
	    (ansi_fold($1, -1, expand => 1, tabstop => $tabstop, @opt))[0];
	}mger;
    } @_;
    wantarray ? @l : $l[0];
}

my $reset_re = qr{ \e \[ [0;]* m }x;
my $erase_re = qr{ \e \[ [\d;]* K }x;
my $end_re   = qr{ $reset_re | $erase_re }x;
my $csi_re   = qr{
    # see ECMA-48 5.4 Control sequences
    \e \[		# csi
    [\x30-\x3f]*	# parameter bytes
    [\x20-\x2f]*	# intermediate bytes
    [\x40-\x7e]		# final byte
}x;

our $REMOVE_REDUNDANT = 1;

sub unexpand {
    my @opt = ref $_[0] eq 'ARRAY' ? @{+shift} : ();
    my @l = map {
	s{ (.*[ ].*) }{ _unexpand($1) }xmger
    } @_;
    if ($REMOVE_REDUNDANT) {
	for (@l) {
	    1 while s/ (?<c>$csi_re+) [^\e]* \K $end_re+ \g{c} //xg;
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
	my($a, $b, $w) = ansi_fold($_, $width);
	if ($w == $width) {
	    $a =~ s/([ ]+)(?= $end_re* $)/\t/x;
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

=head1 FUNCTION

There are exportable functions start with B<ansi_> prefix, and
unexportable functions without them.

=over 7

=item B<expand>(I<text>, ...)

=item B<ansi_expand>(I<text>, ...)

Expand tabs.  Interface is compatible with L<Text::Tabs>::expand().

Default tabstop is 8, and can be accessed through
C<$Text::ANSI::Tabs::tabstop> variable.

Option for underlying B<ansi_fold> can be passed by first parameter as
an array reference, as well as C<< Text::ANSI::Fold->configure >> call.

    my $opt = [ tabhead => 'T', tabspace => '_' ];
    ansi_expand($opt, @text);

    Text::ANSI::Fold->configure(tabhead => 'T', tabspace => '_');
    ansi_expand(@text);

=item B<unexpand>(I<text>, ...)

=item B<ansi_unexpand>(I<text>, ...)

Unexpand tabs.  Interface is compatible with
L<Text::Tabs>::unexpand().  Default tabstop is same as C<ansi_expand>.

Please be aware that, current implementation may leave some redundant
color designation code.

=back

=head1 SEE ALSO

L<Text::ANSI::Fold::Util>,
L<Text::ANSI::Fold::Tabs>,
L<https://github.com/kaz-utashiro/Text-ANSI-Fold-Util>

L<Text::ANSI::Fold>,
L<https://github.com/kaz-utashiro/Text-ANSI-Fold>

L<Text::Tabs>

=head1 LICENSE

Copyright 2021 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kazumasa Utashiro E<lt>kaz@utashiro.comE<gt>

=cut

#  LocalWords:  ansi utf substr unexpand exportable unexportable
#  LocalWords:  tabstop tabhead tabspace Kazumasa Utashiro
