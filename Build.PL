use strict;
use warnings;

use Alien::Base::ModuleBuild;

my $builder = Alien::Base::ModuleBuild->new(
  module_name => 'Alien::Gnuplot',
  license => 'perl',
  configure_requires => {
    'Alien::Base' => '0.001_001',
    'Module::Build' => 0.38,
  },
  requires => {
    'perl' => '5.8.1',
    'Alien::Base' => 0,
  },
  dist_author => 'Craig DeForest <craig@deforest.org>',
  alien_name => 'gnuplot',
  alien_repository => {
    protocol => 'http',
    location => 'http://www.gnuplot.info',
    pattern  => qr/^gnuplot-\d.\d.\d.tar.gz$/,
  },
);
$builder->create_build_script;

