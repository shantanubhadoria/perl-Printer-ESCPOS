# NAME

Printer::ESCPOS - Interface for all thermal, dot-matrix and other receipt printers that support ESC-POS specification.

<div>
    <p>
    <img src="https://img.shields.io/badge/perl-5.10+-brightgreen.svg" alt="Requires Perl 5.10+" />
    <a href="https://travis-ci.org/shantanubhadoria/perl-Printer-ESCPOS"><img src="https://api.travis-ci.org/shantanubhadoria/perl-Printer-ESCPOS.svg?branch=build/master" alt="Travis status" /></a>
    <a href="http://matrix.cpantesters.org/?dist=Printer-ESCPOS%200.022"><img src="https://badgedepot.code301.com/badge/cpantesters/Printer-ESCPOS/0.022" alt="CPAN Testers result" /></a>
    <a href="http://cpants.cpanauthors.org/dist/Printer-ESCPOS-0.022"><img src="https://badgedepot.code301.com/badge/kwalitee/Printer-ESCPOS/0.022" alt="Distribution kwalitee" /></a>
    <a href="https://gratipay.com/shantanubhadoria"><img src="https://img.shields.io/gratipay/shantanubhadoria.svg" alt="Gratipay" /></a>
    </p>
</div>

# VERSION

version 0.022

# SYNOPSIS

If you are just starting up with POS RECEIPT Printers, you must first refer to [Printer::ESCPOS::Manual](https://metacpan.org/pod/Printer::ESCPOS::Manual) to get started.

Printer::ESCPOS provides four different types of printer connections to talk to a ESCPOS printer.
As of v0.012 _driverType_ **Serial**, **Network**, **File** and **USB** are all implemented in this module. **USB** _driverType_ is not supported prior to v0.012.

## USB Printer

**USB** _driverType_ allows you to talk to your Printer using the _vendorId_ and _productId_ values for your printer. These can be retrieved using lsusb command

     shantanu@shantanu-G41M-ES2L:~/github$ lsusb
     . . .
     Bus 003 Device 002: ID 1504:0006
     . . .

The output gives us the _vendorId_ 0x1504 and _productId_ 0x0006

For USB Printers [Printer::ESCPOS](https://metacpan.org/pod/Printer::ESCPOS) uses a default _endPoint_ of 0x01 and a default _timeout_ of
1000, however these can be specified manually in case your printer requires a different value.

        use Printer::ESCPOS;
    
        my $vendorId  = 0x1504;
        my $productId = 0x0006;
        my $device = Printer::ESCPOS->new(
            driverType     => 'USB',
            vendorId       => $vendorId,
            productId      => $productId,
        );
    
        $device->printer->printAreaWidth( nL => 0, nH => 1);
        $device->printer->text("Print Area Width Modified\n");
        $device->printer->printAreaWidth(); # Reset to default
        $device->printer->text("print area width reset\n");
        $device->printer->tab();
        $device->printer->underline(1);
        $device->printer->text("underline on\n");
        $device->printer->invert(1);
        $device->printer->text("Inverted Text\n");
        $device->printer->justification('right');
        $device->printer->text("Right Justified\n");
        $device->printer->upsideDown(1);
        $device->printer->text("Upside Down\n");
        $device->printer->cutPaper();
    
        $device->printer->print(); # Dispatch the above commands from module buffer to the Printer.

## Network Printer

For Network Printers $port is 9100 in most cases but might differ depending on how
you have configured your printer

        use Printer::ESCPOS;
    
        my $printer_id = '192.168.0.10';
        my $port       = '9100';
        my $device = Printer::ESCPOS->new(
            driverType => 'Network',
            deviceIp   => $printer_ip,
            devicePort => $port,
        );
    
        # These commands won't actually send anything to the printer but will store all the
        # merged data including control codes to module buffer.
        $device->printer->printAreaWidth( nL => 0, nH => 1);
        $device->printer->text("Print Area Width Modified\n");
        $device->printer->printAreaWidth(); # Reset to default
        $device->printer->text("print area width reset\n");
        $device->printer->tab();
        $device->printer->underline(1);
        $device->printer->text("underline on\n");
        $device->printer->invert(1);
        $device->printer->text("Inverted Text\n");
        $device->printer->justification('right');
        $device->printer->text("Right Justified\n");
        $device->printer->upsideDown(1);
        $device->printer->text("Upside Down\n");
        $device->printer->cutPaper();
    
        $device->printer->print(); # Dispatch the above commands from module buffer to the Printer.
                                   # This command takes care of read text buffers for the printer.

## Serial Printer

Use the **Serial** _driverType_ for local printer connected on serial port(or a printer connected via
a physical USB port in USB to Serial mode), check syslog(Usually under /var/log/syslog)
for what device file was created for your printer when you connect it to your system(For
plug and play printers).

        use Printer::ESCPOS;
        use Data::Dumper; # Just to get dumps of status functions supported for Serial driverType.
    
        my $path = '/dev/ttyACM0';
        $device = Printer::ESCPOS->new(
            driverType     => 'Serial',
            deviceFilePath => $path,
        );
    
        say Dumper $device->printer->printerStatus();
        say Dumper $device->printer->offlineStatus();
        say Dumper $device->printer->errorStatus();
        say Dumper $device->printer->paperSensorStatus();
    
        $device->printer->bold(1);
        $device->printer->text("Bold Text\n");
        $device->printer->bold(0);
        $device->printer->text("Bold Text Off\n");
    
        $device->printer->print();

## File(Direct to Device File) Printer

A **File** _driverType_ is similar to the **Serial** _driverType_ in all functionality except that it
doesn't support the status functions for the printer. i.e. you will not be able to use
printerStatus, offlineStatus, errorStatus or paperSensorStatus functions

        use Printer::ESCPOS;
    
        my $path = '/dev/usb/lp0';
        $device = Printer::ESCPOS->new(
            driverType     => 'File',
            deviceFilePath => $path,
        );
    
        $device->printer->bold(1);
        $device->printer->text("Bold Text\n");
        $device->printer->bold(0);
        $device->printer->text("Bold Text Off\n");
    
        $device->printer->print();

# DESCRIPTION

You can use this module for all your ESC-POS Printing needs. If some of your printer's functions are not included, you may extend this module by adding specialized funtions for your printer in it's own subclass. Refer to [Printer::ESCPOS::Roles::Profile](https://metacpan.org/pod/Printer::ESCPOS::Roles::Profile) and [Printer::ESCPOS::Profiles::Generic](https://metacpan.org/pod/Printer::ESCPOS::Profiles::Generic)

# ATTRIBUTES

## driverType

"Required attribute". The driver type to use for your printer. This can be **File**, **Network**, **USB** or **Serial**.
If you choose **File** or **Serial** driver, you must provide the _deviceFilePath_,
for **Network** _driverType_ you must provide the _printerIp_ and _printerPort_,
For **USB** _driverType_ you must provide _vendorId_ and _productId_.

USB driver type:

    my $vendorId  = 0x1504;
    my $productId = 0x0006;
    my $device = Printer::ESCPOS->new(
        driverType => 'USB'
        vendorId   => $vendorId,
        productId  => $productId,
    );

Network driver type:

    my $printer_id = '192.168.0.10';
    my $port       = '9100';
    my $device = Printer::ESCPOS->new(
        driverType => 'Network',
        deviceIp   => $printer_ip,
        devicePort => $port,
    );

Serial driver type:

    my $path = '/dev/ttyACM0';
    $device = Printer::ESCPOS->new(
        driverType     => 'Serial',
        deviceFilePath => $path,
    );

File driver type:

    my $path = '/dev/usb/lp0';
    $device = Printer::ESCPOS->new(
        driverType     => 'File',
        deviceFilePath => $path,
    );

## profile

There are minor differences in ESC POS printers across different brands and models in terms of specifications and extra features. For using special features of a particular brand you may create a sub class in the name space Printer::ESCPOS::Profiles::\* and load your profile here. I would recommend extending the Generic Profile( [Printer::ESCPOS::Profiles::Generic](https://metacpan.org/pod/Printer::ESCPOS::Profiles::Generic) ).
Use the following classes as examples.
[Printer::ESCPOS::Profiles::Generic](https://metacpan.org/pod/Printer::ESCPOS::Profiles::Generic)
[Printer::ESCPOS::Profiles::SinocanPSeries](https://metacpan.org/pod/Printer::ESCPOS::Profiles::SinocanPSeries)

Note that your driver class will have to implement the Printer::ESCPOS::Roles::Profile Interface. This is a [Moo::Role](https://metacpan.org/pod/Moo::Role) and can be included in your class with the following line.

    use Moo;
    with 'Printer::ESCPOS::Roles::Profile';

By default the generic profile is loaded but if you have written your own Printer::ESCPOS::Profile::\* class and want to override the generic class pass the _profile_ Param during object creation.

    my $device = Printer::ESCPOS->new(
        driverType => 'Network',
        deviceIp   => $printer_ip,
        devicePort => $port,
        profile    => 'USERCUSTOM'
    );

The above $device object will use the Printer::ESCPOS::Profile::USERCUSTOM profile.

## deviceFilePath

File path for UNIX device file. e.g. "/dev/ttyACM0" this is a mandatory parameter if you are using **File** or **Serial** _driverType_.

## portName

Win32 serial port name

## deviceIP

Contains the IP address of the device when its a network printer. The module creates [IO:Socket::INET](IO:Socket::INET) object to connect to the printer. This can be passed in the constructor.

## devicePort

Contains the network port of the device when its a network printer. The module creates [IO:Socket::INET](IO:Socket::INET) object to connect to the printer. This can be passed in the constructor.

## baudrate

When used as a local serial device you can set the _baudrate_ of the printer too. Default (38400) will usually work, but not always.

## serialOverUSB

Set this value to 1 if you are connecting your printer using the USB Cable but it shows up as a serial device and you are using the **Serial** driver.

## vendorId

This is a required param for **USB** _driverType_. It contains the USB printer's Vendor ID when using **USB** _driverType_. Use lsusb command to get this value for your printer.

## productId

This is a required param for **USB** _driverType_. It contains the USB printer's product Id when using **USB** _driverType_. Use lsusb command to get this value for your printer.

## endPoint

This is a optional param for **USB** _driverType_. It contains the USB endPoint for [Device::USB](https://metacpan.org/pod/Device::USB) to write to if the value is not 0x01 for your printer. Get it using the following command:

    shantanu@shantanu-G41M-ES2L:~$ sudo lsusb -vvv -d 1504:0006 | grep bEndpointAddress | grep OUT
            bEndpointAddress     0x01  EP 1 OUT

Replace 1504:0006 with your own printer's vendor id and product id in the above command.

## timeout

Timeout for bulk write functions for the USB printer. Optional param.

## printer

Use this attribute to send commands to the printer

    $device->printer->setFont('a');
    $device->printer->text("blah blah blah\n");

# USAGE

Refer to the following manual to get started with [Printer::ESCPOS](https://metacpan.org/pod/Printer::ESCPOS)

- [Printer::ESCPOS::Manual](https://metacpan.org/pod/Printer::ESCPOS::Manual)

## Quick usage summary in steps:

1. Create a device object $device by providing parameters for one of the supported printer types. Call $device->printer->init to initialize the printer.
2. call text() and other Text formatting functions on $device->printer for the data to be sent to the printer. Make sure to end it all with a linefeed $device->printer->lf().
3. Then call the print() method to dispatch the sequences from the module buffer to the printer

     $device->printer->print()

Note: While you may call print() after every single command code, this is not advisable as some printers tend to choke up if you send them too many print commands in quick succession. To avoid this, aggregate the data to be sent to the printer with text() and other text formatting functions and then send it all in one go using print() at the very end.

# NOTES

- In Serial mode if the printer prints out garbled characters instead of proper text, try specifying the baudrate parameter when you create the printer object. The default baudrate is set at 38400

     $device = Printer::ESCPOS->new(
         driverType     => 'Serial',
         deviceFilePath => $path,
         baudrate       => 9600,
     );

- For ESC-P codes refer the guide from Epson [http://support.epson.ru/upload/library\_file/14/esc-p.pdf](http://support.epson.ru/upload/library_file/14/esc-p.pdf)

# SEE ALSO

- [Printer::ESCPOS::Manual](https://metacpan.org/pod/Printer::ESCPOS::Manual)
- [Printer::ESCPOS::Profiles::Generic](https://metacpan.org/pod/Printer::ESCPOS::Profiles::Generic)
- [Printer::ESCPOS::Profiles::SinocanPSeries](https://metacpan.org/pod/Printer::ESCPOS::Profiles::SinocanPSeries)
- [Printer::ESCPOS::Roles::Profile](https://metacpan.org/pod/Printer::ESCPOS::Roles::Profile)
- [Printer::ESCPOS::Roles::Connection](https://metacpan.org/pod/Printer::ESCPOS::Roles::Connection)
- [Printer::ESCPOS::Connections::USB](https://metacpan.org/pod/Printer::ESCPOS::Connections::USB)
- [Printer::ESCPOS::Connections::Serial](https://metacpan.org/pod/Printer::ESCPOS::Connections::Serial)
- [Printer::ESCPOS::Connections::Network](https://metacpan.org/pod/Printer::ESCPOS::Connections::Network)
- [Printer::ESCPOS::Connections::File](https://metacpan.org/pod/Printer::ESCPOS::Connections::File)

# SUPPORT

## Bugs / Feature Requests

Please report any bugs or feature requests through github at 
[https://github.com/shantanubhadoria/perl-printer-escpos/issues](https://github.com/shantanubhadoria/perl-printer-escpos/issues).
You will be notified automatically of any progress on your issue.

## Source Code

This is open source software.  The code repository is available for
public review and contribution under the terms of the license.

[https://github.com/shantanubhadoria/perl-printer-escpos](https://github.com/shantanubhadoria/perl-printer-escpos)

    git clone git://github.com/shantanubhadoria/perl-printer-escpos.git

# AUTHOR

Shantanu Bhadoria <shantanu@cpan.org> [https://www.shantanubhadoria.com](https://www.shantanubhadoria.com)

# CONTRIBUTOR

Shantanu Bhadoria &lt;shantanu att cpan dott org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Shantanu Bhadoria.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
