//=== UART.swift ----------------------------------------------------------===//
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
UART is a two-wire serial communication protocol used to communicate with
 serial devices. The devices must agree on a common transmisson rate before
 communication.

*/
public final class UART {
    private let id: Int32
    private var obj: UnsafeMutableRawPointer

    private var config: swift_uart_cfg_t

    private var baudRate: Int {
        willSet {
            config.baudrate = Int32(newValue)
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
            config.read_buf_len = Int32(newValue)
        }
    }

    /**
     Initialize an interface for UART communication.
     - Parameter id: **REQUIRED** The name of the UART interface.
     - Parameter baudRate: **OPTIONAL**The communication speed.
        The default baud rate is 115200.
     - Parameter parity: **OPTIONAL**The parity bit to confirm the accuracy
        of the data transmission.
     - Parameter stopBits: **OPTIONAL**The bits reserved to stop the
        communication.
     - Parameter dataBits : **OPTIONAL**The length of the data being transmitted.
     - Parameter readBufferLength: **OPTIONAL**The length of the serial
        buffer to store the data.
     
     ### Usage Example ###
     ````
     // Initialize a UART interface UART0.
     let uart = UART(Id.UART0)
     ````
     */
    public init(
        _ idName: IdName,
        baudRate: Int = 115200,
        parity: Parity = .none,
        stopBits: StopBits = .oneBit,
        dataBits: DataBits = .eightBits,
        readBufferLength: Int = 64
    ) {
        self.id = idName.value
        self.baudRate = baudRate
        self.parity = parity
        self.stopBits = stopBits
        self.dataBits = dataBits
        self.readBufferLength = readBufferLength

        config = swift_uart_cfg_t()
        config.baudrate = Int32(baudRate)
        config.parity = UART.getParityRawValue(parity)
        config.stop_bits = UART.getStopBitsRawValue(stopBits)
        config.data_bits = UART.getDataBitsRawValue(dataBits)
        config.read_buf_len = Int32(readBufferLength)

        if let ptr = swifthal_uart_open(id, &config) {
            obj = UnsafeMutableRawPointer(ptr)
        } else {
            fatalError("UART \(idName.value) init failed")
        }

    }

    deinit {
        swifthal_uart_close(obj)
    }


    /**
     Set the baud rate for communication. It should be set ahead of time
     to ensure the same baud rate between two devices.
     - Parameter baudRate: The communication speed.

     */
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

    public func getBaudRate() -> Int {
        return baudRate
    }

    /**
     Clear all bytes from the buffer to store the incoming data.
     */
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
     Return the number of received data from the serial buffer.
     - Returns: The number of bytes received in the buffer.
     */
    public func checkBufferReceived() -> Int {
        return Int(swifthal_uart_remainder_get(obj))
    }

    /**
     Write a byte of data to the external device through the serial connection.
     - Parameter byte: One 8-bit binary data to be sent to the device.

     */
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

    /**
     Write a series of bytes to the external device through the
     serial connection.
     - Parameter data: A byte array to be sent to the device.

     */
    @discardableResult
    public func write(_ data: [UInt8], count: Int? = nil) -> Result<(), Errno> {
        var writeLength = 0
        var result = validateLength(data, count: count, length: &writeLength)

        if case .success = result {
            result = nothingOrErrno(
                swifthal_uart_write(obj, data, Int32(writeLength))
            )
        }
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }
        return result
    }

    @discardableResult
    public func write(_ data: UnsafeBufferPointer<UInt8>, count: Int? = nil) -> Result<(), Errno> {
        var writeLength = 0
        var result = validateLength(data, count: count, length: &writeLength)

        if case .success = result {
            result = nothingOrErrno(
                swifthal_uart_write(obj, data.baseAddress, Int32(writeLength))
            )
        }
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }
        return result
    }

    /**
     Write a string to the external device through the serial connection.
     - Parameter string: A string to be sent to the device.

     */
    @discardableResult
    public func write(_ string: String) -> Result<(), Errno> {
        let data: [UInt8] = string.utf8CString.map {UInt8($0)}

        let result = nothingOrErrno(
            swifthal_uart_write(obj, data, Int32(data.count))
        )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }
        return result
    }

    /**
     Read a byte of data receiving from the external device. The maximum time
     for data reception is decided by the timeout value. If the data is
     received before the time set, the read process will end up automatically.
     
     -1 is set to wait until receiving the required data. 
     0 is set to end up the read immediately no matter whether the data is
     received or not.
     A value greater than 0 is set to wait for a certain period
     (in milliseconds) and then end up the read.
     - Parameter timeout: The max time(in milliseconds) for data reception.

     - Returns: One 8-bit binary data read from the device.

     */
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

    /**
     Read a series of bytes receiving from the external device.The maximum
     time for data reception is decided by the timeout value. If the data is
     received before the time set, the read process will end up automatically.
     
     -1 is set to wait until receiving the required data. 
     0 is set to end up the read immediately no matter whether the data is
     received or not.
     A value greater than 0 is set to wait for a certain period
     (in milliseconds) and then end up the read.
     - Parameter timeout: The max time(in milliseconds) for data reception.
     - Parameter count: The number of bytes to read.

     - Returns: A byte array read from the device.

     */
    @discardableResult
    public func read(into buffer: inout [UInt8], count: Int? = nil, timeout: Int? = nil) -> Result<Int, Errno> {
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
                swifthal_uart_read(obj, &buffer, Int32(readLength), timeoutValue)
            )
        }

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }
        return result
    }


    @discardableResult
    public func read(into buffer: UnsafeMutableBufferPointer<UInt8>, count: Int? = nil, timeout: Int? = nil) -> Result<Int, Errno> {
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
                swifthal_uart_read(obj, buffer.baseAddress, Int32(readLength), timeoutValue)
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
     The parity bit is used to ensure the data transmission according
     to the number of logical-high bits.

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
     This indicates the length of the data being transmitted.

     */
    public enum DataBits {
        case eightBits
    }

    private static func getDataBitsRawValue(_ dataBits: DataBits) -> swift_uart_data_bits_t {
        switch dataBits {
        case .eightBits:
            return SWIFT_UART_DATA_BITS_8
        }
    }

}
