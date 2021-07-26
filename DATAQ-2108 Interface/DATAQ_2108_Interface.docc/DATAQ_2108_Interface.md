# ``DATAQ_2108_Interface``

This framework provides access to the DATAQ 2108 data acquisition module using a simple Swift interface

It uses the SwiftUSB framework to communicate with the device.  This framework can be found [here](https://github.com/KevinCoble/SwiftUSB)

## Overview

The ``DATAQ_2108`` class is the main interface mechanism.  Use the static functions on that class to open a connection to a DATAQ 2108 module, configure the data collection parameters, then start collecting data.  The data is returned in a structure with all possible data in it, but with disabled channels and features returning nil.  The structure is sent to a closure you provide with the startScanning method.  This method is run in another thread (one started for the collection loop).

## Sample Use

The following code shows an example of using the framework.  It connects to a device, configures one analog input (channel 0), and starts scanning.  Every 100th collection (the default scan rate is 1 kHz), the voltage of the analog channel is printed.  After 30 seconds, the scanning is stopped.

    if let module = DATAQ_2108.OpenFirstFoundModule() {
        do {
            //  Enable analog channel 0
            try module.enableAnalogInput(channel: 0)
            
            //  Start scanning
            try module.startScanning { data in
                if ((data.packetNumber % 100) == 0) {
                    if (data.analogCount0 != nil) {
                        let voltage = data.getAnalogVoltage(channel: 0)!
                        print("analog 0 = \(voltage) from packet \(data.packetNumber)")
                    }
                    else {
                        print("analog 0 not received")
                    }
                }
                return true
            }
            
            Thread.sleep(forTimeInterval: 30.0)
            try module.stopScanning()
        }
        catch {
            print("unexpected error")
        }
    }



