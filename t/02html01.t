#! perl

use strict;
use warnings;
use Test::More qw(no_plan);

use Data::Report;

chdir("t") if -d "t";

my $rep = Data::Report::->create
  (type => "html",
   layout => [ { name => "acct", title => "Acct",   width => 6  },
	       { name => "desc", title => "Report", width => 40, align => "|" },
	       { name => "deb",  title => "Debet",  width => 10, align => "<" },
	       { name => "crd",  title => "Credit", width => 10, align => ">" },
	     ],
  );

my $out = "";
$rep->set_output(\$out);
$rep->start;
$rep->finish;
$rep->close;

is($out, "");
