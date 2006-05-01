#! perl

use strict;
use warnings;
use Test::More qw(no_plan);

use Data::Report;

my $out = "";

my $rep = Data::Report::->create
  (type => "html",
   layout => [ { name => "acct", title => "Acct",   width => 6  },
	       { name => "desc", title => "Report", width => 40, align => "|" },
	       { name => "deb",  title => "Debet",  width => 10, align => "<" },
	       { name => "crd",  title => "Credit", width => 10, align => ">" },
	     ],
  );

$rep->set_output(\$out);
$rep->start;
$rep->add({ acct => "one", desc => "two", deb => "three", crd => "four" });
$rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "xyz" });
$rep->finish;
$rep->close;

my $ref; { undef $/; $ref = <DATA> }
$ref =~ s/[\r\n]/\n/g;
$out =~ s/[\r\n]/\n/g;

is($out, $ref);

__DATA__
<table class="main">
<tr class="head">
<th class="h_acct">Acct</th>
<th class="h_desc">Report</th>
<th class="h_deb">Debet</th>
<th align="right" class="h_crd">Credit</th>
</tr>
<tr>
<td class="c_acct">one</td>
<td class="c_desc">two</td>
<td class="c_deb">three</td>
<td align="right" class="c_crd">four</td>
</tr>
<tr class="r_xyz">
<td class="c_acct">one</td>
<td class="c_desc">two</td>
<td class="c_deb">three</td>
<td align="right" class="c_crd">four</td>
</tr>
</table>
