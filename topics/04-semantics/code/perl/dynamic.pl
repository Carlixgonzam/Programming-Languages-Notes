use strict;
use warnings;

our $x = 10;
sub f { return $x; }
sub g { local $x = 20; return f(); }

die "FAIL" unless g() == 20;
die "FAIL" unless f() == 10;
print "ok\n";
