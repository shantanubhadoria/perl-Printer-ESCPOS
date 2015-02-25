use strict;
use warnings;

package Printer::ESCPOS::Connections::Serial;

use 5.010;
use Moose;
use namespace::autoclean;

use Device::SerialPort;

=attr serial_device_path

This variable contains the path for the printer device file when connected as a serial device on UNIX-like systems. I haven't added support for Windows and it probably wont work in doz as a local printer without some modifications. Feel free to try it out and let me know what happens. This must be passed in the constructor

=cut

has serial_device_path => (
  is => 'ro',
  isa => 'Str',
);

=attr baudrate

When used as a local serial device you can set the baudrate of the printer too. Default (38400) will usually work, but not always. 

This param may be specified when creating printer object to make sure it works properly.

$printer = Printer::Thermal->new(serial_device_path => '/dev/ttyACM0', baudrate => 9600);

=cut

has baudrate => (
  is => 'ro',
  isa => 'Int',
  default => 38400,
);

has _connection => (
    is         => 'ro',
    lazy_build => 1,
    init_arg   => undef,
);

sub _build__connection {
    my ($self) = @_;
    my $printer;

    $printer = Device::SerialPort->new( $self->serial_device_path );
    $printer->baudrate( $self->baudrate );

    return $printer;
}

sub write {
    my ($self,$raw) = @_;

    $self->_connection->write($raw);
}

sub read {
    my ($self,$bytes) = @_;
    $bytes |= 1024;

    my $data = $self->_connection->read($bytes);

    return $data;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
