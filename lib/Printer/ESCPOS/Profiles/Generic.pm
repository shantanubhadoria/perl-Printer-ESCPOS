use strict;
use warnings;

package Printer::ESCPOS::Profiles::Generic;

# PODNAME: Printer::ESCPOS::Profiles::Generic
# ABSTRACT: Generic Profile for Printers for L<Printer::ESCPOS>. Most common functions are included here.
#
# This file is part of Printer-ESCPOS
#
# This software is copyright (c) 2016 by Shantanu Bhadoria.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
our $VERSION = '1.001'; # VERSION

# Dependencies
use 5.010;
use Moo;
with 'Printer::ESCPOS::Roles::Profile';
use Carp;
use Scalar::Util::Numeric qw(isint);
use GD::Barcode::QRcode;

use constant {
    _ESC => "\x1b",
    _GS  => "\x1d",
    _DLE => "\x10",
    _FS  => "\x1c",

    # Level 2 Constants
    _FF  => "\x0c",
    _SP  => "\x20",
    _EOT => "\x04",
    _DC4 => "\x14",
};


sub init {
    my ($self) = @_;

    $self->driver->print( _ESC . '@' );
}


sub leftMargin {
    my ( $self, $leftMargin ) = @_;

    confess
"Invalid value for leftMargin '$leftMargin'. Use a integer between '0' and '255'.
        Usage: \n\t\$device->printer->leftMargin(30)\n"
      unless ( isint $leftMargin >= 0 and $leftMargin <= 255 );

    my $nH = $leftMargin >> 8;
    my $nL = $leftMargin - ( $nH << 8 );

    $self->driver->write( _GS . 'L' . chr($nL) . chr($nH) );
}


sub rot90 {
    my ( $self, $rotate ) = @_;

    confess "Invalid value for rot90 '$rotate'. Use '0' or '1'.
        Usage: \n\t\$device->printer->rot90(1)\n"
      unless ( $rotate == 1 or $rotate == 0 );

    $self->driver->write( _ESC . 'V' . chr($rotate) );
}

# This is a redundant function in ESCPOS which updates the printer
sub _updatePrintMode {
    my ($self) = @_;
    my %fontMap = (
        a => 0,
        b => 1,
    );

    my $value =
        $fontMap{ $self->fontStyle } . '00'
      . $self->emphasizedStatus
      . ( $self->heightStatus ? '1' : '0' )
      . ( $self->widthStatus  ? '1' : '0' ) . '0'
      . $self->underlineStatus;
    $self->driver->write( _ESC . '!' . pack( "b*", $value ) );
}

# BEGIN: BARCODE functions


sub barcode {
    my ( $self, %params ) = @_;

    my %map = (
        none          => 0,
        above         => 1,
        below         => 2,
        aboveandbelow => 3,
    );

    $self->driver->write(
        _GS . 'H' . chr( $map{ $params{HRIPosition} || 'below' } ) );

    %map = (
        a => 0,
        b => 1,
    );
    $self->driver->write( _GS . 'f' . chr( $map{ $params{font} || 'b' } ) );

    $self->driver->write( _GS . 'h' . chr( $params{height} || 50 ) );

    $self->driver->write( _GS . 'w' . chr( $params{width} || 2 ) );

    %map = (
        'UPC-A' => 0,
        'UPC-B' => 1,
        JAN13   => 2,
        JAN8    => 3,
        CODE39  => 4,
        ITF     => 5,
        CODABAR => 6,
        CODE93  => 7,
        CODE128 => 8,
    );
    $params{system} ||= 'CODE93';

    if ( exists $map{ $params{system} } ) {
        $self->driver->write( _GS . 'k'
              . chr( $map{ $params{system} } + 65 )
              . chr( length $params{barcode} )
              . $params{barcode} );
    }
    else {
        confess "Invalid system in barcode";
    }
}

# END: BARCODE functions

# BEGIN: Bitmap printing methods


sub printNVImage {
    my ( $self, $flag ) = @_;

    $self->driver->write( _FS . 'p' . chr(1) . chr($flag) );
}


sub printImage {
    my ( $self, $flag ) = @_;

    $self->driver->write( _GS . '/' . chr($flag) );
}

# END: Bitmap printing methods

# BEGIN: Peripheral and cutter Control Commands


sub cutPaper {
    my ( $self, %params ) = @_;
    $params{feed} ||= 0;

    $self->lf();
    if ( $params{feed} == 0 ) {
        $self->driver->write( _GS . 'V' . chr(1) );
    }
    else {
        $self->driver->write( _GS . 'V' . chr(66) . chr(0) );
    }

}


sub drawerKickPulse {
    my ( $self, $pin, $time ) = @_;
    $pin  = defined $pin  ? $pin  : 0;
    $time = defined $time ? $time : 8;

    $self->driver->write( _DLE . _DC4 . "\x01" . chr($pin) . chr($time) );
}

# End Peripheral Control Commands

# BEGIN: Printer STATUS methods


sub printerStatus {
    my ($self) = @_;

    my @flags =
      split( //,
        unpack( "B*", $self->driver->read( _DLE . _EOT . "\x01", 255 ) ) );
    return {
        drawer_pin3_high            => $flags[5],
        offline                     => $flags[4],
        waiting_for_online_recovery => $flags[2],
        feed_button_pressed         => $flags[1],
    };
}


sub offlineStatus {
    my ($self) = @_;

    my @flags =
      split( //,
        unpack( "B*", $self->driver->read( _DLE . _EOT . "\x02", 255 ) ) );
    return {
        cover_is_closed     => $flags[5],
        feed_button_pressed => $flags[4],
        paper_end           => $flags[2],
        error               => $flags[1],
    };
}


sub errorStatus {
    my ($self) = @_;

    my @flags =
      split( //,
        unpack( "B*", $self->driver->read( _DLE . _EOT . "\x03", 255 ) ) );
    return {
        auto_cutter_error     => $flags[4],
        unrecoverable_error   => $flags[2],
        autorecoverable_error => $flags[1],
    };
}


sub paperSensorStatus {
    my ($self) = @_;

    my @flags =
      split( //,
        unpack( "B*", $self->driver->read( _DLE . _EOT . "\x04", 255 ) ) );
    return {
        paper_roll_near_end_sensor_1 => $flags[5],
        paper_roll_near_end_sensor_2 => $flags[4],
        paper_roll_status_sensor_1   => $flags[2],
        paper_roll_status_sensor_2   => $flags[1],
    };
}


sub inkStatusA {
    my ($self) = @_;

    my @flags = split(
        //,
        unpack(
            "B*", $self->driver->read( _DLE . _EOT . "\x07" . "\x01", 255 )
        )
    );
    return {
        ink_near_end          => $flags[5],
        ink_end               => $flags[4],
        ink_cartridge_missing => $flags[2],
        cleaning_in_progress  => $flags[1],
    };
}


sub inkStatusB {
    my ($self) = @_;

    my @flags = split(
        //,
        unpack(
            "B*", $self->driver->read( _DLE . _EOT . "\x07" . "\x02", 255 )
        )
    );
    return {
        ink_near_end          => $flags[5],
        ink_end               => $flags[4],
        ink_cartridge_missing => $flags[2],
    };
}

# END: Printer STATUS methods

no Moo;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Printer::ESCPOS::Profiles::Generic - Generic Profile for Printers for L<Printer::ESCPOS>. Most common functions are included here.

=head1 VERSION

version 1.001

=head1 METHODS

=head2 init

Initializes the Printer. Clears the data in print buffer and resets the printer to the mode that was in effect when the
power was turned on. This function is automatically called on creation of printer object.

=head2 leftMargin

Sets the left margin for printing. Set the left margin at the beginning of a line. The printer ignores any data
preceding this command on the same line in the buffer.

In page mode sets the left margin to leftMargin x (horizontal motion unit) from the left edge of the printable area

I<leftMargin>: Left Margin, range: B<0> to B<65535>. If the margin exceeds the printable area, the left margin is
automatically set to the maximum value of the printable area.

    $device->printer->leftMargin($leftMargin);

Note: If you are using Printer::ESCPOS version prior to v1.* Please check documentation for older version of this module
the nL and nH syntax for this method.

=head2 rot90

Rotate printout by 90 degrees

I<rotate> (optional, default 0): B<0> or B<1>

    $device->printer->rot90(1);
    $device->printer->text("This is rotated 90 degrees\n");
    $device->printer->rot90(0);
    $device->printer->text("This is not rotated 90 degrees\n");

=head2 barcode

This method prints a barcode to the printer. This can be bundled with other text formatting commands at the appropriate
point where you would like to print a barcode on your print out. takes argument ~barcode~ as the barcode value.

In the simplest form you can use this command as follows:

    #Default barcode printed in code93 system with a width of 2 and HRI Chars printed below the barcode
    $device->printer->barcode(
        barcode     => 'SHANTANU BHADORIA',
    );

However there are several customizations available including barcode ~system~, ~font~, ~height~ etc.

    my $hripos = 'above';
    my $font   = 'a';
    my $height = 100;
    my $system = 'UPC-A';
    $device->printer->barcode(
        HRIPosition => $hripos,        # Position of Human Readable characters
                                       # 'none','above','below','aboveandbelow'
        font        => $font,          # Font for HRI characters. 'a' or 'b'
        height      => $height,        # no of dots in vertical direction
        system      => $system,        # Barcode system
        width       => 2               # 2:0.25mm, 3:0.375mm, 4:0.5mm, 5:0.625mm, 6:0.75mm
        barcode     => '123456789012', # Check barcode system you are using for allowed
                                       # characters in barcode
    );
    $device->printer->barcode(
        system      => 'CODE39',
        HRIPosition => 'above',
        barcode     => '*1-I.I/ $IA*',
    );
    $device->printer->barcode(
        system      => 'CODE93',
        HRIPosition => 'above',
        barcode     => 'Shan',
    );

I<HRIPosition> (optional, default 'below'): 'none', 'above', 'below', 'aboveandbelow'

I<font> (optional, default 'b'): 'a' or 'b'

I<height> (optional, default 50): height integer between 0 and 255

I<width> (optional, default 50): width integer between 0 and 255

I<system> (optional, default 'CODE93'): B<UPC-A>, B<UPC-B>, B<JAN13>, B<JAN8>, B<CODE39>, B<ITF>, B<CODABAR>, B<CODE93>,
B<CODE128>

I<barcode>: String to print as barcode.

=head2 printNVImage

Prints bit image stored in Non-Volatile (NV) memory of the printer.

    $device->printer->printNVImage($flag);

I<flag>: height and width

* $flag = 0 # Normal width and Normal Height
* $flag = 1 # Double width and Normal Height
* $flag = 2 # Normal width and Double Height
* $flag = 3 # Double width and Double Height

=head2 printImage

Prints bit image stored in Volatile memory of the printer. This image gets erased when printer is reset.

    $device->printer->printImage($flag);

* $flag = 0 # Normal width and Normal Height
* $flag = 1 # Double width and Normal Height
* $flag = 2 # Normal width and Double Height
* $flag = 3 # Double width and Double Height

=head2 cutPaper

Cuts the paper,

I<feed> (optional, default 0): if ~feed~ is set to B<0> then printer doesnt feed paper to cutting position before
cutting it. The default behavior is that the printer doesn't feed paper to cutting position before cutting. One
pre-requisite line feed is automatically executed before paper cut though.

    $device->printer->cutPaper( feed => 0 )

While not strictly a text formatting option, in receipt printer the cut paper instruction is sent along with the rest of
the text and text formatting data and the printer cuts the paper at the appropriate points wherever this command is
used.

=head2 drawerKickPulse

Trigger drawer kick. Used to open cash drawer connected to the printer. In some use cases it may be used to trigger
other devices by close contact.

    $device->printer->drawerKickPulse( $pin, $time );

I<pin> (optional, default 0): $pin is either 0( for pin 2 ) and 1( for pin5 )

I<pin> (optional, default 8): $time is a value between 1 to 8 and the pulse duration in multiples of 100ms.

For default values use without any params to kick drawer pin 2 with a 800ms pulse

    $device->printer->drawerKickPulse();

Again like cutPaper command this is obviously not a text formatting command but this command is sent along with the rest
of the text and text formatting data and the printer sends the pulse at the appropriate points wherever this command is
used. While originally designed for triggering a cash drawer to open, in practice this port can be used for all sorts of
devices like pulsing light, or sound alarm etc.

=head2 printerStatus

Returns printer status in a hashref.

    return {
        drawer_pin3_high            => $flags[5],
        offline                     => $flags[4],
        waiting_for_online_recovery => $flags[2],
        feed_button_pressed         => $flags[1],
    };

=head2 offlineStatus

Returns a hashref for paper cover closed status, feed button pressed status, paper end stop status, and a aggregate
error status either of which will prevent the printer from processing a printing request.

    return {
        cover_is_closed     => $flags[5],
        feed_button_pressed => $flags[4],
        paper_end           => $flags[2],
        error               => $flags[1],
    };

=head2 errorStatus

Returns hashref with error flags for auto_cutter_error, unrecoverable error and auto-recoverable error

    return {
        auto_cutter_error     => $flags[4],
        unrecoverable_error   => $flags[2],
        autorecoverable_error => $flags[1],
    };

=head2 paperSensorStatus

Gets printer paper Sensor status. Returns a hashref with four sensor statuses. Two paper near end sensors and two paper
end sensors for printers supporting this feature. The exact returned status might differ based on the make of your
printer. If any of the flags is set to 1 it implies that the paper is out or near end.

    return {
        paper_roll_near_end_sensor_1 => $flags[5],
        paper_roll_near_end_sensor_2 => $flags[4],
        paper_roll_status_sensor_1 => $flags[2],
        paper_roll_status_sensor_2 => $flags[1],
    };

=head2 inkStatusA

Only available for dot-matrix and other ink consuming printers. Gets printer ink status for inkA(usually black ink).
Returns a hashref with ink statuses.

    return {
        ink_near_end          => $flags[5],
        ink_end               => $flags[4],
        ink_cartridge_missing => $flags[2],
        cleaning_in_progress  => $flags[1],
    };

=head2 inkStatusB

Only available for dot-matrix and other ink consuming printers. Gets printer ink status for inkB(usually red ink).
Returns a hashref with ink statuses.

    return {
        ink_near_end          => $flags[5],
        ink_end               => $flags[4],
        ink_cartridge_missing => $flags[2],
    };

=head1 AUTHOR

Shantanu Bhadoria <shantanu@cpan.org> L<https://www.shantanubhadoria.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Shantanu Bhadoria.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
