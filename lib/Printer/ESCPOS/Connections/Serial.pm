use strict;
use warnings;

package Printer::ESCPOS::Connections::Serial;

# PODNAME: Printer::ESCPOS::Connections::Serial
# ABSTRACT: Serial Connection Interface for Printer::ESCPOS (supports status commands) 
# COPYRIGHT
# VERSION

# Dependencies

use 5.010;
use Moose;
with 'Printer::ESCPOS::Roles::Connection';
use namespace::autoclean;

use Device::SerialPort;

=attr deviceFilePath

This variable contains the path for the printer device file when connected as a serial device on UNIX-like systems. I haven't added support for Windows and it probably wont work in doz as a local printer without some modifications. Feel free to try it out and let me know what happens. This must be passed in the constructor

=cut

has deviceFilePath => (
    is  => 'ro',
    isa => 'Str',
);

=attr baudrate

When used as a local serial device you can set the baudrate of the printer too. Default (38400) will usually work, but not always. 

This param may be specified when creating printer object to make sure it works properly.

$printer = Printer::Thermal->new(deviceFilePath => '/dev/ttyACM0', baudrate => 9600);

=cut

has baudrate => (
    is      => 'ro',
    isa     => 'Int',
    default => 38400,
);

=attr readConstTime

Seconds per unfulfilled read call, default 150 

=cut

has readConstTime => (
    is      => 'ro',
    isa     => 'Int',
    default => 150,
);

has _connection => (
    is         => 'ro',
    lazy_build => 1,
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

no Moose;
__PACKAGE__->meta->make_immutable;

1;
