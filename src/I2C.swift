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


    public func write(to address: UInt8, _ writeArray: [UInt8]) {
        swiftHal_i2cWrite(&obj, address, writeArray, UInt32(writeArray.count))
    }

    public func read(from address: UInt8, count length: Int) -> [UInt8] {
        var readArray: [UInt8] = Array(repeating: 0, count: length)
        swiftHal_i2cRead(&obj, address, &readArray, UInt32(length))
        return readArray
    }

    public func read8bitReg(from address: UInt8, for reg: UInt8, count length: Int) -> [UInt8] {
        var readArray: [UInt8] = Array(repeating: 0, count: length)
        swiftHal_i2cRead8bitReg(&obj, address, reg, &readArray, UInt32(length))
        return readArray
    }

    public func read16bitReg(from address: UInt8, for reg: UInt16, count length: Int) -> [UInt8] {
        var readArray: [UInt8] = Array(repeating: 0, count: length)
        swiftHal_i2cRead16bitReg(&obj, address, reg, &readArray, UInt32(length))
        return readArray
    }
}