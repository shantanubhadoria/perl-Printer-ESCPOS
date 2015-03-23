use strict;
use warnings;

use 5.010;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Printer::ESCPOS;
use Data::Dumper;

my $printer_file = Printer::ESCPOS->new(
    driverType     => 'File',
    deviceFilePath => '/dev/usb/lp0',
);

$printer_file->printer->init();

$printer_file->printer->barcode(
    barcode     => 'SHANTANU BHADORIA',
);
$printer_file->printer->usePrintMode(0);

$printer_file->printer->printNVImage(0);
$printer_file->printer->drawerKickPulse();

$printer_file->printer->lf();
$printer_file->printer->write("print width nH = 1 & nL = 0 for next line");
$printer_file->printer->printAreaWidth( nL => 0, nH => 1);
$printer_file->printer->write("blah blah blah blah blah blah blah blah blah blah blah");
$printer_file->printer->printAreaWidth(); # Reset to default
$printer_file->printer->write("print are width nL = 200 & nH = 0 for next line");
$printer_file->printer->printAreaWidth( nL => 200, nH => 0);
$printer_file->printer->write("blah blah blah blah blah blah blah blah blah blah blah");
$printer_file->printer->printAreaWidth(); # Reset to default

$printer_file->printer->tab();
$printer_file->printer->write("tab position default\n");
$printer_file->printer->tabPositions(30);
$printer_file->printer->tab();
$printer_file->printer->write("tab position 30\n");
$printer_file->printer->tabPositions(8);
$printer_file->printer->tab();
$printer_file->printer->write("tab position 9\n");
$printer_file->printer->write("Two line feeds next . . ");
$printer_file->printer->lf();
$printer_file->printer->lf();

$printer_file->printer->underline(1);
$printer_file->printer->write("underline on\n");
$printer_file->printer->underline(2);
$printer_file->printer->write("underline with double thickness on\n");
$printer_file->printer->underline(0);

$printer_file->printer->invert(1);
$printer_file->printer->write("Inverted Text\n");
$printer_file->printer->invert(0);

$printer_file->printer->write("char height and width\n");
for my $width ( 0 .. 2 ) {
    for my $height ( 0 .. 2 ) {
        $printer_file->printer->width( $width );
        $printer_file->printer->height( $height );
        $printer_file->printer->write("h:$height w:$width\n");
    }
}
$printer_file->printer->width( 0 );
$printer_file->printer->height( 0 );

$printer_file->printer->emphasized(0);
$printer_file->printer->write("default[font(a) de-emphasized] ");

$printer_file->printer->emphasized(1);
$printer_file->printer->write("Emphasized\n ");
$printer_file->printer->emphasized(0);

$printer_file->printer->doubleStrike(1);
$printer_file->printer->write("Double Strike\n ");
$printer_file->printer->doubleStrike(0);

$printer_file->printer->justification('right');
$printer_file->printer->write("Right Justified");
$printer_file->printer->justification('center');
$printer_file->printer->write("Center Justified");
$printer_file->printer->justification('left');

$printer_file->printer->upsideDown(1);
$printer_file->printer->write("Upside Down");
$printer_file->printer->upsideDown(0);

$printer_file->printer->font("b");
$printer_file->printer->write("font b\n");
$printer_file->printer->font("a");

for (0 .. 3){
    $printer_file->printer->charSpacing($_ * 10);
    $printer_file->printer->write("\nchar spacing " . $_ * 10);
}
$printer_file->printer->charSpacing(0);
$printer_file->printer->lineSpacing(0);
$printer_file->printer->write("\n* BEGIN: line spacing 0\n");
$printer_file->printer->write("line spacing 0\n");
$printer_file->printer->lineSpacing(64);
$printer_file->printer->write("* BEGIN: line spacing 64\n");
$printer_file->printer->write("line spacing 64\n");
$printer_file->printer->lineSpacing(128);
$printer_file->printer->write("* BEGIN: line spacing 128\n");
$printer_file->printer->write("line spacing 128\n");

$printer_file->printer->lineSpacing(200);
$printer_file->printer->write("* BEGIN: line spacing 200\n");
$printer_file->printer->write("line spacing 200\n");
$printer_file->printer->lineSpacing(0);

$printer_file->printer->lf();
$printer_file->printer->lf();
$printer_file->printer->lf();

$printer_file->printer->write("Cut paper without feed");
$printer_file->printer->cutPaper( feed => '0');
$printer_file->printer->write("Cut paper with feed");
$printer_file->printer->cutPaper( feed => '1');
$printer_file->printer->print();

