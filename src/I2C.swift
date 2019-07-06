public class I2C {

    let deviceNumber: Int32
    var speed: I2CSpeed

    public convenience init(_ name: I2CName) {
        self.init(name, mode: .standard)
    }

    public init(_ name: I2CName, mode: I2CSpeed) {
        deviceNumber = name.rawValue
        speed = mode
        swiftHal_i2cConfig(deviceNumber, speed.rawValue)
    }

    public func setMode(_ mode: I2CSpeed) {
        speed = mode
        swiftHal_i2cConfig(deviceNumber, speed.rawValue)
	}

    public func write(to address: UInt8, _ writeArray: [UInt8]) {
        swiftHal_i2cWrite(deviceNumber, address, writeArray, Int32(writeArray.count))
    }

    public func read(to address: UInt8, count length: Int) -> [UInt8] {
        var readArray: [UInt8] = Array(repeating: 0, count: length)
        swiftHal_i2cRead(deviceNumber, address, &readArray, Int32(length))
        return readArray
    }
}