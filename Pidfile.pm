package Proc::Pidfile;

$VERSION = '1.002';
use Fcntl qw( :flock );
use File::Basename qw( basename );
require File::Spec;

sub new 
{ 
    my $class = shift;
    my %args = @_;
    my $self = bless \%args, $class;
    unless ( $self->{pidfile} )
    {
        my $basename = basename( $0 );
        my $dir = -w "/var/run" ? "/var/run" : File::Spec->tmpdir();
        die "Can't write to $dir\n" unless -w $dir;
        $pidfile = "$dir/$basename.pid";
        $self->_verbose( "pidfile: $pidfile\n" );
        $self->{pidfile} = $pidfile;
    }
    $self->_create_pidfile();
    return $self;
}

sub DESTROY
{
    my $self = shift;
    $self->_destroy_pidfile();
}

sub pidfile
{
    my $self = shift;
    return $self->{pidfile};
}

sub _verbose
{
    my $self = shift;
    return unless $self->{verbose};
    print STDERR @_;
}

sub _get_pid
{
    my $self = shift;
    my $pidfile = $self->{pidfile};
    $self->_verbose( "get pid from $pidfile\n" );
    open( PID, $pidfile ) or die "can't read pid file $pidfile\n";
    flock( PID, LOCK_SH );
    my $pid = <PID>;
    chomp( $pid );
    flock( PID, LOCK_UN );
    close( PID );
    $self->_verbose( "pid = $pid\n" );
    return $pid;
}

sub _create_pidfile
{
    my $self = shift;
    my $pidfile = $self->{pidfile};
    if ( -e $pidfile )
    {
        $self->_verbose( "pidfile $pidfile exists\n" );
        my $pid = $self->_get_pid();
        $self->_verbose( "pid in pidfile $pidfile = $pid\n" );
        if ( kill( 0, $pid ) )
        {
            if ( $self->{silent} )
            {
                exit;
            }
            else
            {
                die "$0 already running: $pid\n";
            }
        }
        else
        {
            $self->_verbose( "$pid has died - relacing pidfile\n" );
            open( PID, ">$pidfile" ) or die "Can't write to $pidfile\n";
            print PID "$$\n";
            close( PID );
        }
    }
    else
    {
        $self->_verbose( "no pidfile $pidfile\n" );
        open( PID, ">$pidfile" ) or die "Can't write to $pidfile\n";
        flock( PID, LOCK_EX );
        print PID "$$\n";
        flock( PID, LOCK_UN );
        close( PID );
        $self->_verbose( "pidfile $pidfile created\n" );
    }
    $self->{created} = 1;
}

sub _destroy_pidfile
{
    my $self = shift;

    return unless $self->{created};
    my $pidfile = $self->{pidfile};
    $self->_verbose( "destroy $pidfile\n" );
    unless ( $pidfile and -e $pidfile )
    {
        die "pidfile $pidfile doesn't exist\n";
    }
    my $pid = $self->_get_pid();
    $self->_verbose( "pid in $pidfile = $pid\n" );
    if ( $pid == $$ )
    {
        $self->_verbose( "remove pidfile: $pidfile\n" );
        unlink( $pidfile ) if $pidfile and -e $pidfile;
    }
    else
    {
        $self->_verbose(  "$pidfile not my pidfile - maybe my parents?\n" );
        my $ppid = getppid();
        $self->_verbose(  "parent pid = $ppid\n" );
        if ( $ppid != $pid )
        {
            die "pid $pid in $pidfile is not mine ($$) - I am $0 - or my parents ($ppid)\n";
        }
    }
}

#------------------------------------------------------------------------------
#
# Start of POD
#
#------------------------------------------------------------------------------

=head1 NAME

Proc::Pidfile - a simple OO Perl module for maintaining a process id file for
the curent process

=head1 SYNOPSIS

    my $pp = Proc::Pidfile->new( pidfile = "/path/to/your/pidfile" );
    # if the pidfile already exists, die here
    $pidfile = $pp->pidfile();
    undef $pp;
    # unlink $pidfile here

    my $pp = Proc::Pidfile->new();
    # creates pidfile in default location - /var/run or File::Spec->tmpdir ...
    my $pidfile = $pp=>pidfile();
    # tells you where this pidfile is ...

    my $pp = Proc::Pidfile->new( silent => 1 );
    # if the pidfile already exists, exit silently here
    ...
    undef $pp;

=head1 DESCRIPTION

Proc::Pidfile is a very simple OO interface which manages a pidfile for the
current process. You can pass the path to a pidfile to use as an argument to
the constructor, or you can let Proc::Pidfile choose one (basically, "/var/run/$basename", if you can write to /var/run, otherwise "/$tmpdir/$basename").

Pidfiles created by Proc::Pidfile are automatically removed on destruction of
the object. At destruction, the module checks the process id in the pidfile
against its own, and against its parents (in case it is a spawned child of the
process that originally created the Proc::Pidfile object), and barfs if it
doesn't match either.

If you pass a "silent" parameter to the constructor, then it will still check
for the existence of a pidfile, but will exit silently if one is found. This is
useful for, for example, cron jobs, where you don't want to create a new
process if one is already running, but you don't necessarily want to be
informed of this by cron.

=head1 SEE ALSO

Proc::PID::File

=head1 AUTHOR

Ave Wrigley <Ave.Wrigley@itn.co.uk>

=head1 COPYRIGHT

Copyright (c) 2003 Ave Wrigley. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms as Perl
itself.

=cut

#------------------------------------------------------------------------------
#
# End of POD
#
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
#
# True ...
#
#------------------------------------------------------------------------------

1;

