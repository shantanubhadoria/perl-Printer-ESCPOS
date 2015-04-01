use strict;
use warnings;

package Printer::ESCPOS::Profiles::SinocanPSeries;

# PODNAME: Printer::ESCPOS::Profiles::SinocanPSeries
# ABSTRACT: Sinocan P Series Profile for Printers for L<Printer::ESCPOS>.
# COPYRIGHT
# VERSION

# Dependencies
use 5.010;
use Moo;
extends 'Printer::ESCPOS::Profiles::Generic';
with 'Printer::ESCPOS::Roles::Profile';
use namespace::autoclean;

no Moo;
__PACKAGE__->meta->make_immutable;

1;
