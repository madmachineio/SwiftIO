/**
 I2C is a two wire serial protocol for communicating between devices.
 

 ### Example: A simple hello world.
 
 ````
 import SwiftIO
 
 main() {
 //Create a i2c bus to .I2C0
 let i2c = I2C(.I2C0)
 
 while true {

 }
 }
 ````
 
 */
 public class I2C {

    var obj: I2CObject


    public init(_ id: I2CId, speed: I2CSpeed = .standard) {
        obj = I2CObject()
        obj.id = id.rawValue
        obj.speed = speed.rawValue
        swiftHal_i2cInit(&obj)
    }

    deinit {
        swiftHal_i2cDeinit(&obj)
    }

    public func setSpeed(_ speed: I2CSpeed) {
        obj.speed = speed.rawValue
        swiftHal_i2cConfig(&obj)
    }
/*
    public func write<T: BinaryInteger>(_ byte: T, to address: T) {
        let byteU8: UInt8 = numericCast(byte)
        let arrayU8: [UInt8] = [byteU8]
        let addressU8: UInt8 = numericCast(address)
        swiftHal_i2cWrite(&obj, addressU8, arrayU8, 1)
    }

    public func write<T: BinaryInteger>(_ array: [T], to address: T) {
        let arrayU8: [UInt8] = array.map(numericCast) as [UInt8]
        let addressU8: UInt8 = numericCast(address)
        swiftHal_i2cWrite(&obj, addressU8, arrayU8, UInt32(array.count))
    }
*/
    public func readByte(from address: UInt8) -> UInt8 {
        var data = [UInt8](repeating: 0, count: 1)
        
        swiftHal_i2cRead(&obj, address, &data, 1)
        return data[0]
    }

    public func readWord(from address: UInt8) -> UInt16 {
        var data = [UInt8](repeating: 0, count: 2)

        swiftHal_i2cRead(&obj, address, &data, 2)
        return UInt16(data[1]) << 8 | UInt16(data[0])
    }

    public func read(count: Int, from address: UInt8) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: count)

        swiftHal_i2cRead(&obj, address, &data, UInt32(count))
        return data
    }

    public func writeByte(_ value: UInt8, to address: UInt8) {
        var data = [UInt8](repeating: 0, count: 1)

        data[0] = value
        swiftHal_i2cWrite(&obj, address, data, 1)
    }

    public func writeWord(_ value: UInt16, to address: UInt8) {
        var data = [UInt8](repeating: 0, count: 2)

        data[0] = UInt8(value & 0xFF)
        data[1] = UInt8(value >> 8)
        swiftHal_i2cWrite(&obj, address, data, 2)
    }

    public func write(_ value: [UInt8], to address: UInt8) {
        swiftHal_i2cWrite(&obj, address, value, UInt32(value.count))
    }

    public func writeRead(_ value: [UInt8], readCount: Int, address: UInt8) -> [UInt8] {
        var data = [UInt8](repeating:0, count: readCount)

        swiftHal_i2cWriteRead(&obj, address, value, UInt32(value.count), &data, UInt32(readCount))
        return data
    }

}

extension I2C {

    public enum I2CId: UInt8 {
        case I2C0, I2C1
    }

    public enum I2CSpeed: UInt32 {
        case standard = 100000, fast = 400000, fastPlus = 1000000
    }
}