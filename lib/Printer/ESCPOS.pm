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
use namespace::autoclean;

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
