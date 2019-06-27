///  Use the DigitalOut class to set the value of a digital output pin.
public class DigitalOut {

	let instanceNumber: Int32
	var outputMode: OutputMode

    /**
     Use this property to set the output value.
     
     - Attention: This property is **write only!**
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
    public init(_ name: DigitalName, mode: OutputMode) {
        instanceNumber = name.rawValue
        outputMode = mode
        swiftHal_pinConfig(instanceNumber, outputMode.rawValue)
        outputValue = 0
    }

    /**
     Set the output mode of a pin.
     
     - Parameter mode : The output mode.
     */
    public func setMode(_ mode: OutputMode) {
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
}




