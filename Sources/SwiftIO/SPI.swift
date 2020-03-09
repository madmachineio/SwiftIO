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
    private var speed: Int {
        willSet {
            obj.speed = Int32(newValue)
        }
    }

    private func objectInit() {
        obj.id = id.rawValue
        obj.speed = Int32(speed)
        swiftHal_spiInit(&obj)
    }

    public init(_ id: Id,
                speed: Int = 1000000) {
        self.id = id
        self.speed = speed
        obj = SPIObject()
        objectInit()
    }

    deinit {
        swiftHal_spiDeinit(&obj)
    }

    public func getSpeed() -> Int {
        return speed
    }

    public func setSpeed(_ speed: Int) {
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

        swiftHal_spiRead(&obj, &data, Int32(count))
        return data
    }

    public func write(_ byte: UInt8) {
        let _data = [UInt8](repeating: byte, count: 1)

        swiftHal_spiWrite(&obj, _data, 1)
    }


    public func write(_ data: [UInt8]) {
        swiftHal_spiWrite(&obj, data, Int32(data.count))
    }
}

extension SPI {

    public enum Id: UInt8 {
        case SPI0, SPI1
    }

}