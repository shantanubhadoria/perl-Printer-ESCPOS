use strict;
use warnings;

package Printer::ESCPOS::Manual;

# PODNAME: Printer::ESCPOS::Manual
# ABSTRACT: Manual for Printing POS Receipts using L<Printer::ESCPOS>
# COPYRIGHT
# VERSION

1;

__END__

=begin wikidoc

= SYNOPSIS 

== BASIC USAGE

    use Printer::ESCPOS;

    # Create a Printer object, Initialize the printer.
    my $device = Printer::ESCPOS->new(
        driverType     => 'Serial'
        deviceFilePath => '/dev/ttyACM0'
    );

    # All Printers have their own initialization 
    # recommendations(Cleaning buffers etc.). Run 
    # this command to let the module do this for you.
    $device->printer->init();


    # Prepare some data to send to the printer using
    # formatting and text commands
    $device->printer->bold(1);
    $device->printer->text("Heading text\n");
    $device->printer->bold(0);
    $device->printer->text("Content here\n");
    $device->printer->text(". . .\n");


    # Add a cut paper command at the end to cut the receipt
    # This command will be ignored by your printer if it 
    # doesn't have a paper cutter on it 
    $device->printer->cutPaper(); 

    
    # Send the Prepared data to the printer.
    $device->printer->print();

= PRINTING TO YOUR PRINTER IN THREE STEPS

[Printer::ESCPOS] uses a three step mechanism for sending the data to the Printer i.e initialization, preparation of data to send to the printer, and finally sending the prepared data to the printer. Separation of preparation and printing steps allows [Printer::ESCPOS] to deal with communication speed and buffer limitations found in most common ESCPOS printers.

== INITIALIZATION

=== SERIAL PRINTER

The Mandatory parameters for a *Serial* ~driverType~ are ~driverType~( *Serial* ) and ~deviceFilePath~
This is the preferred ~driverType~ for connecting to a printer. This connection type is valid for printers connected over serial ports or for printers connected on physical USB ports but showing up as *Serial* devices(check syslog when you connect the printer). Note that not all printers show up as Serial devices when connected on USB port.

    my $device = Printer::ESCPOS->new(
        driverType     => 'Serial',
        deviceFilePath => '/dev/ttyACM0',
    );

Optional parameters:

the driver uses 38400 as default baudrate. If necessary you can change this value by providing a ~baudrate~ parameter.

    my $device = Printer::ESCPOS->new(
        driverType     => 'Serial',
        deviceFilePath => '/dev/ttyACM0',
        baudrate       => 9600,
    );

If your printer is not printing properly when connected on physical serial port try setting the flag ~serialOverUSB~ to *0* to tell [Printer::ESCPOS] to use special buffer management optimizations for physical serial ports

    my $device = Printer::ESCPOS->new(
        driverType     => 'Serial',
        deviceFilePath => '/dev/ttyACM0',
        baudrate       => 9600,
        serialOverUSB  => 0 
    );

=== NETWORK PRINTER

The Mandatory parameters for a *Network* ~driverType~ are ~driverType~( *Network* ), ~deviceIP~ and ~devicePort~
This is a ~driverType~ for printers connected over a network.

    my $device = Printer::ESCPOS->new(
        driverType => 'Network',
        deviceIP   => '10.0.13.108',
        devicePort => '9100',
    );


=== BASIC DEVICE FILE Driver

The Mandatory parameters for a *File* ~driverType~ are ~driverType~( *File* ) and ~deviceFilePath~
This Driver is included for those instances when your printing needs are simple(You don't want to check the printer for printer status etc. and are only interested in pushing data to the printer for printing) and *Serial* driver type is just refusing to work altogether. In this ~driverType~ the data is written directly to the printer device file and from there sent to the printer. This is the basic text method for ESCPOS printers and it almost always works but it doesn't allow you to read Printer Status which might not be a deal breaker for most people. This ~driverType~ can also be used for Printers which connect on USB ports but don't show up as Serial devices in syslog

    my $device = Printer::ESCPOS->new(
        driverType     => 'File',
        deviceFilePath => '/dev/usb/lp0',
    );

== PREPARING FORMATTED TEXT FOR PRINTER

In all the methods described below its assumed that variable {$device} has been initialized using the appropriate connection to the printer with one of the driverTypes mentioned above.
The following methods prepare the text and text formatting data to be sent to the printer.

=== text

Sends raw text to the printer.

    $device->printer->text("Hello Printer::ESCPOS\n")

=== printAreaWidth

Sets the Print area width specified by ~nL~ and ~NH~. The width is calculated as 
    ( nL + nH * 256 ) * horiz_motion_unit 
    
A pre-requisite line feed is automatically executed before printAreaWidth method.

    $device->printer->printAreaWidth( nL => 0, nH =>0 );

=== tabPositions

Sets horizontal tab positions for tab stops. Upto 32 tab positions can be set in most receipt printers.

    $device->printer->tabPositions( 5, 9, 13 );

* Default tab positions are usually in intervals of 8 chars (9, 17, 25) etc.

=== tab 

moves the cursor to next horizontal tab position like a {"\t"}. This command is ignored unless the next horizontal tab position has been set. You may substitute this command with a {"\t"} as well.

This

    $device->printer->text("blah blah");
    $device->printer->tab();
    $device->printer->text("blah2 blah2");

is same as this

    $device->printer->text("blah blah\tblah2 blah2");

=== lf

line feed. Moves to the next line. You can substitute this method with {"\n"} in your print or text method e.g. :

This

    $device->printer->text("blah blah");
    $device->printer->lf();
    $device->printer->text("blah2 blah2");

is same as this

    $device->printer->text("blah blah\nblah2 blah2");

=== font

Set Font style, you can pass *a*, *b* or *c*. Many printers don't support style *c* and only have two supported styles.

    $device->printer->font('a');
    $device->printer->text('Writing in Font A');
    $device->printer->font('b');
    $device->printer->text('Writing in Font B');

=== bold 

Set bold mode *0* for off and *1* for on. Also called emphasized mode in some printer manuals 

    $device->printer->bold(1);
    $device->printer->text("This is Bold Text\n");
    $device->printer->bold(0);
    $device->printer->text("This is not Bold Text\n");

=== doubleStrike 

Set double-strike mode *0* for off and *1* for on

    $device->printer->doubleStrike(1);
    $device->printer->text("This is Double Striked Text\n");
    $device->printer->doubleStrike(0);
    $device->printer->text("This is not Double Striked  Text\n");

=== underline

set underline, *0* for off, *1* for on and *2* for double thickness 

    $device->printer->underline(1);
    $device->printer->text("This is Underlined Text\n");
    $device->printer->underline(2);
    $device->printer->text("This is Underlined Text with thicker underline\n");
    $device->printer->underline(0);
    $device->printer->text("This is not Underlined Text\n");

=== invert

Reverse white/black printing mode pass *0* for off and *1* for on

    $device->printer->invert(1);
    $device->printer->text("This is Inverted Text\n");
    $device->printer->invert(0);
    $device->printer->text("This is not Inverted Text\n");

=== color

Most thermal printers support just one color, black. Some ESCPOS printers(especially dot matrix) also support a second color, usually red. In many models, this only works when the color is set at the beginning of a new line before any text is printed. Pass *0* or *1* to switch between the two colors.

    $device->printer->lf();
    $device->printer->color(0); #black
    $device->printer->text("black"); 
    $device->printer->lf();
    $device->printer->color(1); #red
    $device->printer->text("Red"); 
    $device->printer->print();

=== justify 

Set Justification. Options *left*, *right* and *center*

    $device->printer->justify( 'right' );
    $device->printer->text("This is right justified"); 

=== upsideDown

Sets Upside Down Printing on/off (pass *0* or *1*)

    $device->printer->upsideDownPrinting(1);
    $device->printer->text("This text is upside down"); 

=== fontHeight 

Set font height. Only supports *0* or *1* for printmode set to 1, supports values *0*, *1*, *2*, *3*, *4*, *5*, *6* and *7* for non-printmode state (default) 

    $device->printer->fontHeight(1);
    $device->printer->text("double height\n");
    $device->printer->fontHeight(2);
    $device->printer->text("triple height\n");
    $device->printer->fontHeight(3);
    $device->printer->text("quadruple height\n");
    . . .

=== fontWidth 

Set font width. Only supports *0* or *1* for printmode set to 1, supports values *0*, *1*, *2*, *3*, *4*, *5*, *6* and *7* for non-printmode state (default) 

    $device->printer->fontWidth(1);
    $device->printer->text("double width\n");
    $device->printer->fontWidth(2);
    $device->printer->text("triple width\n");
    $device->printer->fontWidth(3);
    $device->printer->text("quadruple width\n");
    . . .

=== charSpacing

Sets character spacing. Takes a value between 0 and 255

    $device->printer->charSpacing(5);
    $device->printer->text("Blah Blah Blah\n");
    $device->printer->print();

=== lineSpacing 

Sets the line spacing i.e the spacing between each line of printout.

    $device->printer->lineSpacing($spacing);

* 0 <= $spacing <= 255

=== selectDefaultLineSpacing 

Reverts to default line spacing for the printer

    $device->printer->selectDefaultLineSpacing();

=== printPosition

Sets the distance from the beginning of the line to the position at which characters are to be printed.

    $device->printer->printPosition( $length, $height );

* 0 <= $length <= 255
* 0 <= $height <= 255

=== leftMargin

Sets the left margin. Takes two single byte parameters, ~nL~ and ~nH~.

To determine the value of these two bytes, use the INT and MOD conventions. INT indicates the integer (or whole number) part of a number, while MOD indicates the remainder of a division operation. Must be sent before a new line begins to be effective.

For example, to break the value 520 into two bytes, use the following two equations:
~nH~ = INT 520/256
~nL~ = MOD 520/256

    $device->printer->leftMargin(nL => $nl, nH => $nh);

=== barcode

This method prints a barcode to the printer. This can be bundled with other text formatting commands at the appropriate point where you would like to print a barcode on your print out. takes argument ~barcode~ as the barcode value.

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

Available barcode ~systems~:

* UPC-A
* UPC-C
* JAN13
* JAN8
* CODE39
* ITF
* CODABAR
* CODE93  
* CODE128 

=== printNVImage

Prints bit image stored in Non-Volatile (NV) memory of the printer. 

    $device->printer->printNVImage($flag);

* $flag = 0 # Normal width and Normal Height
* $flag = 1 # Double width and Normal Height
* $flag = 2 # Normal width and Double Height
* $flag = 3 # Double width and Double Height

=== printImage

Prints bit image stored in Volatile memory of the printer. This image gets erased when printer is reset. 

    $device->printer->printImage($flag);

* $flag = 0 # Normal width and Normal Height
* $flag = 1 # Double width and Normal Height
* $flag = 2 # Normal width and Double Height
* $flag = 3 # Double width and Double Height

=== cutPaper

Cuts the paper, if ~feed~ is set to *0* then printer doesnt feed paper to cutting position before cutting it. The default behavior is that the printer doesn't feed paper to cutting position before cutting. One pre-requisite line feed is automatically executed before paper cut though.

    $device->printer->cutPaper( feed => 0 )

While not strictly a text formatting option, in receipt printer the cut paper instruction is sent along with the rest of the text and text formatting data and the printer cuts the paper at the appropriate points wherever this command is used.

=== drawerKickPulse

Trigger drawer kick. Used to open cash drawer connected to the printer. In some use cases it may be used to trigger other devices by close contact.

    $device->printer->drawerKickPulse( $pin, $time );

* $pin is either 0( for pin 2 ) and 1( for pin5 ) default value is 0
* $time is a value between 1 to 8 and the pulse duration in multiples of 100ms. default value is 8

For default values use without any params to kick drawer pin 2 with a 800ms pulse

    $device->printer->drawerKickPulse();

Again like cutPaper command this is obviously not a text formatting command but this command is sent along with the rest of the text and text formatting data and the printer sends the pulse at the appropriate points wherever this command is used. While originally designed for triggering a cash drawer to open, in practice this port can be used for all sorts of devices like pulsing light, or sound alarm etc.

== PRINTING

=== print

Once Initialization is done and the formatted text for printing is prepared using the above commands, its time to send these commands to printer. This is a single easy step.
    
    $device->printer->print();

Why an extra print step to send this data to the printer?
This is necessary because many printers have difficulty handling large amount of print data sent across in a single large stream. Separating the preparation of data from transmission of data to the printer allows [Printer::ESCPOS] to do some buffer management and optimization in the way the entire data is sent to the printer with tiny timed breaks between chunks of data for a reliable printer output.

== GETTING PRINTER HEALTH STATUS

The *Serial* ~driverType~ allows reading of printer health, paper and other status parameters from the printer. 
At the moment there are following commands available for getting printer status.

=== printerStatus

Returns printer status in a hashref.

    return {
        drawer_pin3_high            => $flags[5],
        offline                     => $flags[4],
        waiting_for_online_recovery => $flags[2],
        feed_button_pressed         => $flags[1],
    };

=== offlineStatus

Returns a hashref for paper cover closed status, feed button pressed status, paper end stop status, and a aggregate error status either of which will prevent the printer from processing a printing request.

    return {
        cover_is_closed     => $flags[5],
        feed_button_pressed => $flags[4],
        paper_end           => $flags[2],
        error               => $flags[1],
    };

=== errorStatus

Returns hashref with error flags for auto_cutter_error, unrecoverable error and auto-recoverable error

    return {
        auto_cutter_error     => $flags[4],
        unrecoverable_error   => $flags[2],
        autorecoverable_error => $flags[1],
    };

=== paperSensorStatus

Gets printer paper Sensor status. Returns a hashref with four sensor statuses. Two paper near end sensors and two paper end sensors for printers supporting this feature. The exact returned status might differ based on the make of your printer. If any of the flags is set to 1 it implies that the paper is out or near end.

    return {
        paper_roll_near_end_sensor_1 => $flags[5],
        paper_roll_near_end_sensor_2 => $flags[4],
        paper_roll_status_sensor_1 => $flags[2],
        paper_roll_status_sensor_2 => $flags[1],
    };

=== inkStatusA

Only available for dot-matrix and other ink consuming printers. Gets printer ink status for inkA(usually black ink). Returns a hashref with ink statuses.

    return {
        ink_near_end          => $flags[5],
        ink_end               => $flags[4],
        ink_cartridge_missing => $flags[2],
        cleaning_in_progress  => $flags[1],
    };

=== inkStatusB

Only available for dot-matrix and other ink consuming printers. Gets printer ink status for inkB(usually red ink). Returns a hashref with ink statuses.

    return {
        ink_near_end          => $flags[5],
        ink_end               => $flags[4],
        ink_cartridge_missing => $flags[2],
    };

=end wikidoc
