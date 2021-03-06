use strict;
use warnings;

package Printer::ESCPOS::Connections::File;

# PODNAME: Printer::ESCPOS::Connections::File
# ABSTRACT: Bare Device File Connection Interface for L<Printer::ESCPOS>
# COPYRIGHT
# VERSION

# Dependencies

use 5.010;
use Moo;
with 'Printer::ESCPOS::Roles::Connection';

use IO::File;

=attr deviceFilePath

This variable contains the path for the printer device file on UNIX-like systems.

=cut

has deviceFilePath => (
  is => 'ro',
);

has _connection => (
    is         => 'lazy',
    init_arg   => undef,
);

sub _build__connection {
    my ($self) = @_;
    my $printer;

    $printer = new IO::File ">>" . $self->deviceFilePath ;

    return $printer;
}

no Moo;
__PACKAGE__->meta->make_immutable;

1;
