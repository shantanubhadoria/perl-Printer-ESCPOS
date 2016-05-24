use strict;
use warnings;

package Printer::ESCPOS::Connections::Network;

# PODNAME: Printer::ESCPOS::Connections::Network
# ABSTRACT: Network Connection Interface for L<Printer::ESCPOS>
# COPYRIGHT
# VERSION

# Dependencies

use 5.010;
use Moo;
with 'Printer::ESCPOS::Roles::Connection';

use IO::Socket;

=attr deviceIP

Contains the IP address of the device when its a network printer. The module creates IO:Socket::INET object to connect
to the printer. This can be passed in the constructor.

=cut

has deviceIP => (
  is  => 'ro',
);

=attr devicePort

Contains the network port of the device when its a network printer. The module creates IO:Socket::INET object to connect
to the printer. This can be passed in the constructor.

=cut

has devicePort => (
  is      => 'ro',
  default => '9100',
);

has _connection => (
    is         => 'lazy',
    init_arg   => undef,
);

sub _build__connection {
    my ($self) = @_;
    my $printer;

    $printer = IO::Socket::INET->new(
        Proto     => "tcp",
        PeerAddr  => $self->deviceIP,
        PeerPort  => $self->devicePort,
        Timeout   => 1,
    ) or die " Can't connect to printer";

    return $printer;
}

=method read

Read Data from the printer

=cut

sub read {
    my ($self, $question, $bytes) = @_;
    my $data;
    $bytes ||= 2;

    say unpack("H*",$question);
    $self->_connection->write( $question );
    $self->_connection->read($data, $bytes);

    return $data;
}

no Moo;
__PACKAGE__->meta->make_immutable;

1;
