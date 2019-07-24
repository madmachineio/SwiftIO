public class UART {

    var obj: UARTObject

    public convenience init(_ id: UARTId) {
        self.init(id, baudRate: 115200, dataBits: .eightBits, parity: .none, stopBits: .oneBit, readBufLength: .small)
    }

    public init(_ id: UARTId, baudRate: UInt32, dataBits: UARTDataBits, parity: UARTParity, stopBits: UARTStopBits, readBufLength: UARTBufferLength) {
        obj = UARTObject()
        obj.id = id.rawValue
        obj.baudRate = baudRate
        obj.dataBits = dataBits.rawValue
        obj.parity = parity.rawValue
        obj.stopBits = stopBits.rawValue
        obj.readBufferLength = readBufLength.rawValue
        swiftHal_uartInit(&obj)
    }

    deinit {
        swiftHal_uartDeinit(&obj)
    }

    public func setBandrate(_ baudRate: Int) {
        obj.baudRate = UInt32(baudRate)
        swiftHal_uartConfig(&obj)
    }

    public func clearBuffer() {
        swiftHal_uartClearBuffer(&obj)
    }

    public func checkAvailable() -> Int {
        return Int(swiftHal_uartCount(&obj))
    }

    public func write(_ byte: UInt8) {
        swiftHal_uartWriteChar(&obj, byte)
    }

    public func write(_ array: [UInt8]) {
        swiftHal_uartWrite(&obj, array, UInt32(array.count))
    }

    public func write(_ string: String) {
        let array = Array(string.utf8CString)
        var array1: [UInt8] = Array(repeating: 0, count: array.count)

        for i in 0..<array.count {
            array1[i] = UInt8(array[i])
        }
        swiftHal_uartWrite(&obj, array1, UInt32(array1.count))

    }

    public func read() -> UInt8 {
        return swiftHal_uartReadChar(&obj)
    }



    public func read(count length: Int) -> [UInt8] {
        var readArray: [UInt8] = Array(repeating: 0, count: length)

        swiftHal_uartRead(&obj, &readArray, UInt32(length))
        return readArray
    }

}