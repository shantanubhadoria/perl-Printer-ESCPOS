use strict;
use warnings;

package Printer::ESCPOS::Roles::Connection;

# PODNAME: Printer::ESCPOS::Roles::Connection
# ABSTRACT: Role for Connection Classes for L<Printer::ESCPOS>
# COPYRIGHT
# VERSION

# Dependencies

use 5.010;
use Moo::Role;


has _buffer => (
    is      => 'rw',
    default => '',
);

=method write

Writes prepared data to the module buffer. This data is dispatched to printer with print() method. The print method
takes care of buffer control issues.

=cut

sub write {
    my ($self,$raw) = @_;

    $self->_buffer( $self->_buffer . $raw );
}

=method print

If a string is passed then it passes the string to the printer else passes the buffer data to the printer and clears
the buffer.

    $device->printer->print(); # Prints and clears the Buffer.
    $device->printer->print($raw); # Prints $raw

=cut

sub print {
    my ($self,$raw) = @_;
    my @chunks;

    my $printString;
    if( defined $raw ) {
        $printString = $raw;
    } else {
        $printString = $self->_buffer;
        $self->_buffer('');
    }
    my $n = 64; # Size of each chunk in bytes

    @chunks = unpack "a$n" x ((length($printString)/$n)-1) . "a*", $printString;
    for my $chunk( @chunks ){
        $self->_connection->write($chunk);
    }
}

1;
