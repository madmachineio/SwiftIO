//=== I2C.swift -----------------------------------------------------------===//
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
 Inter-Integrated Circuit, I2C (I squared C) for short, is a two wire protocol for
 short distance communication between different devices.

 The I2C class allows some operations through I2C protocol, including reading messages from devices and writing messages to devices. The messages are in the form of
 a byte (`UInt8`) or an array of bytes (`[UInt8]`). Currently the I2C class
 only support master mode.
 
 - Note: Different I2C devices have different attributes. Please reference their
 device manual for detailed configuration.

 ### Initialize an I2C interface:

 For example, initialize the pin I2C0 for communication:

 ```swift
 // Initialize an I2C interface with its speed set to default.
 let i2c = I2C(Id.I2C0)
 ```
 Each I2C interface consists of a SCL (serial clock) and SDA (serial data). So I2C0
 refers to the pin SCL0 and SDA0 on your board.

 Besides, the supported clock speed for different devices may not be the same.
 Make sure to configure it according to datasheet. By default, it is standard
 mode (100kbps).

 ### Read or write data

 After initializing an I2C instance, to read or write data, use the related
 methods in the class.

 For example, read a byte from a device:

 ```swift
 var byte: UInt8 = 0
 i2c.read(into: &byte, from: ...)
 ```
 The address to read from is the desired device address. If several devices are
 connected, only the device with that address will respond. The address of each
 device is written on its manual and defined when the devices are manufactured.

 The statements above allow you to get data and replace the `byte` with the new data received.

 If you want to write a byte to a device:

 ```swift
 let value: UInt8 = ...
 i2c.write(value, to: ...)
 ```
 No matter how many data is sent or received, they are all in UInt8.


 ### Read or write data and handle error

 In fact, the communication may fail due to all kinds of reason. You will
 thus get wrong data. So the methods involving reading or writing data will
 return the results in `Result` type. You can capture the error and provide
 other solutions in advance.

 ```swift
 // Read a byte from the provided address and get the results.
 let result = i2c.read(into: &byte, from: ...)

 if case .failure(let err) = result {
     // If the communication fails, execute the specified task.
     ...
 }
 ```
 If the data is successfully read, it is stored in `byte`. If the communication
 fails, the `byte` may store a wrong value or remain unchanged, anyway, it is useless.
 You can check the `result` to know what happens, and furthermore, handle the error.


 ### Example 1: Write and read data via I2C bus

 ```swift
 // Import the SwiftIO to use the related board functions.
 import SwiftIO
 // Import the MadBoard to decide which pin is used for the specific function.
 import MadBoard

 // Initialize an I2C interface.
 let i2c = I2C(Id.I2C0)

 // The address of the slave device.
 let address = 0x44

 // Send data to the device.
 var result = i2c.write([0x24, 0x0B], to: address)
 if case .failure(let err) = result {
     ...
 }

 // Read data from the device and store them in the buffer.
 var readBuffer = [UInt8](repeating: 0, count: 6)
 result = i2c.read(into: &readBuffer, from: address)
 if case .failure(let err) = result {
    ...
 }
 ```

 ### Example 2: Read temperature using SHT3x library

 ```swift
 import SwiftIO
 import MadBoard
 // Import the device driver to communicate with the sensor with the provided functions.
 import SHT3x

 // Initialize the I2C interface and use it to initialize the sensor.
 let i2c = I2C(Id.I2C0)
 let sht = SHT3x(i2c)

 // Read the temperature and humidity and print their values out.
 // Stop for 1s and repeat it.
 while true {
     let temp = sht.readCelsius()
     print("Temperature: \(temp)C")
     sleep(ms: 1000)
 }
 ```

 In this example, you can talk to the sensor without caring about the details
 of I2C communication as Example 1. The library [SHT3x](https://github.com/madmachineio/MadDrivers/blob/main/Sources/SHT3x/SHT3x.swift)
 has configured the sensor by sending and receiving data via I2C bus.
 Therefore, you can directly read temperature using the predefined APIs.

 BTW, you can find more drivers for different devices in [MadDrivers](https://github.com/madmachineio/MadDrivers).

 */
 public final class I2C {
    private let id: Int32
    public let obj: UnsafeMutableRawPointer

    private var speedRawValue: UInt32
    private var speed: Speed {
        willSet {
            speedRawValue = I2C.getSpeedRawValue(newValue)
        }
    }


    /**
     Initializes a specific I2C interface as a master device.

     > Note: Please make sure the communication speed set for the I2C is supported
     by the slave device.

     - Parameter idName: **REQUIRED** The name of I2C pin. See Id for the board in
     [MadBoards](https://github.com/madmachineio/MadBoards) library for reference.
     - Parameter speed: **OPTIONAL** The clock speed for data transmission,
     standard (100 Kbps) by default.

     */
    public init(_ idName: IdName,
                speed: Speed = .standard) {
        self.id = idName.value
        self.speed = speed
        self.speedRawValue = I2C.getSpeedRawValue(speed)

        guard let ptr = swifthal_i2c_open(id) else {
            fatalError("I2C\(idName.value) init failed")
        }
        obj = UnsafeMutableRawPointer(ptr)
        if swifthal_i2c_config(obj, speedRawValue) != 0 {
            fatalError("I2C\(idName.value) init config failed")
        }
    }

    deinit {
        swifthal_i2c_close(obj)
    }

    /**
     Gets the current clock speed of the data transmission.
     
     - Returns: The current speed: `.standard` (100 Kbps), `.fast` (400 Kbps) or `.fastPlus` (1Mbps).
     */
    public func getSpeed() -> Speed {
        return speed
    }

    /**
     Sets the clock speed to change the transmission rate.
     - Parameter speed: The clock speed for data transmission:
     `.standard` (100 Kbps), `.fast` (400 Kbps) or `.fastPlus` (1Mbps).
     */
    public func setSpeed(_ speed: Speed) -> Result<(), Errno> {
        let oldSpeed = self.speed
        self.speed = speed

        let result = nothingOrErrno(
            swifthal_i2c_config(obj, speedRawValue)
        )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            self.speed = oldSpeed
        }

        return result
    }

     /// Reads a byte from the specified slave device with the given address.
     /// - Parameters:
     ///   - byte: A UInt8 variable to store the received data.
     ///   - address: The address of the slave device to communicate with.
     /// - Returns: Whether the communication succeeds. If not, it returns the
     /// specific error.
    @discardableResult
    public func read(
        into byte: inout UInt8,
        from address: UInt8
    ) -> Result<(), Errno> {

        let result = nothingOrErrno(
            swifthal_i2c_read(obj, address, &byte, 1)
        )

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }

     /// Reads bytes from the specified slave device with the given address and
     /// store them in the buffer.
     /// - Parameters:
     ///   - buffer: An array to store the received data.
     ///   - count: The number of data to read. Make sure it doesn’t exceed the
     ///   length of the `buffer`. If it's nil, it equals the length of the `buffer`.
     ///   - address: The address of the slave device to communicate with.
     /// - Returns: Whether the communication succeeds. If not, it returns the
     /// specific error.
    @discardableResult
    public func read(
        into buffer: inout [UInt8],
        count: Int? = nil,
        from address: UInt8
    ) -> Result<(), Errno> {
        var readLength = 0
        var result = validateLength(buffer, count: count, length: &readLength)

        if case .success = result {
            result = nothingOrErrno(
                swifthal_i2c_read(obj, address, &buffer, Int32(readLength))
            )
        }

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }

     /// Writes a UInt8 to the specified slave device with the given address.
     /// - Parameters:
     ///   - byte: A UInt8 to be sent to the slave device.
     ///   - address: The address of the slave device to communicate with.
     /// - Returns: Whether the communication succeeds. If not, it returns the
     /// specific error.
     @discardableResult
    public func write(_ byte: UInt8, to address: UInt8) -> Result<(), Errno> {
        var byte = byte
        let result = nothingOrErrno(
            swifthal_i2c_write(obj, address, &byte, 1)
        )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }
        return result
    }

     /// Writes an array of UInt8 to the specified slave device with the given address.
     /// - Parameters:
     ///   - data: An array of UInt8 to be sent to the slave device.
     ///   - count: The number of elements in `data` to be sent. Make sure it
     ///   doesn’t exceed the length of the `data`. If it's nil, all will be sent.
     ///   - address: The address of the slave device to communicate with.
     /// - Returns: Whether the communication succeeds. If not, it returns the
     /// specific error.
    @discardableResult
    public func write(_ data: [UInt8], count: Int? = nil, to address: UInt8) -> Result<(), Errno> {
        var writeLength = 0
        var result = validateLength(data, count: count, length: &writeLength)

        if case .success = result {
            result = nothingOrErrno(
                swifthal_i2c_write(obj, address, data, Int32(writeLength))
            )
        }

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }

     /// Writes a UInt8 to the specified slave device with the given address and
     /// then read a UInt8 from it.
     ///
     /// > Note: This method is not a simple combination of ``write(_:to:)`` and
     /// ``read(into:from:)`` due to some details of data transmission.
     /// Usually, you can find the info about I2C communication about each device
     /// on its manual.
     /// - Parameters:
     ///   - byte: A UInt8 to be sent to the slave device.
     ///   - buffer: A UInt8 variable to store the received data.
     ///   - address: The address of the slave device to communicate with.
     /// - Returns: Whether the communication succeeds. If not, it returns the specific error.
    @discardableResult
    public func writeRead(
        _ byte: UInt8,
        into buffer: inout UInt8,
        address: UInt8
    ) -> Result<(), Errno> {
        let result = nothingOrErrno(
            swifthal_i2c_write_read(obj, address, [byte], 1, &buffer, 1)
        )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }

     /// Writes a UInt8 to the specified slave device with the given address and
     /// then read bytes from it.
     ///
     /// > Note: This method is not a simple combination of ``write(_:to:)`` and
     /// ``read(into:count:from:)`` due to some details of data transmission.
     /// Usually, you can find the info about I2C communication about each device
     /// on its manual.
     /// - Parameters:
     ///   - byte: A UInt8 to be sent to the slave device.
     ///   - buffer: A UInt8 array to store the received bytes.
     ///   - readCount: The number of bytes to read. Make sure it doesn’t exceed
     ///   the length of the `buffer`. If it’s nil, it equals the length of the `buffer`.
     ///   - address: The address of the slave device to communicate with.
     /// - Returns: Whether the communication succeeds. If not, it returns the specific error.
     @discardableResult
    public func writeRead(
        _ byte: UInt8, 
        into buffer: inout [UInt8],
        readCount: Int? = nil,
        address: UInt8
    ) -> Result<(), Errno> {
        var readLength = 0
        var result = validateLength(buffer, count: readCount, length: &readLength)

        if case .success = result {
            result = nothingOrErrno(
                swifthal_i2c_write_read(obj, address, [byte], 1, &buffer, Int32(readLength))
            )
        }
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }

     /// Writes an array of UInt8 to the slave device with the given address and
     /// then read bytes from it.
     ///
     /// > Note: This method is not a simple combination of ``write(_:count:to:)``
     /// and ``read(into:count:from:)`` due to some details of data transmission.
     /// Usually, you can find the info about I2C communication about each device
     /// on its manual.
     /// - Parameters:
     ///   - data: An array of UInt8 to be sent to the slave device.
     ///   - writeCount: The number of elements in `data` to be sent. Make sure
     ///   it doesn’t exceed the length of the `data`. If it’s nil, all will be sent.
     ///   - buffer: A UInt8 array to store the received bytes.
     ///   - readCount: The number of bytes to read. Make sure it doesn’t exceed
     ///   the length of the `buffer`. If it’s nil, it equals the length of the `buffer`.
     ///   - address: The address of the slave device to communicate with.
     /// - Returns: Whether the communication succeeds. If not, it returns the
     /// specific error.
     @discardableResult
    public func writeRead(
        _ data: [UInt8],
        writeCount: Int? = nil,
        into buffer: inout [UInt8],
        readCount: Int? = nil,
        address: UInt8
    ) -> Result<(), Errno> {
        var writeLength = 0, readLength = 0

        var result = validateLength(data, count: writeCount, length: &writeLength)

        if case .success = result {
            result = validateLength(buffer, count: readCount, length: &readLength)
        }

        if case .success = result {
            result = nothingOrErrno(
                swifthal_i2c_write_read(obj,
                                        address,
                                        data,
                                        Int32(writeLength),
                                        &buffer,
                                        Int32(readLength))
            )
        }
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }
}

extension I2C {
    /**
     The clock speed settings used to synchronize the data transmission between
     devices.
     */
    public enum Speed {
        /// 100 Kbps
        case standard
        /// 400 Kbps
        case fast
        /// 1 Mbps
        case fastPlus
    }

    private static func getSpeedRawValue(_ speed: Speed) -> UInt32 {
        switch speed {
            case .standard:
            return UInt32(SWIFT_I2C_SPEED_STANDARD)
            case .fast:
            return UInt32(SWIFT_I2C_SPEED_FAST)
            case .fastPlus:
            return UInt32(SWIFT_I2C_SPEED_FAST_PLUS)
        }
    }
}
