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
 
 */public class I2C {

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

    public func setSpeed(_ speed: I2CSpeed) {
        obj.speed = speed.rawValue
        swiftHal_i2cConfig(&obj)
    }

    public func write<T: BinaryInteger>(_ byte: T, to address: T) {
        let byteU8: UInt8 = numericCast(byte)
        let arrayU8: [UInt8] = [byteU8]
        let addressU8: UInt8 = numericCast(address)
        swiftHal_i2cWrite(&obj, addressU8, arrayU8, 1);
    }

    public func write<T: BinaryInteger>(_ array: [T], to address: T) {
        let arrayU8: [UInt8] = array.map(numericCast) as [UInt8]
        let addressU8: UInt8 = numericCast(address)
        swiftHal_i2cWrite(&obj, addressU8, arrayU8, UInt32(array.count))
    }


    public func read<T: BinaryInteger>(from address: T) -> UInt8 {
        let addressU8: UInt8 = numericCast(address)
        var array: [UInt8] = [0]
        swiftHal_i2cRead(&obj, addressU8, &array, 1)
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
