use strict;
use warnings;

use 5.010;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Printer::ESCPOS;
use Data::Dumper;

my $printer_serial = Printer::ESCPOS->new(
    driverType     => 'Serial',
    deviceFilePath => '/dev/ttyACM0',
);

$printer_serial->printer->init();

say Dumper $printer_serial->printer->printerStatus();
say Dumper $printer_serial->printer->offlineStatus();
say Dumper $printer_serial->printer->errorStatus();
say Dumper $printer_serial->printer->paperSensorStatus();

$printer_serial->printer->barcode(
    barcode     => 'SHANTANU BHADORIA',
);
$printer_serial->printer->usePrintMode(0);

$printer_serial->printer->printNVImage(0);
$printer_serial->printer->drawerKickPulse();

$printer_serial->printer->lf();
$printer_serial->printer->write("print width nH = 1 & nL = 0 for next line");
$printer_serial->printer->printAreaWidth( nL => 0, nH => 1);
$printer_serial->printer->write("blah blah blah blah blah blah blah blah blah blah blah");
$printer_serial->printer->printAreaWidth(); # Reset to default
$printer_serial->printer->write("print are width nL = 200 & nH = 0 for next line");
$printer_serial->printer->printAreaWidth( nL => 200, nH => 0);
$printer_serial->printer->write("blah blah blah blah blah blah blah blah blah blah blah");
$printer_serial->printer->printAreaWidth(); # Reset to default

$printer_serial->printer->lf();
$printer_serial->printer->leftMargin( nL => 0, nH => 1);
$printer_serial->printer->write("Left Margin nL => 0 nH => 1\n");
$printer_serial->printer->leftMargin( nL => 0, nH => 0);

$printer_serial->printer->tab();
$printer_serial->printer->write("tab position default\n");
$printer_serial->printer->tabPositions(30);
$printer_serial->printer->tab();
$printer_serial->printer->write("tab position 30\n");
$printer_serial->printer->tabPositions(8);
$printer_serial->printer->tab();
$printer_serial->printer->write("tab position 9\n");
$printer_serial->printer->write("Two line feeds next . . ");
$printer_serial->printer->lf();
$printer_serial->printer->lf();

$printer_serial->printer->underline(1);
$printer_serial->printer->write("underline on\n");
$printer_serial->printer->underline(2);
$printer_serial->printer->write("underline with double thickness on\n");
$printer_serial->printer->underline(0);

$printer_serial->printer->invert(1);
$printer_serial->printer->write("Inverted Text\n");
$printer_serial->printer->invert(0);

$printer_serial->printer->write("char height and width\n");
for my $width ( 0 .. 2 ) {
    for my $height ( 0 .. 2 ) {
        $printer_serial->printer->width( $width );
        $printer_serial->printer->height( $height );
        $printer_serial->printer->write("h:$height w:$width\n");
    }
}
$printer_serial->printer->width( 0 );
$printer_serial->printer->height( 0 );

$printer_serial->printer->emphasized(0);
$printer_serial->printer->write("default[font(a) de-emphasized] ");

$printer_serial->printer->emphasized(1);
$printer_serial->printer->write("Emphasized\n ");
$printer_serial->printer->emphasized(0);

$printer_serial->printer->doubleStrike(1);
$printer_serial->printer->write("Double Strike\n ");
$printer_serial->printer->doubleStrike(0);

$printer_serial->printer->justification('right');
$printer_serial->printer->write("Right Justified");
$printer_serial->printer->justification('center');
$printer_serial->printer->write("Center Justified");
$printer_serial->printer->justification('left');

$printer_serial->printer->upsideDown(1);
$printer_serial->printer->write("Upside Down");
$printer_serial->printer->upsideDown(0);

$printer_serial->printer->font("b");
$printer_serial->printer->write("font b\n");
$printer_serial->printer->font("a");

for (0 .. 3){
    $printer_serial->printer->charSpacing($_ * 10);
    $printer_serial->printer->write("\nchar spacing " . $_ * 10);
}
$printer_serial->printer->charSpacing(0);
$printer_serial->printer->lineSpacing(0);
$printer_serial->printer->write("\n* BEGIN: line spacing 0\n");
$printer_serial->printer->write("line spacing 0\n");
$printer_serial->printer->lineSpacing(64);
$printer_serial->printer->write("* BEGIN: line spacing 64\n");
$printer_serial->printer->write("line spacing 64\n");
$printer_serial->printer->lineSpacing(128);
$printer_serial->printer->write("* BEGIN: line spacing 128\n");
$printer_serial->printer->write("line spacing 128\n");

$printer_serial->printer->lineSpacing(200);
$printer_serial->printer->write("* BEGIN: line spacing 200\n");
$printer_serial->printer->write("line spacing 200\n");
$printer_serial->printer->lineSpacing(0);

$printer_serial->printer->lf();
$printer_serial->printer->lf();
$printer_serial->printer->lf();

$printer_serial->printer->write("Cut paper without feed");
$printer_serial->printer->cutPaper( feed => '0');
$printer_serial->printer->write("Cut paper with feed");
$printer_serial->printer->cutPaper( feed => '1');
$printer_serial->printer->print();

