#! perl

use strict;
use warnings;
use Test::More qw(no_plan);

package POC::Report;

use base qw(Data::Report);

package POC::Report::Text;

use base qw(Data::Report::Plugins::Text);

sub _std_heading {
    my $self = shift;
    $self->_print("Title line 1\n");
    $self->_print("Title line 2\n");
    $self->_print("\n");
    $self->SUPER::_std_heading;
    $self->{lines} -= 3;
}

sub _std_stylist {
    my ($rep, $row, $col) = @_;

    return { line_after => 1 }
      if $row eq "total" && !$col;
    return;
}

package main;

my $rep = POC::Report::->create(type => "text");
isa_ok($rep, 'POC::Report::Text');

$rep->set_layout
  ([ { name => "acct", title => "Acct",   width => 6  },
     { name => "desc", title => "Report", width => 40, align => "|" },
     { name => "deb",  title => "Debet",  width => 10, align => "<" },
     { name => "crd",  title => "Credit", width => 10, align => ">" },
   ]);

my $out = "";
$rep->set_output(\$out);
$rep->start;

is($rep->get_stylist, \&POC::Report::Text::_std_stylist, "CB: stylist");
is($rep->get_heading, \&POC::Report::Text::_std_heading, "CB: heading");

$rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "normal" });
$rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "normal" });
$rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "normal" });
$rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "total"  });
$rep->finish;
$rep->close;

is($rep->{lines}, $= - 10, "linecount");

my $ref; { undef $/; $ref = <DATA>; }
$ref =~ s/[\r\n]/\n/g;

is($out, $ref, "contents");

__DATA__
Title line 1
Title line 2

Acct                                      Report  Debet           Credit
------------------------------------------------------------------------
one                                          two  three             four
one                                          two  three             four
one                                          two  three             four
one                                          two  three             four
------------------------------------------------------------------------