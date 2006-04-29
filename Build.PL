use strict;
use lib 'inc';
use Module::Build 0.27_09;

my $build = Module::Build->new
  (
   module_name	       => 'Data::Report',
   dist_author	       => 'Johan Vromans',
   dist_abstract       => 'Abstract',
   dist_version	       => '0.01',
   license	       => 'Perl',
   add_to_cleanup      => [ 'pod2htm*',
			    map { +"t/*.$_" }
			    qw(out)
			  ],
  );

$build->create_build_script;
