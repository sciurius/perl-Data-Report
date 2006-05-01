# $Id$

use strict;
use Module::Build 0.28;

my $builder = Module::Build->new(

    module_name         => 'Data::Report',
    license             => 'perl',
    dist_author         => 'Johan Vromans <jvromans@squirrel.nl>',
    dist_version_from   => 'lib/Data/Report.pm',

    recommends => {
	'HTML::Entities' => 0,
    },

    build_requires => {
        'Test::More' => 0,
    },

#    auto_features => {
#	Use_HTML_Entities => {
#	    description => "Use HTML::Entities for HTML",
#	    requires    => { 'HTML::Entities' => 0 },
#	},
#    },

    add_to_cleanup => [
	'Data-Report-*',
	'pod2htm*',
	map { +"t/*.$_" } qw(out)
    ],
);

$builder->create_build_script;
