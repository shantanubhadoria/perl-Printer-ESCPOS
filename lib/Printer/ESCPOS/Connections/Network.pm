use strict;
use warnings;

package Printer::ESCPOS::Connections::Network;

use 5.010;
use Moose;
use namespace::autoclean;

use IO::Socket;

=attr device_ip

Contains the IP address of the device when its a network printer. The module creates IO:Socket::INET object to connect to the printer. This can be passed in the constructor.

=cut

has device_ip => (
  is => 'ro',
  isa => 'Str',
);

=attr device_port

Contains the network port of the device when its a network printer. The module creates IO:Socket::INET object to connect to the printer. This can be passed in the constructor.

=cut

has device_port => (
  is => 'ro',
  isa => 'Int',
);

has _connection => (
    is         => 'ro',
    lazy_build => 1,
    init_arg   => undef,
);

sub _build__connection {
    my ($self) = @_;
    my $printer;

    $printer = IO::Socket::INET->new(
        Proto     => "tcp",
        PeerAddr  => $self->device_ip,
        PeerPort  => $self->device_port,
        Timeout   => 1,
    ) or die " Can't connect to printer";

    return $printer;
}

sub write {
    my ($self,$raw) = @_;

    $self->_connection->write($raw);
}

sub read {
    my ($self,$bytes) = @_;
    my $data;
    $bytes |= 1024;

    $self->_connection->read($data, $bytes);

    return $data;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
