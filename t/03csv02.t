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

my $ref; { undef $/; $ref = <DATA> }
$ref =~ s/[\r\n]/\n/g;

my $out;

SKIP: {
    skip "Text::CSV_XS not found", 1
      unless eval { require Text::CSV_XS };
    dotest(Text::CSV_XS::);
}

SKIP: {
    skip "Text::CSV not found", 1
      unless eval { require Text::CSV };
    dotest(Text::CSV::);
}

dotest();

sub dotest {
    my ($cls) = shift;
    $out = "";
    $rep->set_output(\$out);
    $rep->start;
    $rep->_set_csv_method($cls);
    $rep->add({ acct => 1234, desc => "two two", deb => "th,ree", crd => '"four"' });
    $rep->finish;
    $out =~ s/[\r\n]/\n/g;
    is($out, $ref);
}

__DATA__
"Acct","Report","Debet","Credit"
"1234","two two","th,ree","""four"""
