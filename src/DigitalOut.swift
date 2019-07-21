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
    public var outputValue: UInt32 {
        willSet {
			swiftHal_pinWrite(&obj, newValue)
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
        obj.direction = DigitalDirection.output.rawValue
        obj.outputMode = mode.rawValue
        swiftHal_pinInit(&obj)
        outputValue = 0
    }

    deinit {
        print("DigitalOut Deinit")
        swiftHal_pinDeinit(&obj)
    }

    /**
     Set the output mode of a pin.
     
     - Parameter mode : The output mode.
     */
    public func setMode(_ mode: DigitalOutMode) {
        obj.outputMode = mode.rawValue
        swiftHal_pinConfig(&obj)
	}

    /**
     Write value to a pin.

     - Parameter value : The value to be written.
     */
	public func write(_ value: UInt32) {
		outputValue = value
	}
    
    /**
     Reverse the current output value of a pin.
     */
    public func reverse() {
        outputValue = outputValue == 1 ? 0 : 1
    }
    
}




