//=== SPI.swift -----------------------------------------------------------===//
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

/// SPI is a four wire serial protocol for communication between devices.
///
///
/// ### Initialize an SPI instance
///
/// Let's initialize an SPI interface:
/// ```swift
/// // Initialize the pin SPI0 for communication with other parameters set to default.
/// let spi = SPI(Id.SPI0)
/// ```
/// An SPI interface consists of a clock line, two lines for sending and reading data
/// respectively and a CS line. In this case, the pins for SPI are SCK0, SDO0, SDI0.
/// The cs pin is not defined, thus you need to configure it manually: set it to
/// low/high to activate/release it.
///
/// The devices on an SPI bus are distinguished by a CS line. Before communicating
/// with a specified device, its CS line needs to be activated. Other devices
/// connected on the same bus will ignore all data.
///
/// You can also specify the cs pin when initializing an SPI device, so the spi will
/// manage automatically cs when you read or write data.
///
/// ```swift
/// // Initialize the cs pin for the device.
/// let cs = DigitalOut(Id.D0)
/// // Specify the cs pin so it will be set automatically during communication.
/// let spi = SPI(Id.SPI0, csPin: cs)
/// ```
///
/// What's more, SPI communication has four modes determined by the CPOL and CPHA.
/// And the `bitOrder` specifies how data is sent on the bus.
/// They depends on the device your board is communicating with.
///
/// ### Read or write data
///
/// SPI uses two data lines: one for sending data and the other for receiving data.
/// After initialization, you can use the write and read method to communicate with
/// the desired devices:
///
/// ```swift
/// // Read a UInt8 from the device and store it in a variable.
/// let byte: UInt8 = 0
/// spi.read(into: &byte)
///
/// // Write a UInt8 value to the device.
/// let value: UInt8 = 0x01
/// spi.write(value)
/// ```
///
/// ### Read or write data and handle error
///
/// Indeed, communication can fail for various reasons, potentially leading to
/// incorrect data. So methods related to reading or writing data will return
/// results in a Result type. This allows you to handle errors and find
/// alternative solutions.
///
/// ```swift
/// // Read a byte from the provided address and get the results.
/// let result = spi.read(into: &byte)
///
/// if case .failure(let err) = result {
///     // If the communication fails, execute the specified task.
///
/// }
/// ```
///
/// If the data is successfully read, it is stored in `byte`. If the communication
/// fails, the `byte` may store a wrong value or remain unchanged, anyway, it is useless.
/// You can check the `result` to know what happens, and furthermore, handle the error.
///
///
/// ### Example 1: Write data via SPI bus
/// ```swift
/// // Import the SwiftIO to use the related board functions.
/// import SwiftIO
/// // Import the MadBoard to decide which pin is used for the specific function.
/// import MadBoard
///
/// // The cs pin is high so that the sensor would be in an inactive state.
/// let cs = DigitalOut(Id.D0, value: true)
/// // Initialize the pin SPI0. The cs pin will be controlled by spi automatically.
/// let spi = SPI(Id.SPI0, csPin: cs)
///
/// // Write data to the device.
/// let result = spi.write([0x00, 0x01])
/// if case .failure(let err) = result {
///     // If the communication fails, execute the specified task.
///
/// }
///
/// ```
///
///
/// ### Example 2: Read accelerations using LIS3DH library
///
/// ```swift
/// import SwiftIO
/// import MadBoard
/// import LIS3DH
///
/// // The cs pin is high so that the sensor would be in an inactive state.
/// let cs = DigitalOut(Id.D0, value: true)
/// // The cs pin will be controlled by SPI. The CPOL and CPHA should be true for the sensor.
/// let spi = SPI(Id.SPI0, csPin: cs, CPOL: true, CPHA: true)
/// // Initialize the sensor using the spi instance.
/// let sensor = LIS3DH(spi)
///
/// // Read values from the sensor and print them.
/// while true {
///     print(sensor.readXYZ())
///     sleep(ms: 1000)
/// }
/// ```
/// In this example, you just need to initialize the SPI pin and then talk to the
/// sensor without caring about the details of communication. The library [LIS3DH](https://github.com/madmachineio/MadDrivers/blob/main/Sources/LIS3DH/LIS3DH.swift)
/// has configured the sensor by sending and receiving data via SPI bus.
/// Therefore, you can directly read temperature using the predefined APIs.
public final class SPI {
  private let id: Int32
  @_spi(SwiftIOPrivate) public let obj: UnsafeMutableRawPointer

  private var operation: Operation

  /// The transmission speed of SPI communication.
  public private(set) var speed: Int
  /// The state of SCK line when it’s idle.
  public var CPOL: Bool {
    operation.contains(.CPOL)
  }
  /// The phase to sample data, false for the first edge of the clock pulse,
  /// true for the second edge.
  public var CPHA: Bool {
    operation.contains(.CPHA)
  }
  /// Whether the bit order is MSB.
  public var MSB: Bool {
    operation.contains(.MSB)
  }
  /// Whether the bit order is LSB.
  public var LSB: Bool {
    operation.contains(.LSB)
  }
  /// The bit order on data line.
  public var bitOrder: BitOrder {
    if operation.contains(.MSB) {
      return .MSB
    } else {
      return .LSB
    }
  }

  @usableFromInline
  var csPin: DigitalOut?

  /// A boolean value that tells whether the cs pin is set (true) or not (false).
  public var cs: Bool {
    return csPin != nil
  }

  /// Initializes a specified interface for SPI communication as a master device.
  ///
  /// - Parameters:
  ///   - idName: **REQUIRED** Name/label for a physical pin which is
  ///   associated with the I2C peripheral. See Id for the board in
  ///   [MadBoards](https://github.com/madmachineio/MadBoards) library for reference.
  ///   - speed: **OPTIONAL** The clock speed for data transmission, 5_000_000
  ///   by default. It should not exceed the maximum supported speed by the device.
  ///   - csPin: **OPTIONAL** The digital output pin connected to slave device's
  ///   cs pin. When provided, the SPI interface will manage this CS pin for you.
  ///   If it's nil, you need to control it manually using any ``DigitalOut`` pin.
  ///   - CPOL: **OPTIONAL** The state of SCK line when it's idle, `false` by default.
  ///   - CPHA: **OPTIONAL** The phase to sample data, false for the first
  ///   edge of the clock pulse, true for the second edge. `false` by default.
  ///   - bitOrder: **OPTIONAL** The bit order on data line, MSB by default.
  public init(
    _ idName: IdName,
    speed: Int = 5_000_000,
    csPin: DigitalOut? = nil,
    CPOL: Bool = false,
    CPHA: Bool = false,
    bitOrder: BitOrder = .MSB

  ) {
    self.id = idName.value
    self.speed = speed
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
      obj = ptr
    } else {
      fatalError("SPI \(idName.value) init failed!")
    }

    var syncByte: UInt8 = 0
    swifthal_spi_read(obj, &syncByte, 1)
  }

  deinit {
    swifthal_spi_close(obj)
  }

  @usableFromInline
  func csEnable() {
    csPin?.write(false)
  }

  @usableFromInline
  func csDisable() {
    csPin?.write(true)
  }

  /**
     Gets the current clock speed of SPI communication.

     - Returns: The current clock speed.
     */
  public func getSpeed() -> Int {
    return Int(speed)
  }

  /// Sets the speed of SPI communication.
  /// - Parameter speed: The clock speed for the data transmission.
  /// - Returns: Whether the configuration succeeds. If not, it returns the
  /// specific error.
  //  @discardableResult
  // public func setSpeed(_ speed: Int) -> Result<(), Errno> {
  //     let result = nothingOrErrno(
  //         swifthal_spi_config(obj, Int32(speed), operation.rawValue)
  //     )
  //     if case .failure(let err) = result {
  //         print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
  //     } else {
  //         self.speed = Int32(speed)
  //         var syncByte: UInt8 = 0
  //         swifthal_spi_read(obj, &syncByte, 1)
  //     }

  //     return result
  // }

  /// Sets the SPI mode.
  /// - Parameters:
  ///   - CPOL: The state of SCK line when it's idle.
  ///   - CPHA: The phase to sample data, false for the first edge of clock
  ///   pulse and true for the second.
  ///   - bitOrder: The bit order on data line.
  /// - Returns: Whether the configuration succeeds. If not, it returns the
  /// specific error.
  // public func setMode(
  //     CPOL: Bool,
  //     CPHA: Bool,
  //     bitOrder: BitOrder? = nil
  // ) -> Result<(), Errno> {
  //     var newOperation: Operation = .eightBits

  //     if CPOL {
  //         newOperation.insert(.CPOL)
  //     }
  //     if CPHA {
  //         newOperation.insert(.CPHA)
  //     }

  //     if let bitOrder = bitOrder {
  //         switch bitOrder {
  //         case .MSB:
  //             // MSB bit equal zero, insert operation has no effect
  //             // newOperation.insert(.MSB)
  //             break
  //         case .LSB:
  //             newOperation.insert(.LSB)
  //         }
  //     } else {
  //         // MSB bit equal zero, insert operation has no effect
  //         // if operation.contains(.MSB) {
  //         //     newOperation.insert(.MSB)
  //         // }
  //         if operation.contains(.LSB) {
  //             newOperation.insert(.LSB)
  //         }
  //     }

  //     let result = nothingOrErrno(
  //         swifthal_spi_config(obj, speed, newOperation.rawValue)
  //     )
  //     if case .failure(let err) = result {
  //         print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
  //     } else {
  //         operation = newOperation
  //         var syncByte: UInt8 = 0
  //         swifthal_spi_read(obj, &syncByte, 1)
  //     }

  //     return result
  // }

  /// Gets the SPI mode.
  /// - Returns: The CPOL, CPHA and bit order setting.
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

  /// Reads a UInt8 from the slave device.
  /// - Parameter byte: A UInt8 variable to store the received data.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
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

  /// Reads an array of data from the slave device.
  /// - Parameters:
  ///   - buffer: A UInt8 array to store the received bytes.
  ///   - count: The number of bytes to read. Make sure it doesn’t exceed the
  ///   length of the `buffer`. If it’s nil, the number equals the length of
  ///   the `buffer`.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func read(into buffer: inout [UInt8], count: Int? = nil) -> Result<(), Errno> {
    var readLength = 0
    var result = validateLength(buffer, count: count, length: &readLength)

    if case .success = result {
      csEnable()
      result = nothingOrErrno(
        swifthal_spi_read(obj, &buffer, readLength)
      )
      csDisable()
    }

    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }

    return result
  }

  /// Read an array of binary integer from the slave device.
  /// - Parameters:
  ///   - buffer: An array used to store the received data in specified format.
  ///   - count: The number of bytes to read. Make sure it doesn’t exceed the
  ///   length of the buffer. If it’s nil, the number equals the length of the
  ///   buffer.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func read<Element: BinaryInteger>(into buffer: inout [Element], count: Int? = nil)
    -> Result<(), Errno>
  {
    var readLength = 0
    var result = validateLength(buffer, count: count, length: &readLength)

    if case .success = result {
      csEnable()
      result = nothingOrErrno(
        buffer.withUnsafeMutableBytes { pointer in
          swifthal_spi_read(obj, pointer.baseAddress, readLength)
        }
      )
      csDisable()
    }

    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }

    return result
  }

  /// Reads the data from the slave device into the specified buffer pointer.
  /// - Parameters:
  ///   - buffer: A Raw buffer pointer to store the received data in a
  ///   region of storage.
  ///   - count: The count of bytes to read from the device. Make sure it doesn’t
  ///   exceed the length of the `buffer`. If it's nil, it equals the length of
  ///   the `buffer`.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func read(into buffer: UnsafeMutableRawBufferPointer, count: Int? = nil) -> Result<
    (), Errno
  > {
    var readLength = 0
    var result = validateLength(buffer, count: count, length: &readLength)

    if case .success = result {
      csEnable()
      result = nothingOrErrno(
        swifthal_spi_read(obj, buffer.baseAddress, readLength)
      )
      csDisable()
    }

    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }

    return result
  }

  /// Writes a UInt8 to the slave device.
  /// - Parameter byte: A UInt8 to be sent to the slave device.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
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

  /// Writes an array of UInt8 to the slave device.
  /// - Parameters:
  ///   - data: An array of UInt8 to be sent to the slave device.
  ///   - count: The number of bytes in `data` to be sent. Make sure it doesn’t
  ///   exceed the length of the `data`. If it’s nil, all data will be sent.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func write(_ data: [UInt8], count: Int? = nil) -> Result<(), Errno> {
    var writeLength = 0
    var result = validateLength(data, count: count, length: &writeLength)

    if case .success = result {
      csEnable()
      result = nothingOrErrno(
        swifthal_spi_write(obj, data, writeLength)
      )
      csDisable()
    }

    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }

    return result
  }

  /// Write an array of binary integer to the slave device.
  ///
  /// - Parameters:
  ///   - data: An array of data stored in the specified format.
  ///   - count: The count of data to be sent. If nil, it equals the count
  ///   of elements in data.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func write<Element: BinaryInteger>(_ data: [Element], count: Int? = nil) -> Result<
    (), Errno
  > {
    var writeLength = 0
    var result = validateLength(data, count: count, length: &writeLength)

    if case .success = result {
      csEnable()
      result = nothingOrErrno(
        data.withUnsafeBytes { pointer in
          swifthal_spi_write(obj, pointer.baseAddress, writeLength)
        }
      )
      csDisable()
    }

    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }

    return result
  }

  /// Writes a buffer pointer of the data in the underlying storage to the
  /// slave device.
  ///
  /// For example, if you want to write an array of UInt16, you can directly
  /// send the buffer pointer of the array using SPI without converting all
  /// data into UInt8 manually.
  ///
  /// - Parameters:
  ///   - data: A UInt8 buffer pointer for the data to be sent to the slave device.
  ///   - count: The number of bytes in `data` to be sent. Make sure it doesn’t
  ///   exceed the length of the `data`.If it’s nil, all will be sent.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func write(_ data: UnsafeRawBufferPointer, count: Int? = nil) -> Result<(), Errno> {
    var writeLength = 0
    var result = validateLength(data, count: count, length: &writeLength)

    if case .success = result {
      csEnable()
      result = nothingOrErrno(
        swifthal_spi_write(obj, data.baseAddress, writeLength)
      )
      csDisable()
    }

    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }

    return result
  }

  /// Writes a UInt8 to the slave device and then read bytes from it.
  ///
  /// During the communication, when the byte is sent to the device on SDO
  /// line, there will be a byte from the device on SDI line at the same time.
  /// But the buffer will store all data received until the `readCount`
  /// reached, even if the first one may be useless. So make sure
  /// the `readCount` includes all the necessary data.
  ///
  /// For example, if you need two bytes from the sensor:
  ///
  /// ```swift
  /// var readBuffer = [UInt8](repeating: 0, count: 6)
  /// spi.transceive(0x01, into: &readBuffer, readCount: 3)
  /// ```
  ///
  /// The first byte is received when sending the data, and is not the
  /// desired data. The next two bytes are the needed ones. So the `readCount`
  /// is 3.
  /// - Parameters:
  ///   - byte: A UInt8 to be sent to the slave device.
  ///   - buffer: A UInt8 array to store the received bytes.
  ///   - readCount: The number of bytes to read. Make sure it doesn’t exceed
  ///   the length of the `buffer`. If it’s nil, the number equals the length
  ///   of the `buffer`.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
  public func transceive(_ byte: UInt8, into buffer: inout [UInt8], readCount: Int? = nil)
    -> Result<(), Errno>
  {
    var byte = byte
    var readLength = 0

    var result = validateLength(buffer, count: readCount, length: &readLength)

    if case .success = result {
      csEnable()
      result = nothingOrErrno(
        swifthal_spi_transceive(obj, &byte, 1, &buffer, readLength)
      )
      csDisable()
    }

    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }

    return result
  }

  /// Writes an array of UInt8 to the slave device and then read bytes from it.
  ///
  /// During the communication, when the data is sent to the device on SDO
  /// line, there will be data from the device on SDI line at the same time.
  /// But the buffer will store all data received until the `readCount`
  /// reached, even if the first one/several data may be useless. So make sure
  /// the `readCount` includes all the necessary data.
  ///
  /// For example, if you need two bytes from the sensor:
  ///
  /// ```swift
  /// var readBuffer = [UInt8](repeating: 0, count: 6)
  /// spi.transceive([0x01, 0x02], into: &readBuffer, readCount: 4)
  /// ```
  ///
  /// The first two bytes are received when sending the data, and is not the
  /// desired data. The next two bytes are the needed ones. So the `readCount`
  /// is 4.
  ///
  /// - Parameters:
  ///   - data: An array of UInt8 to be sent to the slave device.
  ///   - writeCount: The number of bytes in `data` to be sent. Make sure it
  ///   doesn’t exceed the length of the `data`.If it’s nil, all data will be sent.
  ///   - buffer: A UInt8 array to store the received bytes.
  ///   - readCount: The number of bytes to read. Make sure it doesn’t exceed
  ///   the length of the `buffer`. If it’s nil, the number equals the length
  ///   of the `buffer`.
  /// - Returns: The address of the slave device to communicate with.
  public func transceive(
    _ data: [UInt8],
    writeCount: Int? = nil,
    into buffer: inout [UInt8],
    readCount: Int? = nil
  ) -> Result<(), Errno> {
    var writeLength = 0
    var readLength = 0

    var result = validateLength(data, count: writeCount, length: &writeLength)

    if case .success = result {
      result = validateLength(buffer, count: readCount, length: &readLength)
    }

    if case .success = result {
      csEnable()
      result = nothingOrErrno(
        swifthal_spi_transceive(obj, data, writeLength, &buffer, readLength)
      )
      csDisable()
    }

    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }

    return result
  }
}

extension SPI {

  /// The bit order that the data is sent on SPI bus: MSB or LSB.
  public enum BitOrder {
    /// The most-significant bit of the data is sent first.
    case MSB
    /// The least-significant bit of the data is sent first.
    case LSB
  }

  private struct Operation: OptionSet {
    let rawValue: UInt16

    static let CPOL = Operation(rawValue: UInt16(SWIFT_SPI_MODE_CPOL))
    static let CPHA = Operation(rawValue: UInt16(SWIFT_SPI_MODE_CPHA))
    static let MSB = Operation(rawValue: UInt16(SWIFT_SPI_TRANSFER_MSB))
    static let LSB = Operation(rawValue: UInt16(SWIFT_SPI_TRANSFER_LSB))

    static let eightBits = Operation(rawValue: 8 << 5)
  }
}
