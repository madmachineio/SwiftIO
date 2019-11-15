/**
 SPI is a two wire serial protocol for communicating between devices.
 

 ### Example: A simple hello world.
 
 ````
 import SwiftIO
 
 func main() {
 //Create a spi bus to .SPI0
 let spi = SPI(.SPI0)
 
    while true {

    }
 }
 ````
 
 */
 public class SPI {

    private var obj: SPIObject

    private let id: Id
    private var speed: UInt {
        willSet {
            obj.speed = UInt32(newValue)
        }
    }

    private func objectInit() {
        obj.id = id.rawValue
        obj.speed = UInt32(speed)
        swiftHal_spiInit(&obj)
    }

    public init(_ id: Id,
                speed: UInt = 1000000) {
        self.id = id
        self.speed = speed
        obj = SPIObject()
        objectInit()
    }

    deinit {
        swiftHal_spiDeinit(&obj)
    }

    public func getSpeed() -> UInt {
        return speed
    }

    public func setSpeed(_ speed: UInt) {
        self.speed = speed
        swiftHal_spiConfig(&obj)
    }

    public func readByte() -> UInt8 {
        var data = [UInt8](repeating: 0, count: 1)
        
        swiftHal_spiRead(&obj, &data, 1)
        return data[0]
    }

    public func read(count: Int) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: count)

        swiftHal_spiRead(&obj, &data, UInt32(count))
        return data
    }

    public func writeByte(_ value: UInt8) {
        var data = [UInt8](repeating: 0, count: 1)

        data[0] = value
        swiftHal_spiWrite(&obj, data, 1)
    }


    public func write(_ value: [UInt8]) {
        swiftHal_spiWrite(&obj, value, UInt32(value.count))
    }



}

extension SPI {

    public enum Id: UInt8 {
        case SPI0, SPI1
    }

}