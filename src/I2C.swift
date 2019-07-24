public class I2C {

    var obj: I2CObject

    public convenience init(_ id: I2CId) {
        self.init(id, speed: .standard)
    }

    public init(_ id: I2CId, speed: I2CSpeed) {
        obj = I2CObject()
        obj.id = id.rawValue
        obj.speed = speed.rawValue
        swiftHal_i2cInit(&obj)
    }

    deinit {
        swiftHal_i2cDeinit(&obj)
    }

    public func write(_ byte: UInt8, to address: UInt8) {
        let array: [UInt8] = [byte]
        swiftHal_i2cWrite(&obj, address, array, 1);
    }

    public func write(_ array: [UInt8], to address: UInt8) {
        swiftHal_i2cWrite(&obj, address, array, UInt32(array.count))
    }


    public func read(from address: UInt8) -> UInt8 {
        var array: [UInt8] = [0]
        swiftHal_i2cRead(&obj, address, &array, 1)
        return array[0]
    }

    public func readArray(_ count: Int, from address: UInt8) -> [UInt8] {
        var array: [UInt8] = Array(repeating: 0, count: count)
        swiftHal_i2cRead(&obj, address, &array, UInt32(count))
        return array
    }

    public func read8bitReg(_ count: Int, from address: UInt8, in register: UInt8) -> [UInt8] {
        var array: [UInt8] = Array(repeating: 0, count: count)
        swiftHal_i2cRead8bitReg(&obj, address, register, &array, UInt32(count))
        return array
    }

    public func read16bitReg(_ count: Int, from address: UInt8, in register: UInt16) -> [UInt8] {
        var array: [UInt8] = Array(repeating: 0, count: count)
        swiftHal_i2cRead16bitReg(&obj, address, register, &array, UInt32(count))
        return array
    }
}
