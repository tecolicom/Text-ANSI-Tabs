use v5.14;
use warnings;
use Test::More 0.98;
use utf8;
use open IO => ':utf8', ':std';

use Text::ANSI::Tabs qw(ansi_expand);
use Text::Tabs;
use Data::Dumper;
{
    no warnings 'redefine';
    *Data::Dumper::qquote = sub { qq["${\(shift)}"] };
    $Data::Dumper::Useperl = 1;
}

sub r {
    my $opt = ref $_[0] ? shift : {};
    my $pattern = $opt->{pattern} ||  q/\S+/;
    $_[0] =~ s/($pattern)/\e[97;41m$1\e[m/gr;
}

my $pattern = <<"END" =~ s/^#.*\n//gr;
#12345670123456701
0	01	01
	0	01
0123		01
01234567	01
		01
END

sub IsEOL {
    <<"END";
0000\t0000
000A\t000D
2028\t2029
END
}

sub rx { return r({ pattern => qr/[^\s\p{IsEOL}]+/ }, @_) }
sub ex { return x(\&expand, @_) }
sub x {
    (my $f, local $_) = @_;
    s/(\P{IsEOL}+)/$f->($1)/ger;
}

for my $t (($pattern =~ s/\n/\0/gr), ($pattern =~ s/\n/\N{U+2028}/gr)) {
    my $x = ex($t);
    for my $p (
	[ $t => $x ],
	[ rx($t) => rx($x) ],
	)
    {
	my($s, $a) = @$p;
	is(ansi_expand($s), $a, sprintf("ansi_expand(\"%s\") -> \"%s\"", $s, $a));
    }

}

done_testing;
