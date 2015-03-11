use strict;
use warnings;

package Printer::ESCPOS::Connections::Network;

# PODNAME: Printer::ESCPOS::Connections::Network
# ABSTRACT: Network Connection Interface for Printer::ESCPOS 
# COPYRIGHT
# VERSION

# Dependencies

use 5.010;
use Moose;
with 'Printer::ESCPOS::Roles::Connection';
use namespace::autoclean;

use IO::Socket;

=attr deviceIP

Contains the IP address of the device when its a network printer. The module creates IO:Socket::INET object to connect to the printer. This can be passed in the constructor.

=cut

has deviceIP => (
  is  => 'ro',
  isa => 'Str',
);

=attr devicePort

Contains the network port of the device when its a network printer. The module creates IO:Socket::INET object to connect to the printer. This can be passed in the constructor.

=cut

has devicePort => (
  is      => 'ro',
  isa     => 'Int',
  default => '9100',
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

=method print

Sends buffer data to the printer.

=cut

sub print {
    my ($self,$raw) = @_;
    my @chunks;
    my $buffer = $self->_buffer;
    my $n = 64; # Size of each chunk in bytes

    @chunks = unpack "a$n" x ((length($buffer)/$n)-1) . "a*", $buffer;    
    for my $chunk( @chunks ){
        $self->_connection->write($chunk);
    }
    $self->_buffer('');
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
