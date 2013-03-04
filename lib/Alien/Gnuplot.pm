package Alien::Gnuplot;

use strict;
use warnings;

use File::Temp qw/tempfile/;
use Time::HiRes qw/usleep/;
use POSIX ":sys_wait_h";

our $VERSION = '0.001';
$VERSION = eval $VERSION;

our $executable;  # Holds the path to the found gnuplot
our $version;     # Holds the found version number
our $pl;          # Holds the found patchlevel

##############################
# Search the path for the executable
#
my $exec_path;
if($ENV{'GNUPLOT_BINARY'}) {
   $exec_path = $ENV{'GNUPLOT_BINARY'};
} else {
    my $exec_str = "gnuplot";
    if( defined($ENV{'PATH'}) ) {
	# POSIX path present...
	my @path = split (/\:/,$ENV{'PATH'});
	for my $dir(@path) {
	    $exec_path = "$dir/$exec_str";
	    last if( -x $exec_path );
	}
    } else {
	die "Alien::Gnuplot: No POSIX-style path found, and no GNUPLOT_BINARY environment\nvariable found either\n\n";
    }
}

unless(-x $exec_path) {
    die "Alien::Gnuplot: no executable gnuplot found (use GNUPLOT_BINARY environment\nvariable, get gnuplot, or reinstall Alien::Gnuplot to get it).\n";
}


##############################
# Execute the executable to make sure it's really gnuplot, and parse
# out its reported version.  This is complicated by gnuplot's shenanigans
# with STDOUT and STDERR, so we fork and redirect everything to a file.
# The parent process gives the daughter 2 seconds to report progress, then
# kills it dead.
my($pid);
my ($undef, $file) = tempfile('gnuplot_test_XXXX');

$pid = fork();
if(!$pid) {
    # daughter
    open STDOUT, ">$file";
    open STDERR, ">&STDOUT";
    open FOO, "|$exec_path";
    print FOO "show version\n";
    close FOO;
    exit(0);
}
elsif($pid>0) {
    # Poll for 2 seconds, cheesily.
    for (1..20) {
	if(waitpid($pid,WNOHANG)) {
	    $pid=0;
	    last;
	}
	usleep(1e5);
    }

    if($pid) {
	kill 9,$pid;   # zap
	waidpid($pid); # reap
    }
} else {
    die "Couldn't fork!";
}

##############################
# Read what gnuplot had to say, and clean up our mess...
open FOO, "<$file";
my @lines = <FOO>;
unlink $file;


##############################
# Whew.  Now parse out the 'GNUPLOT' and version number...
my $lines = join("", map { chomp $_; $_} @lines);

$lines =~ s/\s+G N U P L O T\s*//  or  die "Alien::Gnuplot:  executable $exec_path appears not to be gnuplot!\n";
$lines =~ m/Version (\d+\.\d+) (patchlevel (\d+))?/ or die "Alien::Gnuplot: couldn't figure the gnuplot version number!\n";

$version = $1;
$pl = $3;
$executable = $exec_path;

1;

__END__

=head1 NAME

Alien::Gnuplot - Find and verify functionality of the gnuplot executable.

=head1 SYNOPSIS

 package MyGnuplotter;

 use strict;
 use warnings;

 use Alien::Gnuplot;

 $gnuplot = $Alien::Gnuplot::executable;

 `$gnuplot < /tmp/plotfile`;

 1;

=head1 DESCRIPTION

As an Alien module, Alien::Gnuplot verifies existence of the gnuplot executable.
Installing Alien::Gnuplot checks your system for the presence of gnuplot, and installs
it if necessary (and possible).  Using Alien::Gnuplot merely checks for existence 
of the library.  It also sets three global variables:

=over 3

=item * C<$Alien::Gnuplot::executable> gets the path to the executable that was found.

=item * C<$Alien::Gnuplot::version> gets the self-reported version number of the executable.

=item * C<$Alien::Gnuplot::pl> gets the self-reported patch level.

=back

You can point Alien::Gnuplot to a particular path for gnuplot, by setting the 
environment variable GNUPLOT_BINARY to the path.

=head1 SOURCE REPOSITORY

http://github.com/drzowie/Alien-Gnuplot

=head1 AUTHOR

Craig DeForest <craig@deforest.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Craig DeForest

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

