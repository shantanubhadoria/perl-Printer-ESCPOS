package Printer::ESCPOS::Roles::Connection;

use 5.010;
use Moose::Role;


has buffer => (
    is      => 'rw',
    default => '',
);

sub write {
    my ($self,$raw) = @_;

    $self->buffer( $self->buffer . $raw );
}

sub print {
    my ($self,$raw) = @_;
    my @chunks;
    my $buffer = $self->buffer;
    my $n = 64; # Size of each chunk in bytes

    @chunks = unpack "a$n" x ((length($buffer)/$n)-1) . "a*", $buffer;    
    for my $chunk( @chunks ){
        $self->_connection->write($chunk);
        $self->_connection->read();
    }
    $self->buffer('');
}

1;
