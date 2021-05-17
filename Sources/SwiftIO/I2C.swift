import CSwiftIO

/**
 I2C (I square C) is a two wire protocol to communicate between different devices. The I2C class allows some operations through I2C protocol, including reading messages from a device and writing messages to a device.
 Currently the I2C ports support only master mode.
 
 - Note:
 Different I2C devices have different attributes. Please reference the device manual before using the functions below.
 This class allows the reading and writing of a byte `UInt8` or an array of bytes `[UInt8]`.

 */
 public final class I2C {
    private let id: Int32
    private let obj: UnsafeMutableRawPointer
    private var speedRawValue: UInt32
    
    private var speed: Speed {
        willSet {
            switch newValue {
                case .standard:
                speedRawValue = UInt32(SWIFT_I2C_SPEED_STANDARD)
                case .fast:
                speedRawValue = UInt32(SWIFT_I2C_SPEED_FAST)
                case .fastPlus:
                speedRawValue = UInt32(SWIFT_I2C_SPEED_FAST_PLUS)
            }
        }
    }


    /**
     Initialize a specific I2C interface as a master device.
     - Parameter idName: **REQUIRED** The name of the I2C interface.
     - Parameter speed: **OPTIONAL** The clock speed used to control the data transmission.
     
     ### Usage Example ###
     ````
     // Initialize an I2C interface I2C0.
     let i2cBus = I2C(Id.I2C0)
     ````
     */
    public init(_ idName: IdName,
                speed: Speed = .standard) {
        self.id = idName.value
        self.speed = speed

        switch speed {
            case .standard:
            speedRawValue = UInt32(SWIFT_I2C_SPEED_STANDARD)
            case .fast:
            speedRawValue = UInt32(SWIFT_I2C_SPEED_FAST)
            case .fastPlus:
            speedRawValue = UInt32(SWIFT_I2C_SPEED_FAST_PLUS)
        }
        if let ptr = swifthal_i2c_open(id) {
            obj = UnsafeMutableRawPointer(ptr)
            if swifthal_i2c_config(obj, speedRawValue) != 0 {
                print("I2C\(id) config failed!")
            }
        } else {
            fatalError("I2C\(idName.value) initialization failed!")
        }
    }

    deinit {
        swifthal_i2c_close(obj)
    }

    /**
     Get the current clock speed of the data transmission.
     
     - Returns: The current speed: `.standard`, `.fast` or `.fastPlus`.
     */
    public func getSpeed() -> Speed {
        return speed
    }

    /**
     Set the clock speed to change the transmission rate.
     - Parameter speed: The clock speed used to control the data transmission.
     */
    public func setSpeed(_ speed: Speed) {
        self.speed = speed
        if swifthal_i2c_config(obj, speedRawValue) != 0 {
            print("I2C\(id) setSpeed error!")
        }
    }

    /**
     Read one byte from a specified slave device with the given address.
     - Parameter address: The address of the slave device the board will communicate with.
     
     - Returns: One 8-bit binary number receiving from the slave device.
     */
    @inline(__always)
    public func readByte(from address: UInt8) -> UInt8? {
        var byte: UInt8 = 0
        
        let ret = swifthal_i2c_read(obj, address, &byte, 1)
        if ret == 0 {
            return byte
        } else {
            print("I2C\(id) readByte error!")
            return nil
        }
    }

    /**
     Read an array of data from a specified slave device with the given address.
     - Parameter count : The number of bytes to read.
     - Parameter address : The address of the slave device the board will communicate with.
     
     - Returns: An array of 8-bit binary numbers receiving from the slave device.
     */
    @inline(__always)
    public func read(count: Int, from address: UInt8) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: count)

        let ret = swifthal_i2c_read(obj, address, &data, Int32(count))

        if ret == 0 {
            return data
        } else {
            print("I2C\(id) read error!")
            return []
        }
    }

    /**
     Write a byte of data to a specified slave device with the given address.
     - Parameter byte : One 8-bit binary number to be sent to the slave device.
     - Parameter address : The address of the slave device the board will communicate with.
     */
    @inline(__always)
    public func write(_ byte: UInt8, to address: UInt8) {
        if swifthal_i2c_write(obj, address, [byte], 1) != 0 {
            print("I2C\(id) write error!")
        }
    }

    /**
     Write an array of data to a specified slave device with the given address.
     - Parameter data : A byte array to be sent to the slave device.
     - Parameter address : The address of the slave device the board will communicate with.
     */
    @inline(__always)
    public func write(_ data: [UInt8], count: Int? = nil, to address: UInt8) {
        let ret, length: Int32

        if let count = count {
            length = Int32(min(count, data.count))
        } else {
            length = Int32(data.count)
        }

        ret = swifthal_i2c_write(obj, address, data, length)

        if ret != 0 {
            print("I2C\(id) write error!")
        }
    }



    @inline(__always)
    public func writeRead(_ byte: UInt8, readCount: Int, address: UInt8) -> [UInt8] {
        var receivedData = [UInt8](repeating: 0, count: readCount)

        let ret = swifthal_i2c_write_read(obj, address, [byte], 1, &receivedData, Int32(readCount))
        if ret == 0 {
            return receivedData
        } else {
            print("I2C\(id) writeRead error!")
            return []
        }
    }

    /**
     Write an array of bytes to the slave device with the given address and then read the bytes sent from the device.
     - Parameter data : A byte array to be sent to the slave device.
     - Parameter readCount : The number of bytes to read.
     - Parameter address : The address of the slave device the board will communicate with.
     
     - Returns: An array of 8-bit binary numbers receiving from the slave device.
     */
    @inline(__always)
    public func writeRead(_ data: [UInt8], readCount: Int, address: UInt8) -> [UInt8] {
        var receivedData = [UInt8](repeating:0, count: readCount)

        let ret = swifthal_i2c_write_read(obj, address, data, Int32(data.count), &receivedData, Int32(readCount))
        if ret == 0 {
            return receivedData
        } else {
            print("I2C\(id) writeRead error!")
            return []
        }
    }
}

extension I2C {
    /**
     The clock signal is used to synchronize the data transmission between the devices.There are three available speed grades.
     */
    public enum Speed {
        case standard
        case fast
        case fastPlus
    }
}
