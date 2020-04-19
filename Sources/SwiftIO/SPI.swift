/**
 SPI is a four wire serial protocol for communication between devices.
 

 
 */
 final public class SPI {

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

    /**
     Initialize a specified interface for SPI communication as a master device.
     - Parameter id: **REQUIRED** The name of the SPI interface.
     - Parameter speed: **OPTIONAL** The clock speed used to control the data transmission.
     
     ### Usage Example ###
     ````
     // Initialize a SPI interface SPI0.
     let spi = SPI(.SPI0)
     ````
     */
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

    /**
     Get the current clock speed of SPI communication.
     
     - Returns: The current clock speed.
     */
    public func getSpeed() -> Int {
        return speed
    }

    /**
     Set the speed of SPI communication.
     - Parameter speed: The clock speed used to control the data transmission.
     */
    public func setSpeed(_ speed: Int) {
        self.speed = speed
        swiftHal_spiConfig(&obj)
    }

    /**
     Read a byte of data from the slave device.
     
     - Returns: One 8-bit binary number receiving from the slave device.
     */
    @inline(__always)
    public func readByte() -> UInt8 {
        var data = [UInt8](repeating: 0, count: 1)
        
        swiftHal_spiRead(&obj, &data, 1)
        return data[0]
    }

    /**
     Read an array of data from the slave device.
     - Parameter count: The number of bytes receiving from the slave device.
     - Returns: An array of 8-bit binary numbers receiving from the slave device.
     */
    @inline(__always)
    public func read(count: Int) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: count)

        swiftHal_spiRead(&obj, &data, Int32(count))
        return data
    }

    /**
     Write a byte of data to the slave device.
     - Parameter byte: One 8-bit binary number to be sent to the slave device.
     */
    @inline(__always)
    public func write(_ byte: UInt8) {
        let _data = [UInt8](repeating: byte, count: 1)

        swiftHal_spiWrite(&obj, _data, 1)
    }

    /**
     Write an array of data to the slave device.
     - Parameter data: A byte array to be sent to the slave device.
     */
    @inline(__always)
    public func write(_ data: [UInt8]) {
        swiftHal_spiWrite(&obj, data, Int32(data.count))
    }

    /**
     Write raw data to the slave device.
     - Parameter data: Raw data to be sent to the slave device.
     */
    @inline(__always)
    public func write(_ data: UnsafeRawBufferPointer) {
        guard data.baseAddress != nil else { return }
        let ptr = data.bindMemory(to: UInt8.self)
        swiftHal_spiWrite(&obj, ptr.baseAddress!, Int32(ptr.count))
    }
}

extension SPI {

    /**
     SPI0 and SPI1 are designed for SPI communication. Four wires are required: SCK (serial clock), SDO (data sending), SDI (data receiving), CS (slave selection).
     
     */
    public enum Id: UInt8 {
        case SPI0, SPI1
    }

}
