/**
 I2C (I square C) is a two wire protocol to communicate between different devices.

 Currently the I2C ports support only master mode.
 

 ### BASIC USAGE
 
 The I2C class allows some operations through I2C protocol, including reading messages from a device and writing messages to a device.
 
 - Note:
 Different I2C devices have different attributes to it. Please reference the device manual to use the functions below.
 This class allows the reading and writing of a byte (Uint8) or an array of bytes ([UInt8]).
 
 ````
 import SwiftIO
 
 func main() {
    // initiate an I2C interface to .I2C0
    let i2cBus = I2C(.I2C0)
 
    while true {
        pin.toggle()
        sleep(ms: 1000)
    }
 }
 ````
 
 */
 public class I2C {

    private var obj: I2CObject

    private let id: Id
    private var speed: Speed {
        willSet {
            obj.speed = newValue.rawValue
        }
    }

    private func objectInit() {
        obj.id = id.rawValue
        obj.speed = speed.rawValue
        swiftHal_i2cInit(&obj)
    }

    /**
     An initiation of the class to a specific I2C interface as a master device.
     - Parameter id: **REQUIRED** The name of the I2C interface.
     - Parameter mode: **OPTIONAL** The output mode of the pin. `.pushPull` for default.
     - Parameter value: **OPTIONAL** The output value after initiation. `false` for default.     */
    public init(_ id: Id,
                speed: Speed = .standard) {
        self.id = id
        self.speed = speed
        obj = I2CObject()
        objectInit()
    }

    deinit {
        swiftHal_i2cDeinit(&obj)
    }

    public func getSpeed() -> Speed {
        return speed
    }

    public func setSpeed(_ speed: Speed) {
        self.speed = speed
        swiftHal_i2cConfig(&obj)
    }

    public func readByte(from address: UInt8) -> UInt8 {
        var data = [UInt8](repeating: 0, count: 1)
        
        swiftHal_i2cRead(&obj, address, &data, 1)
        return data[0]
    }


    public func read(count: Int, from address: UInt8) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: count)

        swiftHal_i2cRead(&obj, address, &data, UInt32(count))
        return data
    }

    public func write(_ value: UInt8, to address: UInt8) {
        var data = [UInt8](repeating: 0, count: 1)

        data[0] = value
        swiftHal_i2cWrite(&obj, address, data, 1)
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

    public enum Id: UInt8 {
        case I2C0, I2C1
    }

    public enum Speed: UInt32 {
        case standard = 100000, fast = 400000, fastPlus = 1000000
    }
}
