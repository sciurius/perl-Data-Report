# $id$

package Data::Report::API;

=head1 NAME

Data::Report::API - Documentation of the user API for Data::Report

=head1 SYNOPSIS

This is a documentation-only module. It describes the user API for Data::Report.

    use Data::Report;

    # Factory call to create a reporter.
    my $rpt = Data::Report->create;

    # User API calls.
    $rpt->set_layout(...);   # define layout
    $rpt->start;	     # start the reporter
    $rpt->add(...);          # add a row of data
    $rpt->add(...);          # add a row of data
    $rpt->finish;            # finish the reporter

=head1 BASIC METHODS

=head2 new

This method creates a new instance of a reporter. It is called
internally by the reporter factory.

This method takes either none, or one single argument: a hash
reference of initialisation arguments. All initialisation arguments
correspond to attribute handling methods, see below. For example,

  my $rpt = Data::Report->create({foo => 1, bar => "Hello!"});

is identical to:

  my $rpt = Data::Report->create;
  $rpt->set_foo(1);
  $rpt->set_bar("Hello!");

You can choose any combination at your convenience.

=head2 start

This method indicates that all setup has been completed, and starts
the reporter. Note that no output is generated until the C<add> method
is called.

C<start> takes no arguments.

Although this method could be eliminated by automatically starting the
reporter upon the first call to C<add>, it turns out that an aplicit
C<start> makes the API much cleaner and makes it easier to catch mistakes.

=head2 add

This method adds a new entry to the report. It takes one single
argument, a hash ref of column names and the corresponding values.
Missing columns are left blank.

In addition to the column names and values, you can add the special
key C<_style> to designate a particular style for this entry. What
that means depends on the plugin that implements this reporter. For
example, the standard HTML reporter plugin prefixes the given style
with C<r_> to form the class name for the row.

Example

  $rpt->add({ date   => "2006-04-31",
              amount => 1000,
              descr  => "First payment",
              _style => "plain" });

=head2 finish

This method indicates that report generation is complete. After this,
you can call C<start> again to initiate a new report.

C<finish> takes no arguments.

=head2 close

This is a convenience method. If the output stream was set up by the
reporter itself (see C<set_output>, below), the stream will be
closed. Otherwise, this method will be a no-op.

C<close> takes no arguments.

=head1 ATTRIBUTE HANDLING METHODS

=head2 set_layout

This is the most important attribute, since it effectively defines the report layout.

This method takes one argument, an array reference. Each element of
the array is a hash reference that corresponds to one column in the
report. The order of elements definines the order of the columns in
the report, but see C<set_fields> below.

The following keys are possible in the hash reference:

=over 4

=item C<name>

The name of this column. The name should be a simple name, containing
letters, digits and underscores, not starting with an underscore.

The standard HTML reporter plugin uses the column name to form a class
name for each cell by prefixing with C<c_>. Likewise, the classes for
the table headings will be formed by prefixing the column names with
C<h_>. See L<ADVANCED EXAMPLES>, below.

=item C<title>

The title of this column. This title is placed in the column heading.

=item C<width>

The width of this column.
Relevant for textual reporters only.

By default, if a value does not fit in the given width, it will be
spread over multiple rows in a pseudo-elegant way. See also the
C<truncate> key, below.

=item C<align>

The alignment of this column. This can be either C<< < >> for
left-aligned columns, or C<< > >> to indicate a right-aligned column.

=item C<truncate>

If true, the values in this column will be truncated to fit the width
of the column.
Relevant for textual reporters only.

=back

=head2 set_style

This method can be used to set an arbitrary style (a string) whose
meaning depends on the implementing plugin. For example, a HTML plugin
could use this as the name of the style sheet to use.

=head2 get_style

Returns the style, or C<default> if none.

=head2 set_output

Designates the destination for the report. The argument can be

=over 4

=item a SCALAR reference

All output will be appended to the designated scalar.

=item an ARRAY reference

All output lines will be pushed onto the array.

=item a SCALAR

A file will be created with the given name, and all output will be
written to this file. To close the file, use the C<close> method described above.

=item anything else

Anything else will be considered to be a file handle, and treated as such.

=back

=head2 set_stylist

The stylist is a powerful method to control the appearance of the
report at the row and cell level. The basic idea is taken from HTML
style sheets. By using a stylist, it is possible to add extra spaces
and lines to rows and cells in a declarative way.

When used, the stylist should be a reference to a possibly anonymous
subroutine with three arguments: the reporter object, the style of a
row (as specified with C<_style> in the C<add> method), and the name
of a column as defined in the layout.

The stylist routine will be repeatedly called by the reporter to
obtain formatting properties for rows and cells. It should return
either nothing, or a hash reference with properties.

When called with only the C<row> argument, it should return the
properties for this row.

When called with row equal to "*" and a column name, it should return
the properties for the given column.

When called with a row and a column name, it should return the
properties for the given row/column (cell).

All appropriate properties are merged to form the final set of
properties to apply.

Currently, layout properties are only supported by the textual reporter.

The following row properties are recognised:

=over 4

=item C<skip_before>

Produce an empty line before printing the current row.

=item C<skip_after>

Produce an empty line after printing the current row, but only if
other data follows.

=item C<line_before>

Draw a line of dashes before printing the current row.

=item C<line_after>

Draw a line of dashes after printing the current row.

=item C<cancel_skip>

Cancel the effect of a pending C<skip_after>

=back

The following cell properties are recognised:

=over 4

=item C<indent>

Indent the contents of this cell with the given amount.

=item C<truncate>

If true, truncate the contents of this cell to fit the column width.

=item C<line_before>

Draw a line in the cell before printing the current row. The value of
this property indicates the symbol to use to draw the line. If it is
C<1>, dashes are used.

=item C<line_after>

Draw a line in the cell after printing the current row. The value of
this property indicates the symbol to use to draw the line. If it is
C<1>, dashes are used.

=back

Example:

  $rep->set_stylist(sub {
    my ($rep, $row, $col) = @_;

    unless ( $col ) {
	return { line_after => 1 } if $row eq "total";
	return;
    }
    return { line_after => 1 } if $col eq "amount";
    return;
  });

Each reporter provides a standard (dummy) stylist called
C<_std_stylist>. Overriding this method is equivalent to using
C<set_stylist>.

=head2 get_stylist

Returns the current stylist, if any.

=head2 set_heading

This method can be used to designate a subroutine that provides the
heading of the report.

Each reporter plugin provides a standard heading, implemented in a
method called C<_std_header>. This is the default value for the
C<heading> attribute. A user-defined heading can use

  $self->SUPER::_std_header;

to still get the original heading produced.

Example:

  $rpt->set_heading(sub {
    my $self = shift;
    $self->_print("Title line 1\n");
    $self->_print("Title line 2\n");
    $self->_print("\n");
    $self->SUPER::_std_heading;
  });

Note the use of the reporter provided C<_print> method to produce output.

Overriding C<_std_heading> is equivalent to using C<set_heading>. When
subclassing a reporter it is possible to override C<_std_heading> and
still be able to use the SUPER.

=head2 get_heading

Returns the current heading routine, if any.

=head2 set_fields

This method can be used to define what columns (fields) should be
included in the report and the order they should appear. It takes an
array reference with the names of the desired columns.

Example:

  $rpt->set_fields([qw(descr amount date)]);

=head2 get_fields

Returns the current set of selected columns.

=head2 set_width

This method defines the width for one or more columns. It takes a hash
reference with column names and widths. The width may be an absolute
number, a relative number (to increase/decrease the with, or a
percentage.

Example:

  $rpt->set_width({ amount => 10, desc => '80%' });

=head2 get_widths

Returns a hash with all column names and widths.

=head1 ADVANCED EXAMPLES

This example subclasses Data::Report with an associated pulgin for
type C<text>. Note the use of overriding C<_std_heading> and
C<_std_stylist> to provide special defaults for this reporter.

  package POC::Report;

  use base qw(Data::Report);

  package POC::Report::Text;

  use base qw(Data::Report::Plugin::Text);

  sub _std_heading {
      my $self = shift;
      $self->_print("Title line 1\n");
      $self->_print("Title line 2\n");
      $self->_print("\n");
      $self->SUPER::_std_heading;
  }

  sub _std_stylist {
      my ($rep, $row, $col) = @_;

      return { line_after => 1 }
	if $row eq "total" && !$col;
      return;
  }

It can be used as follows:

  my $rep = POC::Report::->create(type => "text");

  $rep->set_layout
    ([ { name => "acct", title => "Acct",   width => 6  },
       { name => "desc", title => "Report", width => 40, align => "<" },
       { name => "deb",  title => "Debet",  width => 10, align => "<" },
       { name => "crd",  title => "Credit", width => 10, align => ">" },
     ]);

  $rep->start;

  $rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "normal" });
  $rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "normal" });
  $rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "normal" });
  $rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "total"  });

  $rep->finish;

This is a similar example for a HTML reporter:

  package POC::Report;

  use base qw(Data::Report);

  package POC::Report::Html;

  use base qw(Data::Report::Plugin::Html);

  sub start {
      my $self = shift;
      $self->{_title1} = shift;
      $self->{_title2} = shift;
      $self->{_title3} = shift;
      $self->SUPER::start;
  }

  sub _std_heading {
      my $self = shift;
      $self->_print("<html>\n",
		    "<head>\n",
		    "<title>", $self->_html($self->{_title1}), "</title>\n",
		    '<link rel="stylesheet" href="css/', $self->get_style, '.css">', "\n",
		    "</head>\n",
		    "<body>\n",
		    "<p class=\"title\">", $self->_html($self->{_title1}), "</p>\n",
		    "<p class=\"subtitle\">", $self->_html($self->{_title2}), "<br>\n",
		    $self->_html($self->{_title3}), "</p>\n");
      $self->SUPER::_std_heading;
  }

  sub finish {
      my $self = shift;
      $self->SUPER::finish;
      $self->_print("</body>\n</html>\n");
  }

Note that it defines an alternative C<start> method, that is used to
pass in additional parameters for title fields.

The method C<_html> is a convenience method provided by the framework.
It returns its argument with sensitive characters escaped by HTML
entities.

It can be used as follows.

  package main;

  my $rep = POC::Report::->create(type => "html");

  $rep->set_layout
    ([ { name => "acct", title => "Acct",   width => 6  },
       { name => "desc", title => "Report", width => 40, align => "<" },
       { name => "deb",  title => "Debet",  width => 10, align => "<" },
       { name => "crd",  title => "Credit", width => 10, align => ">" },
     ]);

  $rep->start(qw(Title_One Title_Two Title_Three_Left&Right));

  $rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "normal" });
  $rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "normal" });
  $rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "normal" });
  $rep->add({ acct => "one", desc => "two", deb => "three", crd => "four", _style => "total"  });

  $rep->finish;

The output will look like this:

  <html>
  <head>
  <title>Title_One</title>
  <link rel="stylesheet" href="css/default.css">
  </head>
  <body>
  <p class="title">Title_One</p>
  <p class="subtitle">Title_Two<br>
  Title_Three_Left&amp;Right</p>
  <table class="main">
  <tr class="head">
  <th class="h_acct">Acct</th>
  <th class="h_desc">Report</th>
  <th class="h_deb">Debet</th>
  <th class="h_crd">Credit</th>
  </tr>
  <tr class="r_normal">
  <td class="c_acct">one</td>
  <td class="c_desc">two</td>
  <td class="c_deb">three</td>
  <td class="c_crd">four</td>
  </tr>
  <tr class="r_normal">
  <td class="c_acct">one</td>
  <td class="c_desc">two</td>
  <td class="c_deb">three</td>
  <td class="c_crd">four</td>
  </tr>
  <tr class="r_normal">
  <td class="c_acct">one</td>
  <td class="c_desc">two</td>
  <td class="c_deb">three</td>
  <td class="c_crd">four</td>
  </tr>
  <tr class="r_total">
  <td class="c_acct">one</td>
  <td class="c_desc">two</td>
  <td class="c_deb">three</td>
  <td class="c_crd">four</td>
  </tr>
  </table>
  </body>
  </html>

=head1 AUTHOR

Johan Vromans, C<< <jvromans at squirrel.nl> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-data-report at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-Report>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2006 Johan Vromans, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
