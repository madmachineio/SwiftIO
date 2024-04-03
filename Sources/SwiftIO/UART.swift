//=== UART.swift ----------------------------------------------------------===//
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

/// UART is a two-wire serial communication protocol used to communicate with
///  serial devices. The devices must agree on a common transmisson rate before
///  communication.
///
///  ### Initialize a UART port
///
///  To initialize a UART pin, you can simply specify the id. The other parameters
///  have their default value to set the UART communication.
///
///  ```swift
///  // Initialize a UART interface UART0.
///  let uart = UART(Id.UART0)
///  ```
///  Each UART port needs a TX (transmitter) and a RX (receiver) line. UART0 refers
///  to the pins TX0 and RX0 on your board. The TX0 line should connects to the RX of the
///  external device and RX0 to TX of the device.
///
///  ### Read or write data
///
///  To write data to a UART device,
///
///  ```swift
///  // Write a UInt8 to the external device.
///  let data: UInt8 = 0x01
///  uart.write(byte)
///  ```
///  To read data from a UART device,
///
///  ```swift
///  // Read a byte from the external device and store it.
///  var byte: UInt8 = 0
///  uart.read(into: &byte)
///  ```
///
///  ### Read or write data and handle error
///
///
///  Indeed, communication can fail for various reasons, potentially leading to
///  incorrect data. Besides, the wait time may not be enough to receive data and thus
///  you don't get all needed data. So methods related to reading or writing data
///  will return results in a Result type. This allows you to handle errors and find
///  alternative solutions.
///
///  ```swift
///  let result = uart.read(into: &byte)
///  switch result {
///  case .success(let count):
///      // Know if you have received enough data.
///
///  case .failure(let error):
///      // If an error happens, execute the specified task.
///
///  }
///  ```
public final class UART {
  private let id: Int32
  @_spi(SwiftIOPrivate) public let obj: UnsafeMutableRawPointer

  private var config: swift_uart_cfg_t

  private var baudRate: Int {
    willSet {
      config.baudrate = newValue
    }
  }

  private var parity: Parity {
    willSet {
      config.parity = UART.getParityRawValue(newValue)
    }
  }

  private var stopBits: StopBits {
    willSet {
      config.stop_bits = UART.getStopBitsRawValue(newValue)
    }
  }

  private var dataBits: DataBits {
    willSet {
      config.data_bits = UART.getDataBitsRawValue(newValue)
    }
  }

  private var readBufferLength: Int {
    willSet {
      config.read_buf_len = newValue
    }
  }

  /**
     Initializes an interface for UART communication.
     - Parameter idName: **REQUIRED** Name/label for a physical pin which is
     associated with the UART peripheral. See Id for the board in
     [MadBoards](https://github.com/madmachineio/MadBoards) library for reference.
     - Parameter baudRate: **OPTIONAL**The communication speed.
     The default baud rate is 115200.
     - Parameter parity: **OPTIONAL**The parity bit to confirm the accuracy
        of the data transmission, `.none` by default.
     - Parameter stopBits: **OPTIONAL**The bits reserved to stop the
        communication, `.oneBit` by default.
     - Parameter dataBits : **OPTIONAL**The length of the data being transmitted,
     `.eightBits` by default.
     - Parameter readBufferLength: **OPTIONAL**The length of the serial
        buffer to store the data, 1024 by default.
     */
  public init(
    _ idName: IdName,
    baudRate: Int = 115200,
    parity: Parity = .none,
    stopBits: StopBits = .oneBit,
    dataBits: DataBits = .eightBits,
    readBufferLength: Int = 1024
  ) {
    self.id = idName.value
    self.baudRate = baudRate
    self.parity = parity
    self.stopBits = stopBits
    self.dataBits = dataBits
    self.readBufferLength = readBufferLength

    config = swift_uart_cfg_t()
    config.baudrate = baudRate
    config.parity = UART.getParityRawValue(parity)
    config.stop_bits = UART.getStopBitsRawValue(stopBits)
    config.data_bits = UART.getDataBitsRawValue(dataBits)
    config.read_buf_len = readBufferLength

    if let ptr = swifthal_uart_open(id, &config) {
      obj = ptr
    } else {
      fatalError("UART \(idName.value) init failed")
    }

  }

  deinit {
    swifthal_uart_close(obj)
  }

  /// Sets the baud rate for communication. It should be set ahead of time
  /// to ensure the same baud rate between devices.
  /// - Attention: Now this method has issue due to the low-level driver in
  /// Zephyr. Please close the UART and reopen it at a different baudrate.
  /// - Parameter baudRate: The communication speed.
  /// - Returns: Whether the configuration succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func setBaudRate(_ baudRate: Int) -> Result<(), Errno> {
    let oldBaudRate = self.baudRate
    self.baudRate = baudRate

    let result = nothingOrErrno(
      swifthal_uart_baudrate_set(obj, config.baudrate)
    )

    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
      self.baudRate = oldBaudRate
    }

    return result
  }

  /// Gets the current baud rate for serial communication.
  /// - Returns: The communication speed.
  public func getBaudRate() -> Int {
    return baudRate
  }

  /// Clears all bytes from the buffer to store the incoming data.
  /// - Returns: Whether the configuration succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func clearBuffer() -> Result<(), Errno> {
    let result = nothingOrErrno(
      swifthal_uart_buffer_clear(obj)
    )

    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }

    return result
  }

  /**
     Returns the number of received data from the serial buffer.

     UART has a receive buffer for incoming data. It checks the receive buffer
     and determines the number of bytes that are currently available for reading.
     - Returns: The number of bytes received in the buffer.
     */
  public func checkBufferReceived() -> Int {
    return Int(swifthal_uart_remainder_get(obj))
  }

  /// Writes a byte to the external device through the serial connection.
  /// - Parameter byte: A UInt8 to be sent to the device.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func write(_ byte: UInt8) -> Result<(), Errno> {
    let result = nothingOrErrno(
      swifthal_uart_char_put(obj, byte)
    )
    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }
    return result
  }

  /// Writes a series of bytes to the external device through the serial connection.
  /// - Parameters:
  ///   - data: An array of UInt8 to be sent to the device.
  ///   - count: The number of bytes in `data` to be sent. Make sure it doesn't
  ///   exceed the length of the `data`. If it’s nil, all data will be sent.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func write(_ data: [UInt8], count: Int? = nil) -> Result<(), Errno> {
    var writeLength = 0
    var result = validateLength(data, count: count, length: &writeLength)

    if case .success = result {
      result = nothingOrErrno(
        swifthal_uart_write(obj, data, writeLength)
      )
    }
    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }
    return result
  }

  /// Writes buffer pointer of the data in the underlying storage to the external device.
  /// - Parameters:
  ///   - data: A UInt8 buffer pointer for the data to be sent to the device.
  ///   - count: The number of bytes in `data` to be sent. Make sure it doesn't
  ///   exceed the length of the `data`. If it’s nil, all will be sent.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func write(_ data: UnsafeRawBufferPointer, count: Int? = nil) -> Result<(), Errno> {
    var writeLength = 0
    var result = validateLength(data, count: count, length: &writeLength)

    if case .success = result {
      result = nothingOrErrno(
        swifthal_uart_write(obj, data.baseAddress, writeLength)
      )
    }
    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }
    return result
  }

  /// Writes a string to the external device through the serial connection.
  /// - Parameter string: A string to be sent to the device.
  /// - Parameter addNullTerminator: Whether to add "\0" to the end of the string.
  /// - Returns: Whether the communication succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func write(_ string: String, addNullTerminator: Bool = false) -> Result<(), Errno> {
    let data: [UInt8]

    if addNullTerminator {
      data = string.utf8CString.map { UInt8($0) }
    } else {
      data = [UInt8](string.utf8)
    }

    let result = nothingOrErrno(
      swifthal_uart_write(obj, data, data.count)
    )
    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }
    return result
  }

  /// Reads a byte from the external device.
  ///
  /// The parameter `timeout` sets the maximum time for data reception.
  /// If the reception is fulfilled before the time limit, the read process will
  /// end up automatically. If the time is too short, you may not get all data.
  ///
  /// The **timeout** value can be:
  /// - -1: wait until all required data are received.
  /// - 0: stop the data reception immediately no matter whether all data are
  /// received or not.
  /// - A positive integer: wait for a specified period (in milliseconds),
  /// then stop reading data when time is up, even if not all needed data are got.
  ///
  /// The returned **result** indicates how the communication goes:
  /// - For success case: it returns an integer telling the expected data count
  /// and the actual received data count.
  ///     * 0 means all needed data are received, that's to say, the reading is
  ///     fulfilled.
  ///     * 1 means you still needs a byte, that means the time is not enough,
  ///     so you haven't got the byte from the sensor.
  /// - For failure case: it returns the error that happens during communication.
  ///
  /// - Parameters:
  ///   - buffer: A UInt8 to store the received byte.
  ///   - timeout: The max time limit (in milliseconds) for data reception.
  /// - Returns: The number of data that is still needed or an error for the
  /// failure case.
  @discardableResult
  public func read(into buffer: inout UInt8, timeout: Int? = nil) -> Result<Int, Errno> {
    let timeoutValue: Int32

    if let timeout = timeout {
      timeoutValue = Int32(timeout)
    } else {
      timeoutValue = Int32(SWIFT_FOREVER)
    }

    let result = valueOrErrno(
      swifthal_uart_read(obj, &buffer, 1, timeoutValue)
    )
    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }
    return result
  }

  /// Reads a specified amount of bytes from the external device.
  ///
  /// The parameter `timeout` sets the maximum time for data reception.
  /// If the reception is fulfilled before the time limit, the read process will
  /// end up automatically. If the time is too short, you may not get all data.
  ///
  /// The **timeout** value can be:
  /// - -1: wait until all required data are received.
  /// - 0: stop the data reception immediately no matter whether all data are
  /// received or not.
  /// - A positive integer: wait for a specified period (in milliseconds),
  /// then stop reading data when time is up, even if not all needed data are got.
  ///
  /// The returned **result** indicates how the communication goes:
  /// - For success case: it returns an integer telling the expected data count
  /// and the actual received data count.
  ///     * 0 means all needed data are received, that's to say, the reading is
  ///     fulfilled.
  ///     * A positive integer means you still needs some data. For example, you
  ///     want 4 and the result returns 2, so the time is not enough, you have
  ///     got 2 bytes and still need next 2 bytes.
  /// - For failure case: it returns the error that happens during communication.
  ///
  /// - Parameters:
  ///   - buffer: A UInt8 array to store the received bytes.
  ///   - count: The number of bytes to read. Make sure it doesn't exceed the
  ///   length of the buffer. If it’s nil, it equals the length of the buffer.
  ///   - timeout: The max time limit (in milliseconds) for data reception.
  /// - Returns: The number of data that is still needed or an error for the
  /// failure case.
  @discardableResult
  public func read(into buffer: inout [UInt8], count: Int? = nil, timeout: Int? = nil) -> Result<
    Int, Errno
  > {
    let timeoutValue: Int32
    let result: Result<Int, Errno>

    if let timeout = timeout {
      timeoutValue = Int32(timeout)
    } else {
      timeoutValue = Int32(SWIFT_FOREVER)
    }

    var readLength = 0
    let validateRet = validateLength(buffer, count: count, length: &readLength)

    if case .failure(let err) = validateRet {
      result = .failure(err)
    } else {
      result = valueOrErrno(
        swifthal_uart_read(obj, &buffer, readLength, timeoutValue)
      )
    }

    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }
    return result
  }

  /// Reads a specified amount of bytes from the external device into the buffer
  /// pointer.
  ///
  /// The parameter `timeout` sets the maximum time for data reception.
  /// If the reception is fulfilled before the time limit, the read process will
  /// end up automatically. If the time is too short, you may not get all data.
  ///
  /// The **timeout** value can be:
  /// - -1: wait until all required data are received.
  /// - 0: stop the data reception immediately no matter whether all data are
  /// received or not.
  /// - A positive integer: wait for a specified period (in milliseconds),
  /// then stop reading data when time is up, even if not all needed data are got.
  ///
  /// The returned **result** indicates how the communication goes:
  /// - For success case: it returns an integer telling the expected data count
  /// and the actual received data count.
  ///     * 0 means all needed data are received, that's to say, the reading is
  ///     fulfilled.
  ///     * A positive integer means you still needs some data. For example, you
  ///     want 4 and the result returns 2, so the time is not enough, you have
  ///     got 2 bytes and still need next 2 bytes.
  /// - For failure case: it returns the error that happens during communication.
  ///
  /// - Parameters:
  ///   - buffer: A UInt8 buffer pointer to store the received data in a region
  ///   of storage.
  ///   - count: The count of bytes to read from the device. Make sure it doesn't
  ///   exceed the length of the buffer. If it’s nil, it equals the length of
  ///   the buffer.
  ///   - timeout: The max time limit (in milliseconds) for data reception.
  /// - Returns: The number of data that is still needed or an error for the
  /// failure case.
  @discardableResult
  public func read(
    into buffer: UnsafeMutableRawBufferPointer, count: Int? = nil, timeout: Int? = nil
  ) -> Result<Int, Errno> {
    let timeoutValue: Int32
    let result: Result<Int, Errno>

    if let timeout = timeout {
      timeoutValue = Int32(timeout)
    } else {
      timeoutValue = Int32(SWIFT_FOREVER)
    }

    var readLength = 0
    let validateRet = validateLength(buffer, count: count, length: &readLength)

    if case .failure(let err) = validateRet {
      result = .failure(err)
    } else {
      result = valueOrErrno(
        swifthal_uart_read(obj, buffer.baseAddress, readLength, timeoutValue)
      )
    }
    if case .failure(let err) = result {
      print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
    }
    return result
  }

}

extension UART {
  /**
     The parity bit used to verify if data has changed during transmission. It
     counts the number of logical-high bits and see if it equals an odd or even
     number.

     */
  public enum Parity {
    case none, odd, even
  }

  private static func getParityRawValue(_ parity: Parity) -> swift_uart_parity_t {
    switch parity {
    case .none:
      return SWIFT_UART_PARITY_NONE
    case .odd:
      return SWIFT_UART_PARITY_ODD
    case .even:
      return SWIFT_UART_PARITY_EVEN
    }
  }

  /**
     One or two stops bits are reserved to end the communication.

     */
  public enum StopBits {
    case oneBit, twoBits
  }

  private static func getStopBitsRawValue(_ stopBits: StopBits) -> swift_uart_stop_bits_t {
    switch stopBits {
    case .oneBit:
      return SWIFT_UART_STOP_BITS_1
    case .twoBits:
      return SWIFT_UART_STOP_BITS_2
    }
  }

  /**
     The length of the data being transmitted.

     */
  public enum DataBits {
    /// Data is sent in byte.
    case eightBits
  }

  private static func getDataBitsRawValue(_ dataBits: DataBits) -> swift_uart_data_bits_t {
    switch dataBits {
    case .eightBits:
      return SWIFT_UART_DATA_BITS_8
    }
  }

}
