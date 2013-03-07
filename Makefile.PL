use strict;
use ExtUtils::MakeMaker;

sub parseversion
{
    my $version;
  open GP, 'lib/Alien/Gnuplot.pm' or die "Couldn't open lib/Alien/Gnuplot.pm";
  for(<GP>){
      if(m/our \$VERSION = \'([\d\.]+b?)\'/) {$version = $1;}
      last if($version);
  }
  die "Couldn't parse version from Gnuplot.pm" unless($version);
  close GP;
  return $version;
}

sub MY::libscan
{
    package MY;

    my ($self, $file) = @_;

    # Don't install the README.pod or any .pl file
    return undef if $file =~ /\.pl$|^README.pod/;
    return $self->SUPER::libscan ($file);
}


########################################
########################################	
# reroute the main POD into a separate README.pod if requested. This is here
# purely to generate a README.pod for the github front page
my $POD_header = <<EOF;
=head1 OVERVIEW

Alien::Gnuplot is intended for distribution via CPAN.  This repository
stores the history for the Alien::Gnuplot module on CPAN. Install the
module via CPAN.

=cut
EOF
if(exists $ARGV[0] && $ARGV[0] eq 'README.pod')
{
  open MOD, 'lib/Alien/Gnuplot.pm' or die "Couldn't open main module";
  open README, '>README.pod'       or die "Couldn't open README.pod";

  print README $POD_header;

  while (<MOD>)
  {
    if (/^=/../^=cut/)
    { print README; }
  }
}


##############################
##############################
## Write a generic Makefile that puts the module in place.

WriteMakefile(
    NAME                => 'Alien::Gnuplot',
    AUTHOR              => 'Craig DeForest <craig@deforest.org>',
    VERSION             => parseversion(),
    ABSTRACT_FROM       => 'lib/Alien/Gnuplot.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
     ? ('LICENSE'=> 'perl')
     : ()),
    PREREQ_PM => { 'Time::HiRes' => 0,
		   'File::Temp'  => 0,
		   'HTTP::Tiny' => 0,
		   'POSIX'       => 0
    },
    META_ADD => {
	resources => {
	    homepage => 'http://github.com/drzowie/Alien-Gnuplot',
	    repository => 'git://github.com/drzowie/Alien-Gnuplot.git',
	    bugtracker => 'craig@deforest.org'
	}
    },		  

    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'PDL-Graphics-Gnuplot-*' },
	);

################################################################################
################################################################################
## Here we check for a working gnuplot.  What better way to do that than by
## executing our own library?  
{
    my $get_msg = '';

    eval q{ do q{./lib/Alien/Gnuplot.pm}; $get_msg = $@;};
    
    unless($get_msg) {
	if($Alien::Gnuplot::GNUPLOT_RECOMMENDED_VERSION > $Alien::Gnuplot::version) {
	    $get_msg = qq{
Gnuplot seems to exist on your system, but it is version $Alien::Gnuplot::version.
The minimum recommended version is $Alien::Gnuplot::GNUPLOT_RECOMMENDED_VERSION.

}
	}

	
    }

    if($get_msg) {
	print $get_msg . q{
Attempting to install/upgrade gnuplot on your system....

};
	install_gnuplot();
    }
}	

##############################
##############################
## The pedal meets the metal here.
##
## The strategy is to try to get a late-model
## binary from the Usual Suspects, and fall back
## to compiling it.
sub psn {
    if($_[0]) {
	print "Success!\n";
    }else {
	print "nope\n";
    }
}

sub install_gnuplot {
    local($|) = 1;

    ##############################
    # 
    if($^O eq 'darwin') {
      foo: {

   	   ##############################
	   # Binary distros - try macports, fink, homebrew
	  for my $manager( ['macports','port','http://macports.org'],
			['fink','fink','http://www.finkproject.org'],
			['homebrew','brew','http://mxcl.github.com/homebrew/']
	      ) {
	      print "Trying $manager->[0] (you can get it at $manager->[2])...";
	      my $l = `which $manager->[1]`;
	      if($l) {
		  print "\n";
		  print STDERR `$manager->[1] install gnuplot`;
		  my $msg;
		  eval q{ do q{lib/Alien/Gnuplot.pm}; $msg = $@; } ;
		  psn((!$msg) and ($Alien::Gnuplot::version));
		  last foo unless($msg);
	      } else {
		  print "no $manager->[0]\n";
	      }
	  }

	  die "No suitable package managers found! You'll have to get it yourself \n(from http://www.gnuplot.info).\n";
	}
    } 
    else {
	die "I don't know how to install gnuplot on a $^O system.  Please fix me!\n";
    }
}



