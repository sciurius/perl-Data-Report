#! perl

use strict;
use warnings;
use Test::More qw(no_plan);

use Data::Report;

chdir("t") if -d "t";

my $data = "01text.out";

my $rep = Data::Report::->create
  (layout => [ { name => "acct", title => "Acct",   width => 6  },
	       { name => "desc", title => "Report", width => 40, align => "|" },
	       { name => "deb",  title => "Debet",  width => 10, align => "<" },
	       { name => "crd",  title => "Credit", width => 10, align => ">" },
	     ],
  );
isa_ok($rep, 'Data::Report::Plugin::Text');

$rep->set_output($data);
$rep->start;
$rep->finish;
$rep->close;

ok(-s $data == 0);
unlink($data);

