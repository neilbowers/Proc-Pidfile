#!/bin/env perl -w
# vim:filetype=perl

use strict;
use warnings;

use Test::More tests => 21;
BEGIN { require_ok( 'Proc::Pidfile' ); }
my ( $err, $obj, $pidfile, $ppid, $pid );
$obj = Proc::Pidfile->new();
$pidfile = $obj->pidfile();
ok( -e $pidfile, "pidfile created" );
undef $obj;
ok( ! -e $pidfile, "pidfile destroyed" );
$pidfile = '/tmp/Proc::Pidfile.test.pid';
$obj = Proc::Pidfile->new( pidfile => $pidfile );
is( $obj->pidfile(), $pidfile, "temp pidfile matches" );
ok( -e $pidfile, "temp pidfile created" );
undef $obj;
ok( ! -e $pidfile, "temp pidfile destroyed" );
$obj = Proc::Pidfile->new();
$pidfile = $obj->pidfile();
ok( open( FH, $pidfile ), "open pidfile" );
$pid = <FH>;
chomp( $pid );
ok( close( FH ), "close pidfile" );
is( $pid, $$, "pid correct" );
undef $obj;
$obj = Proc::Pidfile->new();
$pid = fork;
if ( $pid == 0 ) { undef $obj; exit(0); }
ok( defined( $pid ), "fork successful" );
is( $pid, waitpid( $pid, 0 ), "child exited" );
is( $? >> 8, 0, "child ignored parent's pidfile" );
ok( -e $pidfile, "child ignored pidfile" );
undef $obj;
ok( ! -e $pidfile, "parent destroyed pidfile" );
eval {
    my $pp = Proc::Pidfile->new();
    $pidfile = $pp->pidfile();
    unlink( $pidfile );
    undef $pp;
};
$err = $@;
undef $@;
like( $err, qr/pidfile $pidfile doesn't exist/, "die on removed pidfile" );
$obj = Proc::Pidfile->new();
$ppid = $$;
$pid = fork;
if ( $pid == 0 )
{
    open ( STDERR, ">/dev/null" );
    $obj = Proc::Pidfile->new();
    exit( 0 );
}
ok( defined( $pid ), "fork successful" );
is( $pid, waitpid( $pid, 0 ), "child exited" );
is( $? >> 8, 2, "child spotted existing pidfile" );
$pid = fork;
if ( $pid == 0 )
{
    $obj = Proc::Pidfile->new( silent => 1 );
    exit( 2 );
}
ok( defined( $pid ), "fork successful" );
is( $pid, waitpid( $pid, 0 ), "silent child exited" );
is( $? >> 8, 0, "child spotted and ignored existing pidfile" );
