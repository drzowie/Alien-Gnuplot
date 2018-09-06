#===============================================================================
#
#         FILE: 00-use.t
#
#  DESCRIPTION: Use the module, check it compiles, check module version
#
#       AUTHOR: Pete Houston (pete), cpan@openstrike.co.uk
#
#===============================================================================

use strict;
use warnings;

use Test::More tests => 3;

BEGIN {
	use_ok 'Alien::Gnuplot';
}

is ($Alien::Gnuplot::VERSION, '1.033', 'Module version matches');
ok (defined $Alien::Gnuplot::version, 'Gnuplot found');
