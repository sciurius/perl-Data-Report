#! perl

use strict;
use warnings;
use Test::More qw(no_plan);

BEGIN { use_ok('Data::Report'); }
BEGIN { use_ok('Data::Report::Base'); }
BEGIN { use_ok('Data::Report::Plugin::Text'); }
BEGIN { use_ok('Data::Report::Plugin::Html'); }
BEGIN { use_ok('Data::Report::Plugin::Csv' ); }

diag("CSV uses ", Data::Report::Plugin::Csv->new->_select_csv_method, "\n");
