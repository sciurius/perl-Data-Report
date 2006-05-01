# Data::Reporter.pm -- Framework for flexible reporting
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : Wed Dec 28 13:18:40 2005
# Last Modified By: Johan Vromans
# Last Modified On: Mon May  1 16:04:41 2006
# Update Count    : 217
# Status          : Unknown, Use with caution!

package Data::Report;

=head1 NAME

Data::Report - Framework for flexible reporting

=head1 VERSION

0.01

=cut

$VERSION = 0.01;

=head1 SYNOPSIS

    use Data::Report;

    # Factory call to create a reporter.
    my $rpt = Data::Report->create;

    # User API calls.
    $rpt->set_layout(...);   # define layout
    $rpt->start;	     # start the reporter
    $rpt->add(...);          # add a row of data
    $rpt->add(...);          # add a row of data
    $rpt->finish;            # finish the reporter

=head1 DESCRIPTION

Data::Report is a flexible, plugin-driven reporting framework.

This module is the factory that creates reporter objects.

For the documentation of the user API, see L<Data::Report::API>.

For the documentation on writing your own plugins, see L<Data::Report::Base>.

The Data::Report framework consists of three parts:

=over 4

=item The plugins

Plugins implement a specific type of report. Standard plugins provided
are C<Data::Report::Plugin::Text> for textual reports,
C<Data::Report::Plugin::Html> for HTML reports, and
C<Data::Report::Plugin::Csv> for CSV (comma-separated) files.

Users can, and are encouraged, to develop their own plugins to handle
different styles and types of reports.

=item The base class

The base class C<Data::Report::Base> implements the functionality
common to all reporters, plus a number of utility functions the
plugins can use.

=item The factory

The actual C<Data::Report> module is a factory that creates a
reporter for a given report type by selecting the appropriate plugin
and returning an instance thereof.

=back

=cut

use strict;
use warnings;
use Carp;

=head1 METHODS

=head2 create

Reporter objects are created using the class method C<create>. This
method takes a hash (or hashref) of arguments to initialise the
reporter object.

The actual reporter object is implemented by one of the plugin
modules, selected by the C<type> argument. Standard plugins are
provided for C<text>, C<HTML> and C<CSV> report types. The default
type is C<text>.

When looking for a plugin to support report type C<foo>, the C<create>
method will first try to load a module C<My::Package::Foo> where
C<My::Package> is the invocant class. If this module cannot be loaded,
it will fall back to C<Data::Report::Plugin::Foo>. Note that, unless
subclassed, the current class will be C<Data::Report>.

All other initialisation arguments correspond to attribute setting
methods provided by the plugins. For example, the hypothetical call

  my $rpt = Data::Report->create(foo => 1, bar => "Hello!");

is identical to:

  my $rpt = Data::Report->create;
  $rpt->set_foo(1);
  $rpt->set_bar("Hello!");

You can choose any combination at your convenience.

For a description of the possible methods, see L<Data::Report::API>.

=cut

sub create {
    my $class = shift;
    my $args;
    if ( @_ == 1 && UNIVERSAL::isa($_[0], 'HASH') ) {
	$args = shift;
    }
    else {
	$args = { @_ };
    }

    # 'type' attribute is mandatory.
    my $type = ucfirst(lc($args->{type}));
    #croak("Missing \"type\" attribute") unless $type;
    $type = "Text" unless $type;

    # Try to load class specific plugin.
    my $plugin = $class . "::" . $type;
    $plugin =~ s/::::/::/g;

    # Strategy: load the class, and see if it exists.
    # A plugin does not necessary have to be external, if one of the
    # other classes did define the requested plugin we'll use that
    # one.

    # First, try the plugin in this invocant class.
    eval "use $plugin";

    unless ( _loaded($plugin) ) {

	# Try to load generic plugin.
	$plugin = __PACKAGE__ . "::Plugin::" . $type;
	$plugin =~ s/::::/::/g;
	eval "use $plugin";
    }
    croak("Unsupported type (Cannot load plug-in for \"$type\")\n$@")
      unless _loaded($plugin);

    # Return the plugin instance.
    # The constructor gets all args passed, including 'type'.
    $plugin->new($args);
}

sub _loaded {
    my $class = shift;
    no strict "refs";
    %{$class . "::"} ? 1 : 0;
}

1;

__END__

=head1 AUTHOR

Johan Vromans, C<< <jvromans at squirrel.nl> >>

=head1 BUGS

I<Disclaimer: This module is derived from actual working code, that I
turned into a generic CPAN module. During the process, some features
may have become unstable, but that will be cured in time. Also, it is
possible that revisions of the API will be necessary when new
functionality is added.>

Please report any bugs or feature requests to
C<bug-data-report at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-Report>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Data::Report
    perldoc Data::Report::API     (user API)
    perldoc Data::Report::Base    (plugin writer documentation)

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Data-Report>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Data-Report>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Report>

=item * Search CPAN

L<http://search.cpan.org/dist/Data-Report>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Squirrel Consultancy, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of Data::Report
