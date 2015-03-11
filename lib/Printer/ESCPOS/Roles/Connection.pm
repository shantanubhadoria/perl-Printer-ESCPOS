use strict;
use warnings;

package Printer::ESCPOS::Roles::Connection;

# PODNAME: Printer::ESCPOS::Roles::Connection
# ABSTRACT: Role for Connection Classes for Printer::ESCPOS
# COPYRIGHT
# VERSION

# Dependencies

use 5.010;
use Moose::Role;


has _buffer => (
    is      => 'rw',
    default => '',
);

=method write

Writes prepared data to the module buffer. This data is dispatched to printer with print() method. The print method takes care of buffer control issues.

=cut

sub write {
    my ($self,$raw) = @_;

    $self->_buffer( $self->_buffer . $raw );
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

1;
