DATAQ-2108 Interface is a framework for working with 
DATAQ 2108 USB data acquisition devices on a Macintosh.

The framework has a class that allows connection to a device, configuration of the device - including setting the scan list, and a separate thread scanning loop that calls a closure with each returned data packet.

The framework was last built using XCode 13.0 beta 3

### Features:
* Swift class for managing a DATAQ 2108  device
* Static functions to connect to a device
* Scan list configuration - analog channels, digital channels, rate, count, scan rate and packet return size are all configurable
* Callback closure called with each returned data packet
* Methods for setting digital outputs and LED color
* New DOCC documentation for the framework

#### Important notes
* Note:  The framework uses the SwiftUSB framework to communicate with the 2108 devices.  That framework can be found [here](https://github.com/KevinCoble/SwiftUSB).

### Future Work
If someone needs it, I could add a static function to connect to multiple devices (currently only the first found 2108 device can be connected).

### License
This framework uses is meant to be used and distributed.  It is a way of showing off the SwiftUSB framework.  As such, it is distributed under the MIT license.

