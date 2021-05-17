import CSwiftIO

/**
UART is a two-wire serial communication protocol used to communicate with serial devices. The devices must agree on a common transmisson rate before communication.

*/
public final class UART {
    private let id: Int32
    private var obj: UnsafeMutableRawPointer

    private var config = swift_uart_cfg_t()

    private var baudRate: Int {
        willSet {
            config.baudrate = Int32(newValue)
        }
    }
    private var dataBits: DataBits {
        willSet {
            switch newValue {
                case .eightBits:
                config.data_bits = SWIFT_UART_DATA_BITS_8
            }
        }
    }
    private var parity: Parity {
        willSet {
            switch newValue {
                case .none:
                config.parity = SWIFT_UART_PARITY_NONE
                case .odd:
                config.parity = SWIFT_UART_PARITY_ODD
                case .even:
                config.parity = SWIFT_UART_PARITY_EVEN
            }
        }
    }
    private var stopBits: StopBits {
        willSet {
            switch newValue {
                case .oneBit:
                config.stop_bits = SWIFT_UART_STOP_BITS_1
                case .twoBits:
                config.stop_bits = SWIFT_UART_STOP_BITS_2
            }
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
     - Parameter baudRate: **OPTIONAL**The communication speed. The default baud rate is 115200.
     - Parameter dataBits : **OPTIONAL**The length of the data being transmitted.
     - Parameter parity: **OPTIONAL**The parity bit to confirm the accuracy of the data transmission.
     - Parameter stopBits: **OPTIONAL**The bits reserved to stop the communication.
     - Parameter readBufferLength: **OPTIONAL**The length of the serial buffer to store the data.
     
     ### Usage Example ###
     ````
     // Initialize a UART interface UART0.
     let uart = UART(Id.UART0)
     ````
     */
    public init(_ idName: IdName,
                baudRate: Int = 115200,
                dataBits: DataBits = .eightBits,
                parity: Parity = .none,
                stopBits: StopBits = .oneBit,
                readBufferLength: Int = 64) {
        self.id = idName.value
        self.baudRate = baudRate
        self.dataBits = dataBits
        self.parity = parity
        self.stopBits = stopBits
        self.readBufferLength = readBufferLength

        config.baudrate = Int32(baudRate)
        switch dataBits {
            case .eightBits:
            config.data_bits = SWIFT_UART_DATA_BITS_8
        }
        switch parity {
            case .none:
            config.parity = SWIFT_UART_PARITY_NONE
            case .odd:
            config.parity = SWIFT_UART_PARITY_ODD
            case .even:
            config.parity = SWIFT_UART_PARITY_EVEN
        }
        switch stopBits {
            case .oneBit:
            config.stop_bits = SWIFT_UART_STOP_BITS_1
            case .twoBits:
            config.stop_bits = SWIFT_UART_STOP_BITS_2
        }
        config.read_buf_len = Int32(readBufferLength)

        if let ptr = swifthal_uart_open(id, &config) {
            obj = UnsafeMutableRawPointer(ptr)
        } else {
            fatalError("UART\(idName.value) initialization failed!")
        }

    }

    deinit {
        swifthal_uart_close(obj)
    }


    /**
     Set the baud rate for communication. It should be set ahead of time to ensure the same baud rate between two devices.
     - Parameter baudRate: The communication speed.

     */
    public func setBaudrate(_ baudRate: Int) {
        config.baudrate = Int32(baudRate)
        swifthal_uart_baudrate_set(obj, config.baudrate)
    }

    /**
     Clear all bytes from the buffer to store the incoming data.
     */
    public func clearBuffer() {
        swifthal_uart_buffer_clear(obj)
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
    @inline(__always)
    public func write(_ byte: UInt8) {
        swifthal_uart_char_put(obj, byte)
    }

    /**
     Write a series of bytes to the external device through the serial connection.
     - Parameter data: A byte array to be sent to the device.

     */
    @inline(__always)
    public func write(_ data: [UInt8], count: Int? = nil) {
        let ret, length: Int32

        if let count = count {
            length = Int32(min(count, data.count))
        } else {
            length = Int32(data.count)
        }

        ret = swifthal_uart_write(obj, data, length)
        if ret != 0 {
            print("UART\(id) write error!")
        }
    }

    /**
     Write a string to the external device through the serial connection.
     - Parameter string: A string to be sent to the device.

     */
    @inline(__always)
    public func write(_ string: String) {
        let data: [UInt8] = string.utf8CString.map {UInt8($0)}

        let ret = swifthal_uart_write(obj, data, Int32(data.count))

        if ret != 0 {
            print("UART\(id) write error!")
        }
    }

    /**
     Read a byte of data receiving from the external device. The maximum time for data reception is decided by the timeout value. If the data is received before the time set, the read process will end up automatically. 
     
     -1 is set to wait until receiving the required data. 
     0 is set to end up the read immediately no matter whether the data is received or not. 
     A value greater than 0 is set to wait for a certain period (in milliseconds) and then end up the read.
     - Parameter timeout: The max time(in milliseconds) for data reception.

     - Returns: One 8-bit binary data read from the device.

     */
    @inline(__always)
    public func readByte(timeout: Int? = nil) -> UInt8? {
        let timeoutValue: Int32

        if let timeout = timeout {
            timeoutValue = Int32(timeout)
        } else {
            timeoutValue = Int32(SWIFT_FOREVER)
        }

        var byte: UInt8 = 0
        let ret = swifthal_uart_char_get(obj, &byte, timeoutValue)
        if ret == 0 {
            return byte
        } else {
            print("UART\(id) readByte error!")
            return nil
        }
    }

    /**
     Read a series of bytes receiving from the external device.The maximum time for data reception is decided by the timeout value. If the data is received before the time set, the read process will end up automatically. 
     
     -1 is set to wait until receiving the required data. 
     0 is set to end up the read immediately no matter whether the data is received or not. 
     A value greater than 0 is set to wait for a certain period (in milliseconds) and then end up the read.
     - Parameter timeout: The max time(in milliseconds) for data reception.
     - Parameter count: The number of bytes to read.

     - Returns: A byte array read from the device.

     */
    @inline(__always)
    public func read(count: Int, timeout: Int? = nil) -> [UInt8] {
        let timeoutValue: Int32

        if let timeout = timeout {
            timeoutValue = Int32(timeout)
        } else {
            timeoutValue = Int32(SWIFT_FOREVER)
        }

        var data = [UInt8](repeating: 0, count: count)
        let received = Int(swifthal_uart_read(obj, &data, Int32(count), timeoutValue))
        return Array(data[0..<received])
    }


}




extension UART {
    /**
     The parity bit is used to ensure the data transmission according to the number of logical-high bits.

     */
    public enum Parity {
        case none, odd, even
    }

    /**
     One or two stops bits are reserved to end the communication.

     */
    public enum StopBits {
        case oneBit, twoBits
    }

    /**
     This indicates the length of the data being transmitted.

     */
    public enum DataBits {
        case eightBits
    }

}
