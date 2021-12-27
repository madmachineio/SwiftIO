//=== SPI.swift -----------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 05/09/2021
// Updated: 12/09/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO

/**
 SPI is a four wire serial protocol for communication between devices.
  
 */
 public final class SPI {

    private let id: Int32
    private let obj: UnsafeMutableRawPointer 

    private var speed: Int32
    private var operation: Operation
    private var csPin: DigitalOut?

    public var cs: Bool {
        return csPin != nil
    }

    /**
     Initialize a specified interface for SPI communication as a master device.
     - Parameter id: **REQUIRED** The name of the SPI interface.
     - Parameter speed: **OPTIONAL** The clock speed used to control the data
        transmission.
     - Parameter csPin: **OPTIONAL** If the csPin is nil, you have to control
        it manually through any DigitalOut pin.
     
     ### Usage Example ###
     ````
     // Initialize a SPI interface SPI0.
     let spi = SPI(Id.SPI0)
     ````
     */
    public init(
        _ idName: IdName,
        speed: Int = 5_000_000,
        csPin: DigitalOut? = nil,
        CPOL: Bool = false,
        CPHA: Bool = false,
        bitOrder: BitOrder = .MSB

    ) {
        self.id = idName.value
        self.speed = Int32(speed)
        self.csPin = csPin
        self.operation = .eightBits

        if CPOL {
            operation.insert(.CPOL)
        }

        if CPHA {
            operation.insert(.CPHA)
        }

        switch bitOrder {
        case .MSB:
            // MSB bit equal zero 
            // operation.insert(.MSB)
            break
        case .LSB:
            operation.insert(.LSB)
        }

        if let ptr = swifthal_spi_open(id, self.speed, operation.rawValue, nil, nil) {
            if let cs = csPin {
                cs.setMode(.pushPull)
                cs.write(true)
            }
            obj = UnsafeMutableRawPointer(ptr)
        } else {
            fatalError("SPI \(idName.value) init failed!")
        }

        var syncByte: UInt8 = 0
        swifthal_spi_read(obj, &syncByte, 1)
    }

    deinit {
        swifthal_spi_close(obj)
    }

    @inline(__always)
    func csEnable() {
        csPin?.write(false)
    }

    @inline(__always)
    func csDisable() {
        csPin?.write(true)
    }

    /**
     Get the current clock speed of SPI communication.
     
     - Returns: The current clock speed.
     */
    public func getSpeed() -> Int {
        return Int(speed)
    }

    /** 
     Set the speed of SPI communication.
     - Parameter speed: The clock speed used to control the data transmission.
     
     */
    @discardableResult
    public func setSpeed(_ speed: Int) -> Result<(), Errno> {
        let result = nothingOrErrno(
            swifthal_spi_config(obj, Int32(speed), operation.rawValue)
        )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        } else {
            self.speed = Int32(speed)
            var syncByte: UInt8 = 0
            swifthal_spi_read(obj, &syncByte, 1)
        }

        return result
    }
    
    public func setMode(
        CPOL: Bool,
        CPHA: Bool,
        bitOrder: BitOrder? = nil
    ) -> Result<(), Errno> {
        var newOperation: Operation = .eightBits

        if CPOL {
            newOperation.insert(.CPOL)
        }
        if CPHA {
            newOperation.insert(.CPHA)
        }

        if let bitOrder = bitOrder {
            switch bitOrder {
            case .MSB:
                // MSB bit equal zero 
                // newOperation.insert(.MSB)
                break
            case .LSB:
                newOperation.insert(.LSB)
            }
        } else {
            // MSB bit equal zero 
            // if operation.contains(.MSB) {
            //     newOperation.insert(.MSB)
            // }
            if operation.contains(.LSB) {
                newOperation.insert(.LSB)
            }
        }

        let result = nothingOrErrno(
            swifthal_spi_config(obj, speed, newOperation.rawValue)
        )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        } else {
            operation = newOperation
            var syncByte: UInt8 = 0
            swifthal_spi_read(obj, &syncByte, 1)
        }

        return result
    }

    public func getMode() -> (CPOL: Bool, CPHA: Bool, bitOrder: BitOrder) {
        let cpol = operation.contains(.CPOL)
        let cpha = operation.contains(.CPHA)
        let bitOrder: BitOrder
        // Never reverse the sequence!!!
        if operation.contains(.LSB) {
            bitOrder = .LSB
        } else {
            bitOrder = .MSB
        }

        return (cpol, cpha, bitOrder)
    }

    @discardableResult
    public func read(into byte: inout UInt8) -> Result<(), Errno> {
        csEnable()
        let result = nothingOrErrno(
            swifthal_spi_read(obj, &byte, 1)
        )
        csDisable()

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }

    /**
     Read an array of data from the slave device.
     - Parameter count: The number of bytes receiving from the slave device.
     - Returns: An array of 8-bit binary numbers receiving from the slave device.
     */
    @discardableResult
    public func read(into buffer: inout [UInt8], count: Int? = nil) -> Result<(), Errno> {

        let readLength: Int

        if let count = count {
            readLength = min(count, buffer.count)
        } else {
            readLength = buffer.count
        }

        csEnable()
        let result = nothingOrErrno(
            swifthal_spi_read(obj, &buffer, Int32(readLength))
        )
        csDisable()

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }

    @discardableResult
    public func read(into buffer: UnsafeMutableBufferPointer<UInt8>, count: Int? = nil) -> Result<(), Errno> {

        let readLength: Int

        if let count = count {
            readLength = min(count, buffer.count)
        } else {
            readLength = buffer.count
        }

        csEnable()
        let result = nothingOrErrno(
            swifthal_spi_read(obj, buffer.baseAddress, Int32(readLength))
        )
        csDisable()

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }

    /**
     Write a byte of data to the slave device.
     - Parameter byte: One 8-bit binary number to be sent to the slave device.
     */
    @discardableResult
    public func write(_ byte: UInt8) -> Result<(), Errno> {
        var byte = byte

        csEnable()
        let result = nothingOrErrno(
            swifthal_spi_write(obj, &byte, 1)
        )
        csDisable()
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }
        return result
    }

    /**
     Write an array of data to the slave device.
     - Parameter data: A byte array to be sent to the slave device.
     */
    @discardableResult
    public func write(_ data: [UInt8], count: Int? = nil) -> Result<(), Errno> {
        let writeLength: Int

        if let count = count {
            writeLength = min(data.count, count)
        } else {
            writeLength = data.count
        }

        csEnable()
        let result = nothingOrErrno(
            swifthal_spi_write(obj, data, Int32(writeLength))
        )
        csDisable()

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }

    /**
     Write an buffer of data to the slave device.
     - Parameter data: A UInt8 buffer to be sent to the slave device.
     */
    @discardableResult
    public func write(_ data: UnsafeBufferPointer<UInt8>, count: Int? = nil) -> Result<(), Errno> {
        let writeLength: Int

        if let count = count {
            writeLength = min(data.count, count)
        } else {
            writeLength = data.count
        }

        csEnable()
        let result = nothingOrErrno(
            swifthal_spi_write(obj, data.baseAddress, Int32(writeLength))
        )
        csDisable()

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }

    public func transceive(_ byte: UInt8, into buffer: inout [UInt8], readCount: Int? = nil) -> Result<(), Errno> {
        var byte = byte
        let readLength: Int

        if let count = readCount {
            readLength = min(buffer.count, count)
        } else {
            readLength = buffer.count
        }

        csEnable()
        let result = nothingOrErrno(
            swifthal_spi_transceive(obj, &byte, 1, &buffer, Int32(readLength))
        )
        csDisable()

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }


    public func transceive(
            _ data: [UInt8],
            writeCount: Int? = nil,
            into buffer: inout [UInt8],
            readCount: Int? = nil
        ) -> Result<(), Errno> {
        let writeLength, readLength: Int

        if let count = writeCount {
            writeLength = min(count, data.count)
        } else {
            writeLength = data.count
        }

        if let count = readCount {
            readLength = min(count, buffer.count)
        } else {
            readLength = buffer.count
        }

        csEnable()
        let result = nothingOrErrno(
            swifthal_spi_transceive(obj, data, Int32(writeLength), &buffer, Int32(readLength))
        )
        csDisable()

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return result
    }
}


extension SPI {
    public enum BitOrder {
        case MSB
        case LSB
    }

    private struct Operation: OptionSet {
        let rawValue: UInt16

        static let CPOL         = Operation(rawValue: UInt16(SWIFT_SPI_MODE_CPOL))
        static let CPHA         = Operation(rawValue: UInt16(SWIFT_SPI_MODE_CPHA))
        static let MSB          = Operation(rawValue: UInt16(SWIFT_SPI_TRANSFER_MSB))
        static let LSB          = Operation(rawValue: UInt16(SWIFT_SPI_TRANSFER_LSB))

        static let eightBits    = Operation(rawValue: 8 << 5)
    }
}