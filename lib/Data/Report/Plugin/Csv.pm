# Data::Report::Plugins::Csv.pm -- CSV plugin for Data::Report
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : Thu Jan  5 18:47:37 2006
# Last Modified By: Johan Vromans
# Last Modified On: Sat Apr 29 16:17:39 2006
# Update Count    : 33
# Status          : Unknown, Use with caution!

package Data::Report::Plugins::Csv;

use strict;
use warnings;
use base qw(Data::Report::Base);

################ API ################

sub start {
    my ($self, @args) = @_;
    $self->SUPER::start(@args);
    $self->set_separator(",") unless $self->get_separator;
}

sub finish {
    my ($self) = @_;
    $self->SUPER::finish();
}

sub add {
    my ($self, $data) = @_;

    my $style = delete($data->{_style});

    my $sep = $self->get_separator;

    $self->SUPER::add($data);

    return unless %$data;

    $self->_checkhdr;

    my $line;

    foreach my $col ( @{$self->_get_fields} ) {
	my $fname = $col->{name};
	my $value = defined($data->{$fname}) ? $self->_csv($data->{$fname}) : "";
	$line .= $sep if defined($line);
	$line .= $value;
    }

    $self->_print($line, "\n");
}

sub set_separator { $_[0]->{sep} = $_[1] }
sub get_separator { $_[0]->{sep} }

################ Pseudo-Internal (used by Base class) ################

sub _std_heading {
    my ($self) = @_;
    my $sep = $self->get_separator;

    $self->_print(join($sep, map { $self->_csv($_->{title}) } @{$self->_get_fields}), "\n");
}

################ Internal methods ################

sub _csv {
    my ($self, $value) = @_;
    my $sep = $self->get_separator;
    # Quotes must be doubled.
    $value =~ s/"/""/g;
    # Quote if anything non-simple.
    $value = '"' . $value . '"'
      if $value =~ /\s|$sep|"/
	|| $value !~ /^[+-]?\d+([.,]\d+)?/;

    return $value;
}

1;
