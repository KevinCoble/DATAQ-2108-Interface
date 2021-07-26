//
//  DATAQ_2108_InterfaceTests.swift
//  DATAQ-2108 InterfaceTests
//
//  Created by Kevin Coble on 7/15/21.
//

import XCTest
@testable import DATAQ_2108_Interface

class DATAQ_2108_InterfaceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        //  Find the first connected device
        if let module = DATAQ_2108.OpenFirstFoundModule() {
            do {
                //  Enable analog channel 0
                try module.enableAnalogInput(channel: 0)
                
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
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
