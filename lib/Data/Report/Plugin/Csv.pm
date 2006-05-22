# Data::Report::Plugin::Csv.pm -- CSV plugin for Data::Report
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : Thu Jan  5 18:47:37 2006
# Last Modified By: Johan Vromans
# Last Modified On: Mon May 22 17:51:41 2006
# Update Count    : 99
# Status          : Unknown, Use with caution!

package Data::Report::Plugin::Csv;

use strict;
use warnings;
use base qw(Data::Report::Base);

################ API ################

my $csv_implementation = 0;

sub start {
    my ($self, @args) = @_;
    $self->SUPER::start(@args);
    $self->set_separator(",") unless $self->get_separator;
    $self->_select_csv_method unless $csv_implementation;
    return;
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

    if ( $style and my $t = $self->_getstyle($style) ) {
	return if $t->{ignore};
    }

    $self->_checkhdr;

    my $line;

    $line = $self->_csv
      ( map {
	  $data->{$_->{name}} || ""
        } @{$self->_get_fields}
      );
    $self->_print($line, "\n");
}

sub set_separator { $_[0]->{sep} = $_[1] }
sub get_separator { $_[0]->{sep} || "," }

################ Pseudo-Internal (used by Base class) ################

sub _std_heading {
    my ($self) = @_;
    my $sep = $self->get_separator;

    $self->_print($self->_csv(map { $_->{title} } @{$self->_get_fields}), "\n");
}

################ Internal (used if no alternatives) ################

sub _csv_internal {
    join(shift->get_separator,
	 map {
	     # Quotes must be doubled.
	     s/"/""/g;
	     # Always quote (compatible with Text::CSV)
	     $_ = '"' . $_ . '"';
	     $_;
	 } @_);
}

sub _set_csv_method {
    my ($self, $class) = @_;
    no warnings qw(redefine);

    if ( $class && $class =~ /^Text::CSV_XS(?:::)?$/ ) {

	# Use always_quote to be compatible with Text::CSV.
	$csv_implementation = Text::CSV_XS->new
	  ({ sep_char => $self->get_separator,
	     always_quote => 1,
	   });

	# Assign the method.
	*_csv = sub {
	    shift;
	    $csv_implementation->combine(@_);
	    $csv_implementation->string;
	};
    }
    elsif ( $class && $class =~ /^Text::CSV(?:::)?$/ ) {

	$csv_implementation = Text::CSV->new;

	# Assign the method.
	*_csv = sub {
	    shift;
	    $csv_implementation->combine(@_);
	    $csv_implementation->string;
	};
    }
    else {
	# Use our internal method.
	*_csv = \&_csv_internal;
	$csv_implementation = "Data::Report::Plugin::Csv::_csv_internal";
    }

    return $csv_implementation;
}

sub _select_csv_method {
    my $self = shift;

    $csv_implementation = 0;
    eval {
	require Text::CSV_XS;
	$self->_set_csv_method(Text::CSV_XS::);
    };
    return $csv_implementation if $csv_implementation;

    if ( $self->get_separator eq "," ) {
      eval {
        require Text::CSV;
	$self->_set_csv_method(Text::CSV::);
      };
    }
    return $csv_implementation if $csv_implementation;

    # Use our internal method.
    $self->_set_csv_method();

    return $csv_implementation;
}

1;
