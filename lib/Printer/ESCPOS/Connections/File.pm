use strict;
use warnings;

package Printer::ESCPOS::Connections::File;

# PODNAME: Printer::ESCPOS::Connections::File
# ABSTRACT: Bare Device File Connection Interface for Printer::ESCPOS 
# COPYRIGHT
# VERSION

# Dependencies

use 5.010;
use Moose;
with 'Printer::ESCPOS::Roles::Connection';
use namespace::autoclean;

use IO::File;

=attr deviceFilePath

This variable contains the path for the printer device file on UNIX-like systems. I haven't added support for Windows and it probably wont work in doz as a local printer without some modifications. Feel free to try it out and let me know what happens. This must be passed in the constructor

=cut

has deviceFilePath => (
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

    $printer = new IO::File ">>" . $self->deviceFilePath ;

    return $printer;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
