use strict;
use warnings;

package Printer::ESCPOS;

# PODNAME: Printer::ESCPOS
# ABSTRACT: Interface for all thermal, dot-matrix and other receipt printers that support ESC-POS specification.  
# COPYRIGHT
# VERSION

# Dependencies
use 5.010;
use Moo;
use Carp;
use Type::Tiny;
use aliased 'Printer::ESCPOS::Roles::Profile' => 'ESCPOSProfile';
use namespace::autoclean;

use Printer::ESCPOS::Connections::File;
use Printer::ESCPOS::Connections::Network;
use Printer::ESCPOS::Connections::Serial;
use Printer::ESCPOS::Connections::USB;

=attr driverType

"Required attribute". The driver type to use for your printer. This can be B<File>, B<Network>, B<USB> or B<Serial>. 
If you choose B<File> or B<Serial> driver, you must provide the I<deviceFilePath>, 
for B<Network> I<driverType> you must provide the I<printerIp> and I<printerPort>,
For USB I<driverType> you must provide I<vendorId> and I<productId>.

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

=cut

has driverType => (
    is       => 'ro',
    required => 1,
);

=attr profile

There are minor differences in ESC POS printers across different brands and models in terms of specifications and extra features. For using special features of a particular brand you may create a sub class in the name space Printer::ESCPOS::Profiles::* and load your profile here. I would recommend extending the Generic Profile( L<Printer::ESCPOS::Profiles::Generic> ).
Use the following classes as examples.
L<Printer::ESCPOS::Profiles::Generic>
L<Printer::ESCPOS::Profiles::SinocanPSeries>

Note that your driver class will have to implement the Printer::ESCPOS::Roles::Profile Interface. This is a L<Moo::Role> and can be included in your class with the following line.

    use Moo;
    with 'Printer::ESCPOS::Roles::Profile';

By default the generic profile is loaded but if you have written your own Printer::ESCPOS::Profile::* class and want to override the generic class pass the I<profile> Param during object creation.

    my $device = Printer::ESCPOS->new(
        driverType => 'Network',
        deviceIp   => $printer_ip,
        devicePort => $port,
        profile    => 'USERCUSTOM'
    );

The above $device object will use the Printer::ESCPOS::Profile::USERCUSTOM profile.

=cut

has profile => (
    is      => 'ro',
    default => 'Generic',
);

=attr deviceFilePath

File path for UNIX device file. e.g. "/dev/ttyACM0" this is a mandatory parameter if you are using B<File> or B<Serial> I<driverType>.

=cut

has deviceFilePath => (
    is  => 'ro',
);

=attr deviceIP

Contains the IP address of the device when its a network printer. The module creates L<IO:Socket::INET> object to connect to the printer. This can be passed in the constructor.

=cut

has deviceIP => (
  is  => 'ro',
);

=attr devicePort

Contains the network port of the device when its a network printer. The module creates L<IO:Socket::INET> object to connect to the printer. This can be passed in the constructor.

=cut

has devicePort => (
  is      => 'ro',
  default => '9100',
);

=attr baudrate

When used as a local serial device you can set the I<baudrate> of the printer too. Default (38400) will usually work, but not always. 

=cut

has baudrate => (
  is      => 'ro',
  default => 38400,
);

=attr serialOverUSB

Set this value to 1 if you are connecting your printer using the USB Cable but it shows up as a serial device and you are using the B<Serial> driver.

=cut

has serialOverUSB => (
  is      => 'ro',
  default => '1',
);

=attr vendorId

This is a required param for *USB* ~driverType~. It contains the USB printer's Vendor ID when using *USB* ~driverType~. Use lsusb command to get this value for your printer.

=cut

has vendorId => (
    is         => 'ro',
);

=attr productId

This is a required param for *USB* ~driverType~. It contains the USB printer's product Id when using *USB* ~driverType~. Use lsusb command to get this value for your printer.

=cut

has productId => (
    is         => 'ro',
);

=attr endPoint

This is a optional param for *USB* ~driverType. It contains the USB endPoint for L<Device::USB> to write to if the value is not 0x01 for your printer. Get it using the following command:

    shantanu@shantanu-G41M-ES2L:~$ sudo lsusb -vvv -d 1504:0006 | grep bEndpointAddress | grep OUT
            bEndpointAddress     0x01  EP 1 OUT

Replace 1504:0006 with your own printer's vendor id and product id in the above command.

=cut

has endPoint => (
    is       => 'ro',
    default  => 0x01,
);

=attr timeout

Timeout for bulk write functions for the USB printer. Optional param.

=cut

has timeout => (
    is       => 'ro',
    required => 1,
    default  => 1000,
);

has _driver => (
    is         => 'lazy',
    init_arg   => undef,
);

sub _build__driver {
    my ( $self ) = @_;

    if( $self->driverType eq 'File' ) {
        return Printer::ESCPOS::Connections::File->new(
            deviceFilePath => $self->deviceFilePath,
        );
    } elsif( $self->driverType eq 'Network' ) {
        return Printer::ESCPOS::Connections::Network->new(
            deviceIP   => $self->deviceIP,
            devicePort => $self->devicePort,
        );
    } elsif( $self->driverType eq 'Serial' ) {
        return Printer::ESCPOS::Connections::Serial->new(
            deviceFilePath => $self->deviceFilePath,
            baudrate       => $self->baudrate,
            serialOverUSB  => $self->serialOverUSB,
        );
    } elsif( $self->driverType eq 'USB' ) {
        return Printer::ESCPOS::Connections::USB->new(
            productId => $self->productId,
            vendorId  => $self->vendorId,
            endPoint  => $self->endPoint,
            timeout   => $self->timeout,
        );
    }
}

=attr printer

Use this attribute to send commands to the printer
    
    $device->printer->setFont('a');
    $device->printer->text("blah blah blah\n");

=cut

has printer => (
    is         => 'lazy',
);

sub _build_printer {
    my ( $self ) = @_;
   
    my $base  = __PACKAGE__ . "::Profiles::";
    my $class = $base . $self->profile;

    Class::Load::load_class($class);
    unless ($class->does(ESCPOSProfile)){
        confess "Class ${class} in ${base} does not implement the Printer::ESCPOS::Roles::Profile Interface";
    }
    my $object = $class->new(
        driver => $self->_driver,
    );

    $object->init();

    return $object;
}

no Moo;
__PACKAGE__->meta->make_immutable;

1;

__END__

=begin wikidoc

= SYNOPSIS

If you are just starting up with POS RECEIPT Printers, you must first refer to [Printer::ESCPOS::Manual] to get started.

Printer::ESCPOS provides four different types of printer connections to talk to a ESCPOS printer. 
As of v0.012 ~driverTypes~ *Serial*, *Network*, *File* and *USB* are all implemented in this module. 'USB' driverType is not supported prior to v0.012. 

== USB Printer

*USB* ~driverType~ allows you to talk to your Printer using the ~vendorId~ and ~productId~ values for your printer. These can be retrieved using lsusb command

    shantanu@shantanu-G41M-ES2L:~/github$ lsusb
    . . .
    Bus 003 Device 002: ID 1504:0006  
    . . .

The output gives us the ~vendorId~ 0x1504 and ~productId~ 0x0006

For USB Printers [Printer::ESCPOS] uses a default ~endPoint~ of 0x01 and a default ~timeout~ of
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

== Network Printer

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

== Serial Printer

Use the Serial mode for local printer connected on serial port(or a printer connected via 
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


== File(Direct to Device File) Printer

A 'File' driver is similar to the 'Serial' driver in all functionality except that it 
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

= DESCRIPTION

You can use this module for all your ESC-POS Printing needs. If some of your printer's functions are not included, you may extend this module by adding specialized funtions for your printer in it's own subclass. Refer to [Printer::ESCPOS::Roles::Profile] and [Printer::ESCPOS::Profiles::Generic]

= USAGE

Refer to the following manual to get started with [Printer::ESCPOS]

* [Printer::ESCPOS::Manual]

== Quick usage summary in steps:

0 Create a device object $device by providing parameters for one of the supported printer types. Call $device->printer->init to initialize the printer.
0 call text() and other Text formatting functions on $device->printer for the data to be sent to the printer. Make sure to end it all with a linefeed $device->printer->lf().
0 Then call the print() method to dispatch the sequences from the module buffer to the printer
    $device->printer->print()

Note: While you may call print() after every single command code, this is not advisable as some printers tend to choke up if you send them too many print commands in quick succession. To avoid this, aggregate the data to be sent to the printer with text() and other text formatting functions and then send it all in one go using print() at the very end.

= NOTES

* In Serial mode if the printer prints out garbled characters instead of proper text, try specifying the baudrate parameter when you create the printer object. The default baudrate is set at 38400
    $device = Printer::ESCPOS->new(
        driverType     => 'Serial',
        deviceFilePath => $path,
        baudrate       => 9600,
    );
* For ESC-P codes refer the guide from Epson [http://support.epson.ru/upload/library_file/14/esc-p.pdf]

=end wikidoc
