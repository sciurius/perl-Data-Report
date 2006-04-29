# Data::Reporter.pm -- 
# RCS Info        : $Id$
# Author          : Johan Vromans
# Created On      : Wed Dec 28 13:18:40 2005
# Last Modified By: Johan Vromans
# Last Modified On: Sat Apr 29 18:23:18 2006
# Update Count    : 179
# Status          : Unknown, Use with caution!

package Data::Report;

use strict;
use warnings;
use Carp;

sub create {
    my ($class, %args) = @_;

    # 'type' attribute is mandatory.
    my $type = ucfirst(lc($args{type}));
    croak("Missing \"type\" attribute") unless $type;

    # Try to load class specific plugin.
    my $plugin = $class . "::" . $type;
    $plugin =~ s/::::/::/g;
    eval "use $plugin";

    unless ( _loaded($plugin) ) {
	# Try to load generic plugin.
	$plugin = __PACKAGE__ . "::Plugins::" . $type;
	$plugin =~ s/::::/::/g;
	eval "use $plugin";
    }
    croak("Unsupported type (Cannot load plug-in for \"$type\")\n$@")
      unless _loaded($plugin);

    # Return the plugin instance.
    # The constructor gets all args passed, including 'type'.
    $plugin->new(%args);
}

sub _loaded {
    my $class = shift;
    no strict "refs";
    %{$class . "::"} ? 1 : 0;
}
1;
