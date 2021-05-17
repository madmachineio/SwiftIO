import CSwiftIO

/**
 SPI is a four wire serial protocol for communication between devices.
  
 */
 public final class SPI {

    private let id: Int32
    private let obj: UnsafeMutableRawPointer 

    private var speed: Int
    private var csPin: DigitalOut?

    /**
     Initialize a specified interface for SPI communication as a master device.
     - Parameter id: **REQUIRED** The name of the SPI interface.
     - Parameter speed: **OPTIONAL** The clock speed used to control the data transmission.
     - Parameter csPin: **OPTIONAL** If the csPin is nil, you have to control it manually through any DigitalOut pin.
     
     ### Usage Example ###
     ````
     // Initialize a SPI interface SPI0.
     let spi = SPI(Id.SPI0)
     ````
     */
    public init(_ idName: IdName,
                speed: Int = 1_000_000,
                csPin: DigitalOut? = nil) {
        self.id = idName.value
        self.speed = speed
        self.csPin = csPin

        if let ptr = swifthal_spi_open(id, Int32(speed), nil, nil) {
            obj = UnsafeMutableRawPointer(ptr)
            if let cs = csPin {
                cs.setMode(.pushPull)
            }
        } else {
            fatalError("SPI\(idName.value) initialization failed!")
        }
    }

    deinit {
        swifthal_spi_close(obj)
    }

    @inline(__always)
    func csEnable() {
        if let cs = csPin {
            cs.write(false)
        }
    }

    @inline(__always)
    func csDisable() {
        if let cs = csPin {
            cs.write(true)
        }
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
        if swifthal_spi_config(obj, Int32(speed)) != 0 {
            print("SPI\(id) setSpeed error!")
        } else {
            self.speed = speed
        }
    }
    

    /**
     Read a byte of data from the slave device.
     
     - Returns: One 8-bit binary number receiving from the slave device.
     */
    @inline(__always)
    public func readByte() -> UInt8? {
        var byte: UInt8 = 0

        csEnable()
        let ret = swifthal_spi_read(obj, &byte, 1)
        csDisable()
       
        if ret == 0 {
            return byte
        } else {
            print("SPI\(id) readByte error!")
            return nil
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

        csEnable()
        let ret = swifthal_spi_read(obj, &data, Int32(count))
        csDisable()

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
        csEnable()
        let ret = swifthal_spi_write(obj, [byte], 1)
        csDisable()

        if ret != 0 {
            print("SPI\(id) write error!")
        }
    }

    /**
     Write an array of data to the slave device.
     - Parameter data: A byte array to be sent to the slave device.
     */
    @inline(__always)
    public func write(_ data: [UInt8], count: Int? = nil) {
        let ret, length: Int32

        if let count = count {
            length = Int32(min(count, data.count))
        } else {
            length = Int32(data.count)
        }

        csEnable()
        ret = swifthal_spi_write(obj, data, length)
        csDisable()

        if ret != 0 {
            print("SPI\(id) write error!")
        }
    }
}

