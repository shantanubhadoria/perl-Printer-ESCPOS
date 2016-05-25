use strict;
use warnings;

use 5.010;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Printer::ESCPOS;
use GD;
use Data::Dumper;

my $printer_usb = Printer::ESCPOS->new(
    driverType => 'USB',
    vendorId   => 0x1504,
    productId  => 0x0006,
    endPoint   => 0x01
);
#$printer_usb->printer->qr("Don't Panic");

# $printer_usb->printer->justify("left");
# $printer_usb->printer->qr("WIFI:T:WPA;S:CoreBPM Guest;P:CoreBPM.2016;;",'L',4,0);
$printer_usb->printer->font('a');
$printer_usb->printer->text("adadsad asd sad asd \n");
$printer_usb->printer->font('b');
$printer_usb->printer->text("bdadsad asd sad asd \n");


=head2

my $ESC = "\x1b";
my $GS = "\x1D";
$printer_usb->printer->justify("left");
$printer_usb->printer->text("abcdefghifjkl\n");
$printer_usb->printer->lineSpacing(0);
$printer_usb->printer->text("abcdefghifjkl\n");
$printer_usb->printer->text($ESC . "*" . chr(0) . chr(255) . chr(3));
for (1 .. 1023) {
  # $printer_usb->printer->text(chr(oct("0b10101010")));
  $printer_usb->printer->text(chr(oct("0b10101000")));
}
$printer_usb->printer->text("abcdefghifjkl\n");
$printer_usb->printer->text("abcdefghifjkl\n");
$printer_usb->printer->lf();

=cut
$printer_usb->printer->print();
