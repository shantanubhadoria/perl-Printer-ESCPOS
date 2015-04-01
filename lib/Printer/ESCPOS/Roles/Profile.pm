use strict;
use warnings;

package Printer::ESCPOS::Roles::Profile;

# PODNAME: Printer::ESCPOS::Roles::Profile
# ABSTRACT: Role for all Printer Profiles for L<Printer::ESCPOS> 
# COPYRIGHT
# VERSION

# Dependencies
use 5.010;
use Moo::Role;
requires 'init';

=attr driver

Stores the connection object from the Printer::ESCPOS::Connections::*. In any normal use case you must not modify this attribute.

=cut

has driver => (
    is      => 'rw',
    required => 1,
);

=attr usePrintMode

Use Print mode to set font, underline, double width, double height and emphasized if false uses the individual command ESC M n for font "c" ESC M is forced irrespective of this flag

=cut

has usePrintMode => (
  is      => 'rw',
  default => '0',
);

=attr fontStyle

Set ESC-POS Font pass "a" "b" or "c". Note "c" is not supported across all printers.

=cut

has fontStyle => (
  is      => 'rw',
  default => 'a',
);

=attr emphasizedStatus

Set/unset emphasized property

=cut

has emphasizedStatus => (
  is      => 'rw',
  default => 0,
);

=attr heightStatus

set unset double height property

=cut

has heightStatus => (
  is      => 'rw',
  default => 0,
);

=attr widthStatus

set unset double width property

=cut

has widthStatus => (
  is      => 'rw',
  default => 0,
);

=attr underlineStatus

Set/unset underline property

=cut

has underlineStatus => (
  is      => 'rw',
  default => 0,
);

=method text 

Sends raw text to the local buffer ready for sending this to the printer. This would contain a set of strings to print or ESCPOS Codes.

    $device->printer->text("Hello World\n");

=cut

sub text {
    my ( $self, $text ) = @_;
    $self->driver->write( $text );
}

=method print 

prints data in the buffer

=cut

sub print {
    my ( $self, $text ) = @_;
    $self->driver->print( $text );
}

=method read

Reads n bytes from the printer. This function is used internally to get printer statuses when supported.

=cut

sub read {
    my ( $self, $bytes ) = @_;
    if( $self->driver->can( 'read' ) ) {
        return $self->driver->read( $bytes );
    } else {
        die "read is not supported by the Printer Driver in use use a different driverType $!";
    }
}

1;
