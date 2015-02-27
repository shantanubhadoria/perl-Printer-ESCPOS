use strict;
use warnings;

package Printer::ESCPOS;

# PODNAME: Printer::ESCPOS
# ABSTRACT: Interface for all thermal or dot-matrix receipt printers that support ESC-POS specification.  
# COPYRIGHT
# VERSION

# Dependencies
use 5.010;
use Moose;
use Moose::Util::TypeConstraints;
use aliased 'Printer::ESCPOS::Roles::Profile' => 'ESCPOSProfile';
use namespace::autoclean;

use Printer::ESCPOS::Connections::File;
use Printer::ESCPOS::Connections::Network;
use Printer::ESCPOS::Connections::Serial;
use Printer::ESCPOS::Connections::USB;

=attr driverType

"Required attribute". The driver type to use for your printer. This can be "File", "Network" or "Serial". "USB" driver is not implemented yet.
If you choose "File" or "Serial" driver, you must provide the deviceFilePath, for "Network" driver you must provide the printerIp and printerPort.

=cut

has driverType => (
    is       => 'rw',
    isa      => enum( [qw[ File Network Serial USB ]] ),
    required => 1,
);

=attr profile

There are minor differences in ESC POS printers across different brands and models in terms of specifications and extra features. For using special features of a particular brand you may create a sub class in the name space Printer::ESCPOS::Profiles::* and load your profile here. I would recommend extending  Generic ( [Printer::ESCPOS::Profiles::Generic] ).
Use the following classes as examples.
[Printer::ESCPOS::Profiles::Generic]
[Printer::ESCPOS::Profiles::SinocanPSeries]

Note that your driver class will have to implement the Printer::ESCPOS::Roles::Profile Interface. This is a Moose Role and can be included in your class with the following line.

    use Moose;
    extends 'Printer::ESCPOS::Roles::Profile';

=cut

has profile => (
    is      => 'rw',
    default => 'Generic',
);

=attr deviceFilePath

File path for UNIX device file. e.g. "/dev/ttyACM0"

=cut

has deviceFilePath => (
    is  => 'rw',
    isa => 'Str',
);

=attr deviceIP

Contains the IP address of the device when its a network printer. The module creates IO:Socket::INET object to connect to the printer. This can be passed in the constructor.

=cut

has deviceIP => (
  is => 'ro',
  isa => 'Str',
);

=attr devicePort

Contains the network port of the device when its a network printer. The module creates IO:Socket::INET object to connect to the printer. This can be passed in the constructor.

=cut

has devicePort => (
  is => 'ro',
  isa => 'Int',
);

=attr baudrate

When used as a local serial device you can set the baudrate of the printer too. Default (38400) will usually work, but not always. 

=cut

has baudrate => (
  is => 'ro',
  isa => 'Int',
  default => 38400,
);

has _driver => (
    is         => 'ro',
    lazy_build => 1,
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
        );
    }
}

=attr printer

Use this attribute to send commands to the printer
    
    $device->printer->setFont('a');
    $device->printer->write("blah blah blah\n");

=cut

has printer => (
    is         => 'ro',
    lazy_build => 1,
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
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=begin wikidoc

= SYNOPSIS

  use Printer::ESCPOS;

  #For Network Printers $port is 9100 in most cases but might differ depending on how you have configured your printer
  $printer = Printer::ESCPOS->new(device_ip=>$printer_ip,device_port=>$port);

  #These commands won't actually send anything to the printer but it will store all the merged data including control codes to send to printer in $printer->print_string variable.
  $printer->write("Blah Blah \nReceipt Details\nFooter");
  $printer->bold_on();
  $printer->write("Bold Text");
  $printer->bold_off();
  $printer->print(); ##Sends the above set of code to the printer. Clears the buffer text in module.
  
  #For local printer connected on serial port, check syslog(Usually under /var/log/syslog) for what device file was created for your printer when you connect it to your system(For plug and play printers).
  my $path = '/dev/ttyACM0';
  $printer = Printer::ESCPOS->new(serial_device_path=$path);
  $printer->write("Blah Blah \nReceipt Details\nFooter");
  $printer->bold_on();
  $printer->write("Bold Text");
  $printer->bold_off();
  $printer->print();

  #For local printer connected on usb port, check syslog(Usually under /var/log/syslog) for what device file was created for your printer when you connect it to your system(For plug and play printers).
  my $path = '/dev/usb/lp0';
  $printer = Printer::ESCPOS->new(usb_device_path=$path);
  $printer->write("Blah Blah \nReceipt Details\nFooter");
  $printer->bold_on();
  $printer->write("Bold Text");
  $printer->bold_off();
  $printer->print();

= DESCRIPTION

You can use this module for all your ESC-POS Printing needs. If some of your printer's functions are not included, you can even extend this module by adding specialized funtions for your printer in it's own subclass.

For ESC-P codes refer the guide from Epson http://support.epson.ru/upload/library_file/14/esc-p.pdf

= NOTES

* If the printer prints out garbled characters instead of proper text, try specifying the baudrate parameter when creating printer object when you create the printer object(not for network or USB printers)
    $printer = Printer::ESCPOS->new(serial_device_path => '/dev/ttyACM0', baudrate => 9600);

= USAGE

* This Module offers a object oriented interface to ESC-POS Printers. 
* Create a printer object by providing parameters for one of the three types of 
printers supported.
* then call formatting options or write() text to printer object in sequence. 
* Then call the print() method to dispatch the sequences from the module buffer 
to the printer. 

Note: While you may call print() after every single command code, this is not advisable as some printers tend to choke up if you send them too many commands too quickly.

=end wikidoc

=cut
