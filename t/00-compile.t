use 5.006;
use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::Compile 2.054

use Test::More;

plan tests => 9 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

my @module_files = (
    'Printer/ESCPOS.pm',
    'Printer/ESCPOS/Connections/File.pm',
    'Printer/ESCPOS/Connections/Network.pm',
#    'Printer/ESCPOS/Connections/USB.pm', 
#    Skip this for errors in Device::USB
    'Printer/ESCPOS/Manual.pm',
    'Printer/ESCPOS/Profiles/Generic.pm',
    'Printer/ESCPOS/Profiles/SinocanPSeries.pm',
    'Printer/ESCPOS/Roles/Connection.pm',
    'Printer/ESCPOS/Roles/Profile.pm'
);



# fake home for cpan-testers
use File::Temp;
local $ENV{HOME} = File::Temp::tempdir( CLEANUP => 1 );


my $inc_switch = -d 'blib' ? '-Mblib' : '-Ilib';

use File::Spec;
use IPC::Open3;
use IO::Handle;

open my $stdin, '<', File::Spec->devnull or die "can't open devnull: $!";

my @warnings;
for my $lib (@module_files)
{
    # see L<perlfaq8/How can I capture STDERR from an external command?>
    my $stderr = IO::Handle->new;

    my $pid = open3($stdin, '>&STDERR', $stderr, $^X, $inc_switch, '-e', "require q[$lib]");
    binmode $stderr, ':crlf' if $^O eq 'MSWin32';
    my @_warnings = <$stderr>;
    waitpid($pid, 0);
    is($?, 0, "$lib loaded ok");

    shift @_warnings if @_warnings and $_warnings[0] =~ /^Using .*\bblib/
