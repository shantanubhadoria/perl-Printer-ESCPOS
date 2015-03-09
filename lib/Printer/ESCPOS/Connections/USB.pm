use strict;
use warnings;

package Printer::ESCPOS::Connections::USB;

# PODNAME: Printer::ESCPOS::Connections::USB
# ABSTRACT: USB Connection Interface for Printer::ESCPOS 
# COPYRIGHT
# VERSION

# Dependencies

use 5.010;
use Moose;
with 'Printer::ESCPOS::Roles::Connection';

use Device::USB;

=attr vendorId

=cut

has vendorId => (
    is         => 'ro',
    required => 1,
);

=attr productId

=cut

has productId => (
    is         => 'ro',
    required => 1,
);

has _connection => (
    is         => 'ro',
    lazy_build => 1,
    init_arg   => undef,
);

sub _build__connection {
    my ($self) = @_;

    my $usb = Device::USB->new();
    my $device = $usb->find_device( $self->vendorId, $self->productId );

    return $device;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
