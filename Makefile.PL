use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Proc::Pidfile',
    'VERSION_FROM'	=> 'Pidfile.pm', # finds $VERSION
);
