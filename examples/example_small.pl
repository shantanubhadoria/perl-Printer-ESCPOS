use strict;
use warnings;

use 5.010;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Printer::ESCPOS;
use Data::Dumper;

my $printer_usb = Printer::ESCPOS->new(
    driverType     => 'USB',
    vendorId       => 0x1504,
    productId      => 0x0006,
);

$printer_usb->printer->init();


$printer_usb->printer->barcode(
    barcode     => 'SHANTANU BHADORIA',
);
$printer_usb->printer->usePrintMode(0);

$printer_usb->printer->printNVImage(0);
$printer_usb->printer->drawerKickPulse();

$printer_usb->printer->lf();
$printer_usb->printer->text("print width nH = 1 & nL = 0 for next line");
$printer_usb->printer->printAreaWidth( nL => 0, nH => 1);
$printer_usb->printer->text("blah blah blah blah blah blah blah blah blah blah blah");
$printer_usb->printer->printAreaWidth(); # Reset to default
$printer_usb->printer->text("print are width nL = 200 & nH = 0 for next line");
$printer_usb->printer->printAreaWidth( nL => 200, nH => 0);
$printer_usb->printer->text("blah blah blah blah blah blah blah blah blah blah blah");
$printer_usb->printer->printAreaWidth(); # Reset to default
$printer_usb->printer->cutPaper( feed => '1');
$printer_usb->printer->print();
