
/**
 SPI is a four wire serial protocol for communication between devices.
  
 */
 public final class SPI {

    private let id: Int32
    private let obj: UnsafeRawPointer 

    private var speed: Int

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
    public init(_ idName: IdName,
                speed: Int = 1_000_000) {
        self.id = idName.value
        self.speed = speed

        if let ptr = swifthal_spi_open(id, Int32(speed), nil, nil) {
            obj = UnsafeRawPointer(ptr)
        } else {
            fatalError("SPI\(idName.value) initialization failed!")
        }
    }

    deinit {
        swifthal_spi_close(obj)
    }

    /**
     Get the current clock speed of SPI communication.
     
     - Returns: The current clock speed.
     */
    public func getSpeed() -> Int {
        return speed
    }

    /** TODO
     Set the speed of SPI communication.
     - Parameter speed: The clock speed used to control the data transmission.
     
    public func setSpeed(_ speed: Int) {
        self.speed = speed
        
        if swifthal_spi_config(obj, Int32(speed)) != 0 {
            print("SPI\(id) setSpeed error!")
        }
    }
    */

    /**
     Read a byte of data from the slave device.
     
     - Returns: One 8-bit binary number receiving from the slave device.
     */
    @inline(__always)
    public func readByte() -> UInt8 {
        var data: [UInt8] = [0]
        
        let ret = swifthal_spi_read(obj, &data, 1)
        if ret == 0 {
            return data[0]
        } else {
            print("SPI\(id) readByte error!")
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

        let ret = swifthal_spi_read(obj, &data, Int32(count))
        if ret == 0 {
            return data
        } else {
            print("SPI\(id) read error!")
            return []
        }
    }

    /**
     Write a byte of data to the slave device.
     - Parameter byte: One 8-bit binary number to be sent to the slave device.
     */
    @inline(__always)
    public func write(_ byte: UInt8) {
        if swifthal_spi_write(obj, [byte], 1) != 0 {
            print("SPI\(id) write error!")
        }
    }

    /**
     Write an array of data to the slave device.
     - Parameter data: A byte array to be sent to the slave device.
     */
    @inline(__always)
    public func write(_ data: [UInt8], count: Int? = nil) {
        let ret: Int32

        if let length = count {
            ret = swifthal_spi_write(obj, data, Int32(length))
        } else {
            ret = swifthal_spi_write(obj, data, Int32(data.count))
        }

        if ret != 0 {
            print("SPI\(id) write error!")
        }
    }
}

