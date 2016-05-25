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
$printer_usb->printer->qr("Don't Panic");

$printer_usb->printer->justify("right");
$printer_usb->printer->text('abcdefghifjkl');
$printer_usb->printer->qr("WIFI:T:WPA;S:CoreBPM Guest;P:CoreBPM.2016;;",'L',5,3);
$printer_usb->printer->print();
