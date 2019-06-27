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

	let instanceNumber: Int32
	var outputMode: DigitalOutMode

    /**
     The current state of the output value.
     Write to this property would change the output value.
     
     */
    public var outputValue: Int {
        willSet {
			swiftHal_pinWrite(instanceNumber, Int32(newValue))
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
    public convenience init(_ name: DigitalName) {
        self.init(name, mode: .pushPull)
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
    public init(_ name: DigitalName, mode: DigitalOutMode) {
        instanceNumber = name.rawValue
        outputMode = mode
        swiftHal_pinConfig(instanceNumber, outputMode.rawValue)
        outputValue = 0
    }

    /**
     Set the output mode of a pin.
     
     - Parameter mode : The output mode.
     */
    public func setMode(_ mode: DigitalOutMode) {
        outputMode = mode
        swiftHal_pinConfig(instanceNumber, outputMode.rawValue)
	}

    /**
     Write value to a pin.

     - Parameter value : The value to be written.
     */
	public func write(_ value: Int) {
		outputValue = value
	}
    
    /**
     Reverse the current output value of a pin.
     */
    public func reverse() {
        outputValue = outputValue == 1 ? 0 : 1
    }
    
}




