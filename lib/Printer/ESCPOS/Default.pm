use strict;
use warnings;

package Printer::ESCPOS::Default;

# PODNAME: Printer::ESCPOS::Default
# ABSTRACT: Default Profile for Printers for Printer::ESCPOS. Most common functions are included here.
# COPYRIGHT
# VERSION

# Dependencies
use 5.010;
use Moose;
use namespace::autoclean;

use Printer::Thermal::Constants;

has init => (
    is => 'Str',
    default => ESC . '@'
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
