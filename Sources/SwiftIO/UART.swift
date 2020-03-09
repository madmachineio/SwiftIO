public class UART {

    var obj: UARTObject


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

    public func setBaudrate(_ baudRate: Int) {
        obj.baudRate = Int32(baudRate)
        swiftHal_uartConfig(&obj)
    }

    public func clearBuffer() {
        swiftHal_uartClearBuffer(&obj)
    }

    public func checkBufferReceived() -> Int {
        return Int(swiftHal_uartCount(&obj))
    }

    public func write(_ byte: UInt8) {
        swiftHal_uartWriteChar(&obj, byte)
    }

    public func write(_ data: [UInt8]) {
        swiftHal_uartWrite(&obj, data, Int32(data.count))
    }

    public func write(_ string: String) {
        let data: [UInt8] = string.utf8CString.map {UInt8($0)}
        swiftHal_uartWrite(&obj, data, Int32(data.count))
    }

    public func readByte() -> UInt8 {
        return swiftHal_uartReadChar(&obj)
    }

    public func read(_ count: Int) -> [UInt8] {
        var data: [UInt8] = Array(repeating: 0, count: count)
        swiftHal_uartRead(&obj, &data, Int32(count));
        return data
    }


}




extension UART {

    public enum Id: UInt8 {
        case UART0 = 0, UART1, UART2, UART3
    }

    public enum Parity: UInt8 {
        case none, odd, even
    }

    public enum StopBits: UInt8 {
        case oneBit, twoBits
    }

    public enum DataBits: UInt8 {
        case eightBits
    }

    public enum BufferLength: Int32 {
        case small = 64, medium = 256, large = 1024
    }
}