package Printer::ESCPOS::Manual;

# PODNAME: Printer::ESCPOS::Manual
# ABSTRACT: Manual for Printing POS Receipts using Printer::ESCPOS
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
    $device->printer->write("Heading text\n");
    $device->printer->bold(0);
    $device->printer->write("Content here\n");
    $device->printer->write(". . .\n");


    # Add a cut paper command at the end to cut the receipt
    # This command will be ignored by your printer if it 
    # doesn't have a paper cutter on it 
    $device->printer->cutPaper(); 

    
    # Send the Prepared data to the printer.
    $device->printer->print();

= PRINTER FORMATTING AND TEXT COMMANDS

In all the methods described below its assumed that $device has been initilized using the appropriate connection to the printer like so(The device file path  or the driverType in your case may vary depending on how you connect to your printer):

    my $device = Printer::ESCPOS->new(
        driverType     => 'Serial'
        deviceFilePath => '/dev/ttyACM0'
    );

=method printAreaWidth

Sets the Print area width specified by nL and NH. The width is calculated as 

    ( nL + nH * 256 ) * horiz_motion_unit 
    
nL and nH are single Byte Characters. To determine the value of these two bytes, use the INT and MOD conventions. INT indicates the integer (or whole number) part of a number, while MOD indicates the remainder of a division operation.
For example, to break the value 520 into two bytes, use the following two equations:
nH = INT 520/256
nL = MOD 520/256
A pre-requisite line feed is automatically executed before printAreaWidth method.

    $device->printer->printAreaWidth( nL => 0, nH =>0 );

=method tabPositions

Sets horizontal tab positions for tab stops. Upto 32 tab positions can be set in most receipt printers.

    $device->printer->tabPositions( 5, 9, 13 );
    $device->printer->tabPositions( 3, 20 );

* Default tab positions are usually in intervals of 8 chars (9, 17, 25) etc. Tab position is particularly useful function when printing price lists in receipts like these.

    Item           Price
    ----------------------
    Carrots        $20.00
    Guava          $120.23
    ...
    ----------------------
    Total          $523.44

To print a receipt like the above just set tab position to appropriate value where the second column starts
    $device->printer->tabPositions(4,20); # Items will start at pos 4 and Prices at pos 20
    $device->write("Item\tPrice\n");
    $device->write("----------------------\n");
    for (@items){
        $device->write($_->{itemname} . "\t" . $_->{price} . "\n");
    }
    $device->write("----------------------\n");
    $device->write("Total\t" . $total . "\n");
    $device->printer->print();

=method font

Set Font style, you can pass 'a', 'b' or 'c'. Many printers don't support style 'c' and only have two supported styles.

    $device->printer->font('a');
    $device->printer->write("This text is Font A\n");
    $device->printer->font('b');
    $device->printer->write("This text is Font B\n");

    $device->printer->print();

=method emphasized

Set bold mode 0 for off and 1 for on. Also called emphasized mode in some printer manuals 

    $device->printer->bold(1);
    $device->printer->write("This is Bold Text\n");
    $device->printer->bold(0);
    $device->printer->write("This is not Bold Text\n");

    $device->printer->print();

=method doubleStrike 

Set double-strike mode 0 for off and 1 for on

    $device->printer->doubleStrike(1);
    $device->printer->write("This is doubleStrike Text\n");
    $device->printer->doubleStrike(0);
    $device->printer->write("This is not doubleStrike Text\n");

    $device->printer->print();

=method underline

set underline, 0 for off, 1 for on and 2 for double thickness 
    
    $device->printer->underline(1);
    $device->printer->write("This is underlined Text\n");
    $device->printer->underline(2);
    $device->printer->write("This is underlined Text with double thickness\n");
    $device->printer->underline(0);
    $device->printer->write("This is not underlined Text\n");

    $device->printer->print();

=method invert

Reverse white/black printing mode pass 0 for off and 1 for on

    $device->printer->invert(0);
    $device->printer->write("This text is white on black background\n");
    $device->printer->invert(1);
    $device->printer->write("This text is black on white background\n");

    $device->printer->print();

=cut
=method color

Most thermal printers support just one color, black. Some ESCPOS printers(especially dot matrix) also support a second color, usually red. In many models, this only works when the color is set at the beginning of a new line before any text is printed.

    $device->printer->lf();
    $device->printer->color(0); #black
    $device->printer->write("This is Black text"); 
    $device->printer->lf();
    $device->printer->color(1); #red
    $device->printer->write("This is Red text"); 

    $device->printer->print();

=method justify 

Set Justification. Options 'left', 'right' and 'center'

    $device->printer->lf();
    $device->printer->justify( 'right' );
    $device->printer->write("This is Right Justified Text\n"); 
    $device->printer->justify( 'center' );
    $device->printer->write("This is Center Justified Text\n"); 
    $device->printer->justify( 'left' );
    $device->printer->write("This is Left Justified Text\n"); 

    $device->printer->print();

=method upsideDown

Sets Upside Down Printing on/off (pass 0 or 1)

    $device->printer->lf();
    $device->printer->upsideDownPrinting(1);
    $device->printer->write("This Text is Upside Down\n"); 
    $device->printer->upsideDownPrinting(0);
    $device->printer->write("This Text is right side up\n"); 

    $device->printer->print();

=method fontHeight 

Set font height. Supports values 0 to 7 for non-printmode state (default case). Only supports 0 or 1 if printmode flag is set to 1  by the user

    for (1 .. 7){
        $device->printer->fontHeight($_);
        $device->printer->write("Font Height $_ \n"); 
    }
    $device->printer->print();

=method fontWidth 

Set font width. Supports values 0 to 7 for non-printmode state (default case). Only supports 0 or 1 if printmode flag is set to 1  by the user

    for (1 .. 7){
        $device->printer->fontWidth($_);
        $device->printer->write("Font Width $_ \n"); 
    }
    $device->printer->print();


= PRINTER CONTROL AND INITIALIZATION COMMANDS

=method init

Initializes the Printer. Clears the data in print buffer and resets the printer to the mode that was in effect when the power was turned on.
    $device->printer->init()

== enable

Enables/Disables the printer with a '_ESC =' command (Set peripheral device). When disabled, the printer ignores all commands except enable() or other real-time commands.
Pass 1 to enable, pass 0 to disable
    
    $device->printer->enable(0) # disabled
    $device->printer->enable(1) # enabled

=end wikidoc
