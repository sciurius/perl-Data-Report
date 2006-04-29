# Data::Report::Text.pm -- Text plugin for Data::Report
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : Wed Dec 28 13:21:11 2005
# Last Modified By: Johan Vromans
# Last Modified On: Sat Apr 29 16:16:15 2006
# Update Count    : 114
# Status          : Unknown, Use with caution!

package Data::Report::Plugins::Text;

use strict;
use warnings;
use base qw(Data::Report::Base);
use Carp;

################ API ################

sub start {
    my $self = shift;
    $self->_argcheck(0);
    $self->SUPER::start;
    $self->_make_format;
    $self->{lines} = 0;
    $self->{page} = $=;
}

sub finish {
    my $self = shift;
    $self->_argcheck(0);
    $self->_checkskip(1);	# cancel skips.
    $self->SUPER::finish();
}

sub add {
    my ($self, $data) = @_;

    my $style = delete($data->{_style});

    $self->SUPER::add($data);

    $self->_checkhdr;

    my $skip_after = 0;
    my $line_after = 0;
    my $cancel_skip = 0;
    if ( $style and my $t = $self->_getstyle($style) ) {
	$self->_skip if $t->{skip_before};
	$skip_after   = $t->{skip_after};
	$self->_line if $t->{line_before};
	$line_after   = $t->{line_after};
	$cancel_skip  = $t->{cancel_skip};
    }

    $self->_checkskip($cancel_skip);

    my @values;
    my @widths;
    my @indents;
    my $linebefore;
    my $lineafter;

    foreach my $col ( @{$self->_get_fields} ) {
	my $fname = $col->{name};
	push(@values, defined($data->{$fname}) ? $data->{$fname} : "");
	push(@widths, $col->{width});

	# Examine style mods.
	my $indent = 0;
	my $excess = 0;
	if ( $style ) {
	    if ( my $t = $self->_getstyle($style, $fname) ) {
		$indent = $t->{indent} || 0;
		if ( $t->{line_before} ) {
		    $linebefore->{$fname} =
		      ($t->{line_before} eq "1" ? "-" : $t->{line_before}) x $col->{width};
		}
		if ( $t->{line_after} ) {
		    $lineafter->{$fname} =
		      ($t->{line_after} eq "1" ? "-" : $t->{line_after}) x $col->{width};
		}
		if ( $t->{excess} ) {
		    $widths[-1] += 2;
		}
		if ($t->{truncate} ) {
		    $values[-1] = substr($values[-1], 0, $widths[-1] - $indent);
		}
	    }
	}
	push(@indents, $indent);

    }

    if ( $linebefore ) {
	$self->add($linebefore);
    }

    my @lines;
    while ( 1 ) {
	my $more = 0;
	my @v;
	foreach my $i ( 0..$#widths ) {
	    my $ind = $indents[$i];
	    my $maxw = $widths[$i] - $ind;
	    $ind = " " x $ind;
	    if ( length($values[$i]) <= $maxw ) {
		push(@v, $ind.$values[$i]);
		$values[$i] = "";
	    }
	    else {
		my $t = substr($values[$i], 0, $maxw);
		if ( substr($values[$i], $maxw, 1) eq " " ) {
		    push(@v, $ind.$t);
		    substr($values[$i], 0, length($t) + 1, "");
		}
		elsif ( $t =~ /^(.*)([ ]+)/ ) {
		    my $pre = $1;
		    push(@v, $ind.$pre);
		    substr($values[$i], 0, length($pre) + length($2), "");
		}
		else {
		    push(@v, $ind.$t);
		    substr($values[$i], 0, $maxw, "");
		}
		$more++;
	    }
	}
	my $t = sprintf($self->{format}, @v);
	$t =~ s/ +$//;
	push(@lines, $t) if $t =~ /\S/;
	last unless $more;
    }

    if ( $self->{lines} < @lines ) {
	$self->_needhdr(1);
	$self->_checkhdr;
    }
    $self->_print(@lines);
    $self->{lines} -= @lines;

    # Post: Lines for cells.
    if ( $lineafter ) {
	$self->add($lineafter);
    }
    # Post: Line for row.
    if ( $line_after ) {
	$self->_line;
    }
    # Post: Skip after this row.
    elsif ( $skip_after ) {
	$self->_skip;
    }
}

################ Pseudo-Internal (used by Base class) ################

sub _std_heading {
    my ($self) = @_;

    # Print column names.
    my $t = sprintf($self->{format},
		    map { $_->{title} } @{$self->_get_fields});

    # Add separator line.
    $t .= "-" x ($self->{width});
    $t .= "\n";

    # Remove trailing blanks.
    $t =~ s/ +$//gm;

    # Print it.
    $self->_print($t);

    $self->_needskip(0);
    my $cnt = $t =~ tr/\n/\n/;
    $self->{lines} = $self->{page} - $cnt;

}

################ Internal methods ################

sub _make_format {
    my ($self) = @_;

    my $width = 0;		# new width
    my $format = "";		# new format

    foreach my $a ( @{$self->_get_fields} ) {

	# Never mind the trailing blanks -- we'll trim anyway.
	$width += $a->{width} + 2;
	if ( $a->{align} eq "<" ) {
	    $format .= "%-".
	      join(".", ($a->{width}+2) x 2) .
		"s";
	}
	else {
	    $format .= "%".
	      join(".", ($a->{width}) x 2) .
		"s  ";
	}
    }

    # Store format and width in object.
    $self->{format} = $format . "\n";
    $self->{width}  = $width - 2;

    # PBP: Return nothing sensible.
    return;
}

sub _checkskip {
    my ($self, $cancel) = @_;
    return if !$self->_does_needskip || $self->{lines} <= 0;
    $self->{lines}--,$self->_print("\n") unless $cancel;
    $self->_needskip(0);
}

sub _needskip {
    my $self = shift;
    $self->_argcheck(1);
    $self->{needskip } = shift;
}
sub _does_needskip {
    my $self = shift;
    $self->_argcheck(0);
    $self->{needskip};
}

sub _line {
    my ($self) = @_;

    $self->_checkhdr;
    $self->_checkskip(1);	# cancel skips.

    $self->_print("-" x ($self->{width}), "\n");
    $self->{lines}--;
}

sub _skip {
    my ($self) = @_;

    $self->_checkhdr;
    $self->_needskip(1);
}

sub _center {
    my ($self, $text, $width) = @_;
    (" " x (($width - length($text))/2)) . $text;
}

sub _expand {
    my ($self, $text) = @_;
    $text =~ s/(.)/$1 /g;
    $text =~ s/ +$//;
    $text;
}

1;
