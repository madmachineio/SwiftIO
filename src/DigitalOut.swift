/**
 Use the DigitalOut class to set the value of a digital output pin.
 
 ### Example: A simple hello world.
 
 ````
 import SwiftIO
 
 main() {
    //Create a DigitalOut to .D0
    let pin = DigitalOut(.D0)
 
    //Reverse the output value every 1 second
    while true {
        pin.reverse()
        msSleep(1000)
    }
 }
 ````
 
 */
public class DigitalOut {

    var obj: DigitalIOObject

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
     Create a DigitalOut to a specified pin, the default output mode is `.pushPull`.
     
     - Parameter name: The Digital pin name on the board.
     
     ### Usage Example: ###
     ````
     let pin = DigitalOut(.D0)
     ````
     */
    public convenience init(_ id: DigitalIOId) {
        self.init(id, mode: .pushPull)
    }
    
    /**
     Create a DigitalOut to a specified pin.
     
     - Parameter name: The Digital pin name on the board.
     - Parameter mode: The output mode.

     ### Usage Example: ###
     ````
     let pin = DigitalOut(.D0, mode: .pushPull)
     ````
     */
    public init(_ id: DigitalIOId, mode: DigitalOutMode) {
        obj = DigitalIOObject()
        obj.id = id.rawValue
        obj.direction = DigitalIODirection.output.rawValue
        obj.outputMode = mode.rawValue
        swiftHal_gpioInit(&obj)
        value = false
    }

    deinit {
        swiftHal_gpioDeinit(&obj)
    }

    /**
     Set the output mode of a pin.
     
     - Parameter mode : The output mode.
     */
    public func setMode(_ mode: DigitalOutMode) {
        obj.outputMode = mode.rawValue
        swiftHal_gpioConfig(&obj)
	}

    /**
     Write value to a pin.

     - Parameter value : The value to be written.
     */
	public func write(_ value: Bool) {
		self.value = value
	}
    
    /**
     Reverse the current output value of a pin.
     */
    public func reverse() {
        value = value ? false : true
    }

    public func getState() -> Bool {
        return value
    }
    
}




