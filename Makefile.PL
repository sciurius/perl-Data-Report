#! perl

use strict;
use warnings;
use ExtUtils::MakeMaker;

my $master = 'lib/Data/Report.pm';
my $version = MM->parse_version($master);

WriteMakefile(
 NAME                => 'Data::Report',
 AUTHOR              => 'Johan Vromans <jv@cpan.org>',
 VERSION             => $version,
 ABSTRACT_FROM       => $master,
 LICENSE             => 'perl_5',
 PL_FILES            => {},
 DIR		     => [],
 MIN_PERL_VERSION    => '5.010001',
 PREREQ_PM => {
     'ExtUtils::MakeMaker' => 6.46, # for META_MERGE, LICENSE
     'Test::More' => 0,
     'Text::CSV'  => 1.00,
 },
 TEST_REQUIRES  => {
        'Text::CSV'  => 1.00,
 },
 META_MERGE => {
   resources    => {
     repository => {
       type => 'git',
       web  => 'https://github.com/sciurius/perl-Data-Report',
       url  => 'https://github.com/sciurius/perl-Data-Report.git',
     },
     bugtracker => {
       web => "https://github.com/sciurius/perl-Data-Report/issues",
     },
   },
   'meta-spec' => {
     version => '2',
     url     => 'https://metacpan.org/pod/CPAN::Meta::Spec',
   },
   provides => {
       "Data::Report"
		=> { file => "lib/Text/Layout.pm",
		     version => $version },
       "Data::Report::FontConfig"
		=> { file => "lib/Text/Layout/FontConfig.pm",
		     version => $version },
       "Data::Report::FontDescriptor"
		=> { file => "lib/Text/Layout/FontDescriptor.pm",
		     version => $version },
   },
   recommends => {
		  'HTML::Entities' => 0,
   },

   no_index => {
         file => [
		  "lib/Text/Layout/Cairo.pm",
		  "lib/Text/Layout/Markdown.pm",
		  "lib/Text/Layout/Pango.pm",
		  "lib/Text/Layout/PDFAPI2.pm",
	 ],
       directory => [
	  "tests",
       ],
       package => [ qw(DB) ],
   },
 }
);
