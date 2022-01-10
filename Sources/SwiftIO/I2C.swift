//=== I2C.swift -----------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 05/09/2021
// Updated: 11/05/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO

/**
 I2C (I square C) is a two wire protocol to communicate between different
 devices. The I2C class allows some operations through I2C protocol, including
 reading messages from a device and writing messages to a device.
 Currently the I2C ports support only master mode.
 
 - Note:
 Different I2C devices have different attributes. Please reference the device
 manual before using the functions below.
 This class allows the reading and writing of a byte `UInt8` or an array of
 bytes `[UInt8]`.

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
     Initialize a specific I2C interface as a master device.
     - Parameter idName: **REQUIRED** The name of the I2C interface.
     - Parameter speed: **OPTIONAL** The clock speed used to control the data
        transmission.
     
     ### Usage Example ###
     ````
     // Initialize an I2C interface I2C0.
     let i2cBus = I2C(Id.I2C0)
     ````
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
     Get the current clock speed of the data transmission.
     
     - Returns: The current speed: `.standard`, `.fast` or `.fastPlus`.
     */
    public func getSpeed() -> Speed {
        return speed
    }

    /**
     Set the clock speed to change the transmission rate.
     - Parameter speed: The clock speed used to control the data transmission.
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

    /**
     Read an array of data from a specified slave device with the given address.
     - Parameter count : The number of bytes to read.
     - Parameter address : The address of the slave device the board will
        communicate with.
     
     - Returns: An array of 8-bit binary numbers receiving from the slave device.
     */
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

    /**
     Read an array of data from a specified slave device with the given address.
     - Parameter count : The number of bytes to read.
     - Parameter address : The address of the slave device the board will
        communicate with.
     
     - Returns: An array of 8-bit binary numbers receiving from the slave device.
     */
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

    /**
     Write a byte of data to a specified slave device with the given address.
     - Parameter byte : One 8-bit binary number to be sent to the slave device.
     - Parameter address : The address of the slave device the board will
        communicate with.
     */
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

    /**
     Write an array of data to a specified slave device with the given address.
     - Parameter data : A byte array to be sent to the slave device.
     - Parameter address : The address of the slave device the board will
        communicate with.
     */
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

    @discardableResult
    public func writeRead(
        _ byte: UInt8,
        into buffer: inout UInt8,
        address: UInt8
    ) -> Result<(), Errno> {
        let result = nothingOrErrno(
            swifthal_i2c_write_read(obj,
                                    address,
                                    [byte],
                                    1,
                                    &buffer,
                                    1)
        )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }

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
                swifthal_i2c_write_read(obj,
                                        address,
                                        [byte],
                                        1,
                                        &buffer,
                                        Int32(readLength))
            )
        }
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }


    /**
     Write an array of bytes to the slave device with the given address
     and then read the bytes sent from the device.
     - Parameter data : A byte array to be sent to the slave device.
     - Parameter readCount : The number of bytes to read.
     - Parameter address : The address of the slave device the board will
        communicate with.
     
     - Returns: An array of 8-bit binary numbers receiving from the slave device.
     */
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
     The clock signal is used to synchronize the data transmission between the devices.There are three available speed grades.
     */
    public enum Speed {
        case standard
        case fast
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
