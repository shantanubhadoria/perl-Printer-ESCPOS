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

== enable

Enables/Disables the printer with a '_ESC =' command (Set peripheral device). When disabled, the printer ignores all commands except enable() or other real-time commands
pass 1 to enable, pass 0 to disable
    
    $device->printer->enable(0) # disabled
    $device->printer->enable(1) # enabled

=end wikidoc
