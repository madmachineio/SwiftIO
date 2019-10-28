/**
 Use the DigitalOut class to set the value of a digital output pin.
 
 ### Example: A simple hello world.
 
 ````
 import SwiftIO
 
 func main() {
    //Create a DigitalOut to .D0
    let pin = DigitalOut(.D0)
 
    //Reverse the output value every 1 second
    while true {
        pin.reverse()
        sleep(1000)
    }
 }
 ````
 */
public class DigitalOut {

    private var obj: DigitalIOObject

    private var mode: DigitalOutMode {
        willSet {
            obj.outputMode = newValue.rawValue
            print("newValue = \(newValue)")
        }
    }

    /**
     The current state of the output value.
     Write to this property would change the output value.
     
     */
    public var value: Bool {
        willSet {
			swiftHal_gpioWrite(&obj, newValue ? 1 : 0)
		}
	}
    
    
    /**
     Create a DigitalOut to a specified pin.
     
     - Parameter name: The Digital pin name on the board.
     - Parameter mode: The output mode.
     - Parameter value: The output value.

     ### Usage Example: ###
     ````
     let pin = DigitalOut(.D0, mode: .pushPull)
     ````
     */
    public init(_ id: DigitalIOId, mode: DigitalOutMode = .pushPull, value: Bool = false) {
        obj = DigitalIOObject()
        obj.id = id.rawValue
        obj.direction = DigitalIODirection.output.rawValue
        obj.outputMode = mode.rawValue

        self.mode = mode
        self.value = value

        swiftHal_gpioInit(&obj)
		swiftHal_gpioWrite(&obj, value ? 1 : 0)
    }

    deinit {
        swiftHal_gpioDeinit(&obj)
    }

    /**
     Set the output mode of a pin.
     
     - Parameter mode : The output mode.
     */
    public func setMode(_ mode: DigitalOutMode) {
        self.mode = mode
        swiftHal_gpioConfig(&obj)
	}

    /**
     Get the output mode of a pin.

     */
    public func getMode() -> DigitalOutMode {
        return mode
    }

    /**
     Write value to a pin.

     - Parameter value : The value to be written.
     */
	public func write(_ value: Bool) {
		self.value = value
	}
    
    /**
     Toggle the current output value of a pin.
     */
    public func toggle() {
        value = value ? false : true
    }

    /**
     Get the current output value of a pin.
     */
    public func getValue() -> Bool {
        return value
    }
    
}


extension DigitalOut {

    public enum DigitalOutMode: UInt8 {
        case pushPull = 1, openDrain
    }    
}

