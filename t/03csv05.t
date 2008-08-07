#! perl

use strict;
use warnings;
use Test::More;

plan(skip_all => "Text::CSV_XS not found"), exit
  unless eval { require Text::CSV_XS };

plan(tests => 1);

use Data::Report;

my $rep = Data::Report::->create
  (type => "csv",
   layout => [ { name => "acct", title => "Acct",   width => 6  },
	       { name => "desc", title => "Report", width => 40, align => "|" },
	       { name => "deb",  title => "Debet",  width => 10, align => "<" },
	       { name => "crd",  title => "Credit", width => 10, align => ">" },
	     ],
  );

my $out = "";
$rep->set_stylist(sub {
    my ($self, $row, $col) = @_;
    return { ignore => 1 } if $row eq "total" && !$col;
    return;
});
$rep->set_output(\$out);
$rep->start;
$rep->add({ acct => 1234, desc => "two", deb => "thr�e", crd => "four" });
$rep->add({ acct => 1235, desc => "two", deb => "thr�e", crd => "four" });
$rep->add({ acct => 1236, desc => "two", deb => "thr�e", crd => "four" });
$rep->add({ desc => "total", deb => "three", crd => "four", _style => "total" });
$rep->finish;
$rep->close;

my $ref; { undef $/; $ref = <DATA> }
$ref =~ s/[\r\n]/\n/g;
$out =~ s/[\r\n]/\n/g;
is($out, $ref);

__DATA__
"Acct","Report","Debet","Credit"
"1234","two","thr�e","four"
"1235","two","thr�e","four"
"1236","two","thr�e","four"
