#===============================================================================
#
#         FILE: 00-use.t
#
#  DESCRIPTION: Use the module, check it compiles
#
#       AUTHOR: Pete Houston (pete), cpan@openstrike.co.uk
#
#===============================================================================

use strict;
use warnings;
no warnings 'once';

use Test::More tests => 2;

use_ok 'Alien::Gnuplot';
ok defined $Alien::Gnuplot::version, 'Gnuplot found';
