/**
UART is a two-wire serial communication protocol used to communicate with serial devices.

*/
public class UART {

    var obj: UARTObject

    /**
     Initialize an interface for UART communication.
     - Parameter id: **REQUIRED** The name of the UART interface.
     - Parameter baudRate: **OPTIONAL**The communication speed. The default baud rate is 115200.
     - Parameter dataBits : **OPTIONAL**The length of the data being transmitted.
     - Parameter parity: **OPTIONAL**The parity bit to confirm the accuracy of the data transmission.
     - Parameter stopBits: **OPTIONAL**The bits reserved to stop the communication.
     - Parameter readBufLength: **OPTIONAL**The length of the serial buffer to store the data.
     
     ### Usage Example ###
     ````
     // Initialize a UART interface UART0.
     let uart = UART(.UART0)

     ````
     */
    public init(_ id: Id,
                baudRate: Int = 115200,
                dataBits: DataBits = .eightBits,
                parity: Parity = .none,
                stopBits: StopBits = .oneBit,
                readBufLength: BufferLength = .small) {
        obj = UARTObject()
        obj.id = id.rawValue
        obj.baudRate = Int32(baudRate)
        obj.dataBits = dataBits.rawValue
        obj.parity = parity.rawValue
        obj.stopBits = stopBits.rawValue
        obj.readBufferLength = Int32(readBufLength.rawValue)
        swiftHal_uartInit(&obj)
    }

    deinit {
        swiftHal_uartDeinit(&obj)
    }

    /**
     Set the baud rate for communication.
     - Parameter baudRate: The communication speed.

     */
    public func setBaudrate(_ baudRate: Int) {
        obj.baudRate = Int32(baudRate)
        swiftHal_uartConfig(&obj)
    }

    /**
     Clear all bytes from the buffer.
     */
    public func clearBuffer() {
        swiftHal_uartClearBuffer(&obj)
    }

    /**
     Return the number of received data from the serial buffer.
     - Returns: The number of bytes received in the buffer.
     */
    public func checkBufferReceived() -> Int {
        return Int(swiftHal_uartCount(&obj))
    }

    /**
     Write a byte of data to the external device through the serial connection.
     - Parameter byte: One 8-bits binary data to be sent to the device.

     */
    public func write(_ byte: UInt8) {
        swiftHal_uartWriteChar(&obj, byte)
    }

    /**
     Write a series of bytes to the external device through the serial connection.
     - Parameter data: A series of 8-bits binary data to be sent to the device.

     */
    public func write(_ data: [UInt8]) {
        swiftHal_uartWrite(&obj, data, Int32(data.count))
    }

    /**
     Write a string to the external device through the serial connection.
     - Parameter string: A string to be sent to the device.

     */
    public func write(_ string: String) {
        let data: [UInt8] = string.utf8CString.map {UInt8($0)}
        swiftHal_uartWrite(&obj, data, Int32(data.count))
    }

    /**
     Read a byte of data receiving from the external device.
     - Returns: One 8-bits binary data.

     */
    public func readByte() -> UInt8 {
        return swiftHal_uartReadChar(&obj)
    }

    /**
     Read a series of bytes receiving from the external device.
     - Returns: A series of 8-bits binary data.

     */
    public func read(_ count: Int) -> [UInt8] {
        var data: [UInt8] = Array(repeating: 0, count: count)
        swiftHal_uartRead(&obj, &data, Int32(count));
        return data
    }


}




extension UART {
    
    /**
     The interfaces UART0 to UART3 are used for UART communication. Two pins are necessary: TX is used to transmit data; RX is used to receive data.

     */
    public enum Id: UInt8 {
        case UART0 = 0, UART1, UART2, UART3
    }

    /**
     This is used to ensure the data transmission according to the number of logical-high bits.

     */
    public enum Parity: UInt8 {
        case none, odd, even
    }

    /**
     One or two stops bits are reserved to stop the communication.

     */
    public enum StopBits: UInt8 {
        case oneBit, twoBits
    }

    /**
     This indicates the length of the data being transmitted.

     */
    public enum DataBits: UInt8 {
        case eightBits
    }

    /**
     This indicates the storage size of the serial buffer.

     */
    public enum BufferLength: Int32 {
        case small = 64, medium = 256, large = 1024
    }
}
