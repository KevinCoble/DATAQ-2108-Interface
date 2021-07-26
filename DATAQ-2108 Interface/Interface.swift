//
//  Interface.swift
//  DATAQ-2108 Interface
//
//  Created by Kevin Coble on 7/15/21.
//

import Foundation
import SwiftUSB

///  Errors that can be thrown by a DATAQ interface class method
public enum DATAQ_Interface_Error: Error {
    /// The index for the analog input was outside the valid range for the device
    case invalidAnalogIndex
    /// The index for the digital input or output was outside the valid range for the device
    case invalidDigitalIndex
    /// Configuration changes cannot be made while the device is in scan mode
    case cannotConfigureWhileScanning
    /// No analogs, digitals, rate, or count channels have been enabled
    case noInputsConfigured
    /// The requested data return rate is above the maximum possible for the enabled channels (160000 Hz)
    case dataRateAboveMaximum
    /// The requested data return rate is below the minimum possible (915.5413 divided by decimation).  Increase decimation to lower data rate
    case dataRateBelowMinimum
    /// A request to stop scanning was made when scanning was not active
    case notScanning
}

///  Analog input handling for use with decimation factor > 1
public enum AnalogInputHandling : Int {
    /// Return the last analog input value across the decimation window
    case lastPoint = 0
    /// Return the result of a CIC filter from analog input value across the decimation window
    case CICFiltert = 1
    /// Return the maximum analog input value across the decimation window
    case maximum = 2
    /// Return the minimum analog input value across the decimation window
    case minimum = 3
}

///  Range for rate measurement
public enum RateMaximumFrequency : Int {
    ///  50 kHz
    case Hz50000 = 1
    ///  20 kHz
    case Hz20000 = 2
    ///  10 kHz
    case Hz10000 = 3
    ///  5 kHz
    case Hz5000 = 4
    ///  2 kHz
    case Hz2000 = 5
    ///  1 kHz
    case Hz1000 = 6
    ///  500 Hz
    case Hz500 = 7
    ///  200 Hz
    case Hz200 = 8
    ///  100 Hz
    case Hz100 = 9
    ///  50 Hz
    case Hz50 = 10
    ///  20 Hz
    case Hz20 = 11
    ///  10 Hz
    case Hz10 = 12
}


///  Packet size - this affects how often results are returned
public enum ReturnPacketSize : Int {
    ///  16 bytes (8 collected data values) per packet
    case send16Bytes = 0
    ///  32 bytes (16 collected data values) per packet
    case send32Bytes = 1
    ///  64 bytes (32 collected data values) per packet
    case send64Bytes = 2
    ///  128bytes (64 collected data values) per packet
    case send128Bytes = 3
    ///  256 bytes (128 collected data values) per packet
    case send256Bytes = 4
    ///  512 bytes (256 collected data values) per packet
    case send512Bytes = 5
    ///  1024 bytes (512 collected data values) per packet
    case send1024Bytes = 6
    ///  2048 bytes (1024 collected data values) per packet
    case send2048Bytes = 7
}

///  Use to set the color of the LED
public enum LedColor : Int {
    ///  Set the LED off
    case black = 0
    ///  Set the LED to a blue color
    case blue = 1
    ///  Set the LED to a green color
    case green = 2
    ///  Set the LED to a cyan color
    case cyan = 3
    ///  Set the LED to a red color
    case red = 4
    ///  Set the LED to a magenta color
    case magenta = 5
    ///  Set the LED to a yellow color
    case yellow = 6
    ///  Set the LED to a white color
    case white = 7
}


///  The structure returned to the scanning closure that contains the data collected
public struct DATAQ_2108_Data {
    /// The data packet number.  Set to 0 when scanning started.  Incremented with each return packet
    public let packetNumber : Int
    ///  The counts for analog input channel 0, or nil if channel not enabled
    public let analogCount0 : Int?
    ///  The counts for analog input channel 1, or nil if channel not enabled
    public let analogCount1 : Int?
    ///  The counts for analog input channel 2, or nil if channel not enabled
    public let analogCount2 : Int?
    ///  The counts for analog input channel 3, or nil if channel not enabled
    public let analogCount3 : Int?
    ///  The counts for analog input channel 4, or nil if channel not enabled
    public let analogCount4 : Int?
    ///  The counts for analog input channel 5, or nil if channel not enabled
    public let analogCount5 : Int?
    ///  The counts for analog input channel 6, or nil if channel not enabled
    public let analogCount6 : Int?
    ///  The counts for analog input channel 7, or nil if channel not enabled
    public let analogCount7 : Int?
    ///  The state of the digital inputs or nil if no digital input is enabled
    public let digitalState : UInt8?
    ///  The counts for the rate value, or nil if the rate input is not enabled
    public let rateCount : Int?
    ///  The value for the counter, or nil if the count input is not enabled
    public let countValue : Int?
    let rangeValue : RateMaximumFrequency
    
    ///  Return the voltage value for the specified analog input, or nil if the channel is not enabled
    ///
    ///   - parameter channel: The channel number for the analog input (0-7)
    /// - Returns: A voltage for the channel, or nil if the channel is not enabled for the scan list
    public func getAnalogVoltage(channel: Int) -> Double? {
        if (channel < 0 || channel > 7) { return nil }

        switch (channel) {
        case 0:
            if (analogCount0 == nil) { return nil}
            return 10.0 * Double(analogCount0!) / 32768.0
        case 1:
            if (analogCount1 == nil) { return nil}
            return 10.0 * Double(analogCount1!) / 32768.0
        case 2:
            if (analogCount2 == nil) { return nil}
            return 10.0 * Double(analogCount2!) / 32768.0
        case 3:
            if (analogCount3 == nil) { return nil}
            return 10.0 * Double(analogCount3!) / 32768.0
        case 4:
            if (analogCount4 == nil) { return nil}
            return 10.0 * Double(analogCount4!) / 32768.0
        case 5:
            if (analogCount5 == nil) { return nil}
            return 10.0 * Double(analogCount5!) / 32768.0
        case 6:
            if (analogCount6 == nil) { return nil}
            return 10.0 * Double(analogCount6!) / 32768.0
        default:
            if (analogCount7 == nil) { return nil}
            return 10.0 * Double(analogCount7!) / 32768.0
        }
    }
    
    ///  Return the frequency value for the rate input, or nil if the rate input is not enabled
    ///
    /// - Returns: A frequency determined from the input
    public func getRateFrequency() -> Double? {
        if (rateCount == nil) { return nil }
        
        var range : Double
        switch (rangeValue) {
        case .Hz50000:
            range = 50000.0
        case .Hz20000:
            range = 20000.0
        case .Hz10000:
            range = 10000.0
        case .Hz5000:
            range = 5000.0
        case .Hz2000:
            range = 2000.0
        case .Hz1000:
            range = 1000.0
        case .Hz500:
            range = 500.0
        case .Hz200:
            range = 200.0
        case .Hz100:
            range = 100.0
        case .Hz50:
            range = 50.0
        case .Hz20:
            range = 20.0
        case .Hz10:
            range = 10.0

        }
        
        return Double(rateCount! + 32768) * range / 65536.0
    }
}

private enum ScanListEntry {
    case analog(index : Int)
    case digitals
    case rate
    case count
}

///  The main interface class for communicating with the DATAQ 2108 device
open class DATAQ_2108 {
    static let vendorID: Int16 = 0x0683
    static let productID: Int16 = 0x2108
    
    ///  Static function to find the first DATAQ 2108 device, connect to it, and return a DATAQ_2108 class instance for it
    ///
    /// - Returns: A DATAQ_2108 class for the device, or nil if no device is found
    public static func OpenFirstFoundModule() -> DATAQ_2108? {
        if let usbDevice = SwiftUSB.OpenDevice(vendorID: vendorID, productID: productID) {
            return DATAQ_2108(device: usbDevice)
        }
        return nil
    }
    
    var analog_Enabled = [Bool](repeating: false, count: 8)
    var digital_Enabled = [Bool](repeating: false, count: 7)
    var rate_Enabled = false
    var count_Enabled = false
    var scanning = false

    let device : SwiftUSB
    init(device: SwiftUSB) {
        self.device = device
    }
    
    ///  Enables the specified analog input channel

    ///   - parameter channel: The channel number for the analog input (0-7)

    /// - Throws: `DATAQ_Interface_Error.invalidAnalogIndex` if the channel is outside of 0 through 7
    /// - Throws: `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    public func enableAnalogInput(channel: Int) throws {
        if (channel < 0 || channel > 7) { throw DATAQ_Interface_Error.invalidAnalogIndex }
        
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        analog_Enabled[channel] = true
    }
    
    ///  Disables the specified analog channel
    ///
    ///   - parameter channel: The channel number for the analog input (0-7)
    /// - Throws:
    ///   - `DATAQ_Interface_Error.invalidAnalogIndex` if the channel is outside of 0 through 7
    ///   - `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    public func disableAnalogInput(channel: Int) throws {
        if (channel < 0 || channel > 7) { throw DATAQ_Interface_Error.invalidAnalogIndex }
        
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        analog_Enabled[channel] = false
    }
    
    ///  Enables digital inputs in the scan list, and sets the specified digital port to an input
    ///
    ///   - parameter index: The index number for the digital input (0-6)
    /// - Throws:
    ///   - `DATAQ_Interface_Error.invalidDigitalIndex` if the index is outside of 0 through 6
    ///   - `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    public func enableDigitalInput(index: Int) throws {
        if (index < 0 || index > 6) { throw DATAQ_Interface_Error.invalidDigitalIndex }
        
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        digital_Enabled[index] = true
    }
    
    ///  Sets the specified digital port to an output, and if no digital inputs, removes digitals from the scan list
    ///
    ///   - parameter index: The index number for the digital input (0-6)
    /// - Throws:
    ///   - `DATAQ_Interface_Error.invalidDigitalIndex` if the index is outside of 0 through 6
    ///   - `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    public func disableDigitalInput(index: Int) throws {
        if (index < 0 || index > 6) { throw DATAQ_Interface_Error.invalidDigitalIndex }
        
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        digital_Enabled[index] = false
    }
    
    var maxFreq = RateMaximumFrequency.Hz1000
    
    ///  Adds the rate input to the scan list
    ///
    ///   - parameter maxFrequency: The maximum frequency range for the rate input
    /// - Throws:
    ///   - `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    public func enableRateInput(maxFrequency: RateMaximumFrequency) throws {
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        rate_Enabled = true
        maxFreq = maxFrequency
    }
    
    ///  Removes the rate input from the scan list
    ///
    /// - Throws: `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    public func disableRateInput() throws {
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        rate_Enabled = false
    }
    
    ///  Adds the count input to the scan list
    ///
    /// - Throws: `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    public func enableCountInput() throws {
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        count_Enabled = true
    }
    
    ///  Removes the count input from the scan list
    ///
    /// - Throws: `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    public func disableCountInput() throws {
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        count_Enabled = false
    }
    
    func countReturnWords() -> Int {
        //  Count the number of enabled inputs
        var count = count_Enabled ? 1 : 0
        count += rate_Enabled ? 1 : 0
        count += digital_Enabled.reduce(false, {anyEnabled, enabled in anyEnabled || enabled } ) ? 1 : 0
        count += analog_Enabled.reduce(0, {count, enabled in count + (enabled ? 1 : 0) } )
        return count
    }

    
    var scanRateSetting = 60000
    var decimationFactor = 1
    var analogFilterType = AnalogInputHandling.lastPoint
    ///  Sets the desired data rate from the device when scanning
    ///
    ///   - parameter hertz: The desired data rate
    /// - Throws:
    ///   - `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    ///   - `DATAQ_Interface_Error.dataRateAboveMaximum` if the requested data rate is higher than the device can be configured for
    ///   - `DATAQ_Interface_Error.dataRateBelowMinimum` if the requested data rate is lower than the device can be configured for
    /// - Returns: The actual expected data frequency
    public func setDataRate(hertz: Double) throws -> Double {
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        //  Count the number of enabled inputs
        let count = countReturnWords()
        
        //  If none enabled, we won't get data back
        if (count == 0) { throw DATAQ_Interface_Error.noInputsConfigured }
        
        //  Get the nearest setting for this
        let scanRate = Int((60000000.0 / hertz) + 0.5)
        if (scanRate > 655356) { throw DATAQ_Interface_Error.dataRateAboveMaximum}
        if (scanRate < 375) { throw DATAQ_Interface_Error.dataRateBelowMinimum}
        
        //  Remember the settings
        scanRateSetting = scanRate

        //  Return the actual data frequency
        return 60000000.0 / Double(scanRateSetting)
    }
    
    ///  Sets the analog input filter parameters
    ///
    ///   - parameter decimationWindow: The number of samples to be used in the filter
    ///   - parameter analogProcessing: The type of filtering to be done to (all) analog inputs
    /// - Throws: `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    public func setAnalogFilter(decimationWindow: Int, analogProcessing: AnalogInputHandling) throws {
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        //  Remember the settings
        decimationFactor = decimationWindow
        analogFilterType = analogProcessing
    }
    
    var returnPacketSize = ReturnPacketSize.send256Bytes
    ///  Sets the size of the return data packets
    ///
    ///   - parameter packetSize: The size of each returned data packet
    /// - Throws: `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    /// - Returns: The number of data collections that will fit into one returned packet
    public func setPacketSize(packetSize: ReturnPacketSize) throws -> Double {
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        returnPacketSize = packetSize
        
        //  Calculate the number of data packets per send
        let count = countReturnWords()
        if (count == 0) { return 0.0 }
        let words = (8 << packetSize.rawValue)
        return Double(words) / Double(count)
    }
    
    private func writeCommand(command: String, getEcho: Bool = true) {
        //  Convert the command into a Data object
        let terminatedString = command + "\r"
        if let data = terminatedString.data(using: .utf8) {
            device.SendBulkData(to: .Interface, data: data)
            
            //  If we should get the echo, do so
            if (getEcho) {
                if let echo = device.GetBulkData(from: .Interface, maxLength: data.count + 16) {
                    if (echo.count == data.count || echo.count == data.count + 1) { return }    //  Allow for null terminator to be sent back
                }
                print("Failed getting echo")
            }
        }
    }
    
    fileprivate var scanList : [ScanListEntry] = []
    ///  Starts scanning
    ///
    ///   - parameter closure: The closure to be called with each returned data set
    /// - Throws: `DATAQ_Interface_Error.cannotConfigureWhileScanning` if the device is currently in scan mode
    open func startScanning(_ closure:@escaping (_ data: DATAQ_2108_Data) -> Bool) throws {
        if (scanning) { throw DATAQ_Interface_Error.cannotConfigureWhileScanning }
        
        //  Validate that we have inputs
        let count = countReturnWords()
        if (count == 0) { throw DATAQ_Interface_Error.noInputsConfigured }
        
        //  Set up the scan list
        var scanListIndex = 0
        scanList = []
        
        //  Add each enabled analog to the scan list
        var haveAnalogs = false
        for index in 0..<8 {
            if (analog_Enabled[index]) {
                let command = "slist \(scanListIndex) \(index)"
                writeCommand(command: command)
                scanList.append(.analog(index: index))
                scanListIndex += 1
                haveAnalogs = true
            }
        }
        
        //  If any digitals are enabled, add them to the scan list
        var outputs = 0
        for index in 0..<7 {
            if (!digital_Enabled[index]) {
                outputs += (1 << index)
            }
        }
        var command = "endo \(outputs)"
        writeCommand(command: command)
        if (outputs != 127) {
            command = "slist \(scanListIndex) 8"
            writeCommand(command: command)
            scanList.append(.digitals)
            scanListIndex += 1
        }
        
        //  If the rate is enabled, add that
        if (rate_Enabled) {
            let rateWithRange = 9 + (maxFreq.rawValue * 256)
            command = "slist \(scanListIndex) \(rateWithRange)"
            writeCommand(command: command)
            scanList.append(.rate)
            scanListIndex += 1
        }
        
        //  If the counter is enabled, add that
        if (count_Enabled) {
            command = "slist \(scanListIndex) 10"
            writeCommand(command: command)
            scanList.append(.count)
            scanListIndex += 1
        }
        
        //  Set the scan rate
        command = "srate \(scanRateSetting)"
        writeCommand(command: command)
        
        //  Set the filter, if there are analogs
        if (haveAnalogs) {
            command = "filter * \(analogFilterType.rawValue)"
            writeCommand(command: command)

            //  Set the decimation factor
            command = "dec \(decimationFactor)"
            writeCommand(command: command)
        }
        
        //  Set the packet size
        command = "ps \(returnPacketSize.rawValue)"
        writeCommand(command: command)

        //  Start the scanning
        writeCommand(command: "start 0", getEcho: false)
        scanning = true
        
        //  Calculate the packet time
        let dataFrequency = 60000000.0 / Double(scanRateSetting)
        let words = (8 << returnPacketSize.rawValue)
        let packetFrequency = dataFrequency * Double(count) / Double(words)
        
        //  Get a timeout value (3 times packet freq, or 5 seconds - whichever is larger
        var timeout = Int(3000.0 / packetFrequency)
        if (timeout < 5000) { timeout = 5000 }
        
        //  Set up a read loop in another thread
        let queue = DispatchQueue(label: "DATAQ_USBReadQueue")
        queue.async {
            var returnListEntry = 0
            let bytesInPacket = words * 2
            var packetCount = 0
            
            var analog0 : Int? = nil
            var analog1 : Int? = nil
            var analog2 : Int? = nil
            var analog3 : Int? = nil
            var analog4 : Int? = nil
            var analog5 : Int? = nil
            var analog6 : Int? = nil
            var analog7 : Int? = nil
            var digitals : UInt8? = nil
            var rate : Int? = nil
            var countValue : Int? = nil

            while (self.scanning) {
                //  Get the next response from the device
                if let data = self.device.GetBulkData(from: .Interface, maxLength: bytesInPacket, timeout: timeout) {
                    if (data.count == 0) { continue }
                    //  Extract the data
                    data.withUnsafeBytes { ptr in
                        guard var shortValues = ptr.baseAddress?.assumingMemoryBound(to: Int16.self) else {
                            //  We should always be able to get the address of our data
                            fatalError()
                        }
                        for _ in 0..<words {
                            let short = shortValues.pointee
                            shortValues += 1
                            switch (self.scanList[returnListEntry]) {
                            case .analog(let index):
                                switch (index) {
                                case 0:
                                    analog0 = Int(short)
                                case 1:
                                    analog1 = Int(short)
                                case 2:
                                    analog2 = Int(short)
                                case 3:
                                    analog3 = Int(short)
                                case 4:
                                    analog4 = Int(short)
                                case 5:
                                    analog5 = Int(short)
                                case 6:
                                    analog6 = Int(short)
                                case 7:
                                    analog7 = Int(short)
                                default:
                                    break
                                }
                            case .digitals:
                                digitals = UInt8(short >> 8)
                            case .rate:
                                rate = Int(short)
                            case .count:
                                countValue = Int(short)
                            }
                            
                            //  Advance to next scan list entry
                            returnListEntry += 1
                            if (returnListEntry >= count) {
                                //  end of scan list - send the data structure back to the callback enclosure and reset the list
                                returnListEntry = 0
                                                                
                                //  Create the data structure
                                let dataStruct = DATAQ_2108_Data(packetNumber: packetCount, analogCount0: analog0, analogCount1: analog1, analogCount2: analog2, analogCount3: analog3, analogCount4: analog4, analogCount5: analog5, analogCount6: analog6, analogCount7: analog7, digitalState: digitals, rateCount: rate, countValue: countValue, rangeValue: self.maxFreq)
                                packetCount += 1
                                
                                //  Call the closure with the data
                                if (!closure(dataStruct)) {
                                    do {
                                        try self.stopScanning()
                                    }
                                    catch {
                                        //  We should be scanning when we get here
                                        fatalError()
                                    }
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    ///  Stops scanning
    ///
    /// - Throws: `DATAQ_Interface_Error.notScanning` if the device is currently in not in scan mode
    open func stopScanning() throws {
        if (!scanning) { throw DATAQ_Interface_Error.notScanning }
        
        //  Send the stop command
        writeCommand(command: "stop")

        scanning = false
    }
    
    ///  Set the state of all digital outputs
    ///
    ///   - parameter states: The bit encoded value for the digital channels
    open func setDigitalOutputs(states : UInt8) {
        //  Send the dout command
        writeCommand(command: "dout \(Int(states))", getEcho: !scanning)
    }
    
    ///  Set the color ot the LED
    ///
    ///   - parameter color: The color to set the LED to
    open func setLedColor(color : LedColor) {
        //  Send the led command
        writeCommand(command: "led \(color.rawValue)", getEcho: !scanning)
    }
}
