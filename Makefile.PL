use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Proc::Pidfile',
    'VERSION_FROM'	=> 'Pidfile.pm', # finds $VERSION
    'PREREQ_PM'		=> {
        Proc::ProcessTable => 0,
        Fcntl => 0,
        File::Basename => 0,
        File::Spec=> 0,
    }, # e.g., Module::Name => 1.1
);
