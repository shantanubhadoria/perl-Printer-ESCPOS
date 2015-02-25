use strict;
use warnings;

package Printer::ESCPOS::Connections::File;

use 5.010;
use Moose;
use namespace::autoclean;

use IO::File;

=attr device_path

This variable contains the path for the printer device file on UNIX-like systems. I haven't added support for Windows and it probably wont work in doz as a local printer without some modifications. Feel free to try it out and let me know what happens. This must be passed in the constructor

=cut

has device_path => (
  is => 'ro',
  isa => 'Str',
);

has _connection => (
    is         => 'ro',
    lazy_build => 1,
    init_arg   => undef,
);

sub _build__connection {
    my ($self) = @_;
    my $printer;

    $printer = new IO::File ">>" . $self->device_path ;

    return $printer;
}

sub write {
    my ($self,$raw) = @_;

    $self->_connection->write($raw);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
