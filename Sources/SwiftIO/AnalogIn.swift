//=== AnalogIn.swift ------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 05/09/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO

/**
 The AnalogIn class reads external voltage from an analog input pin, which 
 functions like a multimeter for measuring input values.

 
 At first, initialize a pin as an AnalogIn pin. A physical pin may be connected
 to various internal peripherals and thus serve multiple functionalities.
 You need to identify the specific pin using its id and specify the pin's
 functionality before using it.
 - `AnalogIn` tells the pin's usage.
 - `Id.A0` defines which pin is used. You may refer to the board's pinout
 which shows all pins and their corresponding usages.

 ```swift
 let pin = AnalogIn(Id.A0)
 ```
 
 ### Example: Read and print the analog input value
 
 ```swift
 // Import the SwiftIO to use the related board functions.
 import SwiftIO
 // Import the MadBoard to decide which pin is used for the specific function.
 import MadBoard
 
 // Initialize an AnalogIn to analog pin A0.
 let pin = AnalogIn(Id.A0)
 
 // Read and print the analog input value every second.
 while true {
     var value = pin.readVoltage()
     print("The analog input volatge is \(value)")
     sleep(ms: 1000)
 }
 ```
 
 */
public final class AnalogIn {
    private let id: Int32
    private let obj: UnsafeMutableRawPointer

    private let info: swift_adc_info_t

    /**
     The number of bits in the absolute value of the ADC.
     Different ADC has different resolutions.
     The max raw value of an 8-bit ADC is 255 and that one of a 10-bit ADC is
     4095.

     */
    public var resolutionBits: Int {
        info.resolution
    }

    /**
     The max raw value of the ADC. It depends on ADC resolution,
     i.e. 255 for an 8-bit ADC and 4095 for a 12-bit ADC.

     */
    public var maxRawValue: Int {
        1 << info.resolution - 1
    }

    /**
     The reference voltage of the ADC.

     */
    public var refVoltage: Float {
        info.ref_voltage
    }

    /**
     Initializes a specified pin as AnalogIn.
     
     - Parameter idName: **REQUIRED** Name/label for a physical pin which is
     associated with the AnalogIn peripheral. See Id for the board in
    [MadBoards](https://github.com/madmachineio/MadBoards) library for reference.
     
     To initialize an analog pin, only the pin name is required. Take pin A0 for
     example, the prefix A tells the functionality of the pin, that is, AnalogIn.
     The number 0 locates the pin.
     ```swift
     // Initialize an analog pin A0.
     let pin = AnalogIn(Id.A0)
     ```
     */
    public init(_ idName: IdName) {
        id = idName.value
        if let ptr = swifthal_adc_open(id) {
            obj = ptr
        } else {
            fatalError("AnalogIn \(idName.value) init failed")
        }
        var _info = swift_adc_info_t()
        swifthal_adc_info_get(obj, &_info)
        info = _info
    }

    deinit {
        swifthal_adc_close(obj)
    }

    /**
     Reads the raw value representing the analog voltage level on the specified pin.

     The raw value is the direct output of the ADC without any additional processing.
     For n-bit ADCs, the raw value will be in the range of 0 to 2^n, which can be
     calculated into actual voltage: (raw value / 2^n) x reference voltage.

     - Returns: A raw value in the range of 0 to 2^n - 1 (for n-bit resolution).
     */
    public func readRawValue() -> Int {
        var sample: UInt16 = 0

        let result = nothingOrErrno(
            swifthal_adc_read(obj, &sample)
        )

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return Int(sample)
    }

    /**
     Reads the raw value representing the analog voltage level on the specified pin. 
     It's the same as `readRawValue()`.

     - Returns: A raw value in the range of 0 to 2^n - 1 (for n-bit resolution).
     */
    @inlinable
    public func read() -> Int {
        return readRawValue()
    }

    /**
     Read the percentage of current input in relation to the max value from a
     specified analog pin.

     - Returns: A percentage of input value in relation to the max value,
     0.0 to 1.0.
     */
    public func readPercentage() -> Float {
        let rawValue = Float(readRawValue())
        return rawValue / Float(maxRawValue)
    }

    /**
     Reads the input voltage from a specified analog pin.
     
     - Returns: A float value in the range of 0.0 to the reference voltage.
     */
    public func readVoltage() -> Float {
        let rawValue = Float(readRawValue())
        return refVoltage * rawValue / Float(maxRawValue)
    }
}
