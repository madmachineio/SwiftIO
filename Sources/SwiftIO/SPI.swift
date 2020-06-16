import CHal

/**
 SPI is a four wire serial protocol for communication between devices.
  
 */
 public final class SPI {

    private var obj: SPIObject

    private let id: IdName
    private var speed: Int {
        willSet {
            obj.speed = Int32(newValue)
        }
    }

    private func objectInit() {
        obj.idNumber = id.number
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
     let spi = SPI(Id.SPI0)
     ````
     */
    public init(_ id: IdName,
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
        var data: [UInt8] = [0]
        
        let ret = swiftHal_spiRead(&obj, &data, 1)
        if ret == 0 {
            return data[0]
        } else {
            print("SPI readByte error!")
            return 0
        }
    }

    /**
     Read an array of data from the slave device.
     - Parameter count: The number of bytes receiving from the slave device.
     - Returns: An array of 8-bit binary numbers receiving from the slave device.
     */
    @inline(__always)
    public func read(count: Int) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: count)

        let ret = swiftHal_spiRead(&obj, &data, Int32(count))
        if ret == 0 {
            return data
        } else {
            print("SPI read error!")
            return []
        }
    }

    /**
     Write a byte of data to the slave device.
     - Parameter byte: One 8-bit binary number to be sent to the slave device.
     */
    @inline(__always)
    public func write(_ byte: UInt8) {
        swiftHal_spiWrite(&obj, [byte], 1)
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

