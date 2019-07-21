public class UART {

    var obj: UARTObject

    public convenience init(_ id: UARTId) {
        self.init(id, baudRate: 115200, dataBits: .eightBits, parity: .none, stopBits: .oneBit, readBufLength: .small)
    }

    public init(_ id: UARTId, baudRate: UInt32, dataBits: UARTDataBits, parity: UARTParity, stopBits: UARTStopBits, readBufLength: UARTBufLength) {
        obj = UARTObject()
        obj.id = id.rawValue
        obj.baudRate = baudRate
        obj.dataBits = dataBits.rawValue
        obj.parity = parity.rawValue
        obj.stopBits = stopBits.rawValue
        obj.readBufLength = readBufLength.rawValue
        swiftHal_uartInit(&obj)
    }

    deinit {
        swiftHal_uartDeinit(&obj)
    }

    public func updateBandrate(to baudrate: UInt32) {
        obj.baudRate = baudrate
        swiftHal_uartConfig(&obj)
    }

    public func available() -> UInt {
        return UInt(swiftHal_uartCount(&obj))
    }

    public func writeByte(_ byte: UInt8) {
        swiftHal_uartWriteChar(&obj, byte)
    }

    public func readByte() -> UInt8 {
        return swiftHal_uartReadChar(&obj)
    }

    public func write(_ writeArray: [Int8]) {
        print("writeArray.count = \(writeArray.count)")
        print(writeArray)
        swiftHal_uartWrite(&obj, writeArray, UInt32(writeArray.count))
    }

    public func read(count length: Int) -> [UInt8] {
        var readArray: [UInt8] = Array(repeating: 0, count: length)

        swiftHal_uartRead(&obj, &readArray, UInt32(length))
        return readArray
    }

}