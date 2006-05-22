#! perl

use strict;
use warnings;
use Test::More qw(no_plan);

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
$rep->add({ acct => 1234, desc => "two", deb => "three", crd => "four" });
$rep->add({ acct => 1235, desc => "two", deb => "three", crd => "four" });
$rep->add({ acct => 1236, desc => "two", deb => "three", crd => "four" });
$rep->add({ desc => "total", deb => "three", crd => "four", _style => "total" });
$rep->finish;
$rep->close;

my $ref; { undef $/; $ref = <DATA> }
$ref =~ s/[\r\n]/\n/g;
$out =~ s/[\r\n]/\n/g;
is($out, $ref);

__DATA__
"Acct","Report","Debet","Credit"
"1234","two","three","four"
"1235","two","three","four"
"1236","two","three","four"
