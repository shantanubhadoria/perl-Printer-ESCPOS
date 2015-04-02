use strict;
use warnings;

package Printer::ESCPOS::Connections::Serial;

# PODNAME: Printer::ESCPOS::Connections::Serial
# ABSTRACT: Serial Connection Interface for L<Printer::ESCPOS> (supports status commands) 
# COPYRIGHT
# VERSION

# Dependencies

use 5.010;
use Moo;
with 'Printer::ESCPOS::Roles::Connection';

use Device::SerialPort;
use Time::HiRes qw(usleep);

=attr deviceFilePath

This variable contains the path for the printer device file when connected as a serial device on UNIX-like systems. I haven't added support for Windows and it probably wont work in doz as a local printer without some modifications. Feel free to try it out and let me know what happens. This must be passed in the constructor

=cut

has deviceFilePath => (
    is  => 'ro',
);

=attr baudrate

When used as a local serial device you can set the baudrate of the printer too. Default (38400) will usually work, but not always. 

This param may be specified when creating printer object to make sure it works properly.

$printer = Printer::Thermal->new(deviceFilePath => '/dev/ttyACM0', baudrate => 9600);

=cut

has baudrate => (
    is      => 'ro',
    default => 38400,
);

=attr readConstTime

Seconds per unfulfilled read call, default 150 

=cut

has readConstTime => (
    is      => 'ro',
    default => 150,
);

=attr serialOverUSB

Set this value to 1 if you are connecting your printer using the USB Cable but it shows up as a serial device

=cut

has serialOverUSB => (
  is      => 'rw',
  default => '0',
);

has _connection => (
    is         => 'lazy',
    init_arg   => undef,
);

sub _build__connection {
    my ($self) = @_;

    my $printer = new Device::SerialPort( $self->deviceFilePath )
        || die "Can't open Port: $!\n";
    $printer->baudrate( $self->baudrate );
    $printer->read_const_time( $self->readConstTime ); # 1 second per unfulfilled "read" call
    $printer->read_char_time( 0 );     # don't wait for each character

    return $printer;
}

=method read

Read Data from the printer 

=cut

sub read {
    my ( $self, $question, $bytes ) = @_;
    $bytes |= 1024;

    $self->_connection->write( $question );
    my ( $count, $data ) = $self->_connection->read( $bytes );

    return $data;
}

=method print

Sends buffer data to the printer.

=cut

sub print {
    my ( $self, $raw ) = @_;
    my @chunks;

    my $buffer = $self->_buffer;
    if( defined $raw ) {
        $buffer = $raw;
    } else {
        $self->_buffer('');
    }

    my $n      = 8;                # Size of each chunk in bytes
    $n = 64 if ( $self->serialOverUSB );

    @chunks = unpack "a$n" x ( ( length($buffer) / $n ) - 1 ) . "a*", $buffer;
    for my $chunk (@chunks) {
        $self->_connection->write($chunk);
        if ( $self->serialOverUSB ) {
            $self->_connection->read();
        }
        else {
            usleep(10000)
              ; # Serial Port is annoying, it doesn't tell you when it is ready to get the next chunk
        }
    }
}

no Moo;
__PACKAGE__->meta->make_immutable;

1;
