/**
 Use the DigitalIn class to red the value of a digital input pin.
 
 ### Example: A simple hello world.
 
 ````
 import SwiftIO
 
 func main() {
    //Initialize a DigitalIn to DigitalId.D0
    let pin = DigitalIn(.D0)
 
    //Read and print the input value every 1 second
    while true {
        var value = pin.read()
        print("The input value is \(value)")
        sleep(1000)
    }
 }
 ````
 */
public class DigitalIn {
		
    var obj: DigitalIOObject

    /**
     Use this property to get the input value.
     
     - Attention: This property is **read only!**
     */
	public var value: Bool {
		return swiftHal_gpioRead(&obj) == 1 ? true : false
	}

    /**
     Initialize a DigitalIn to a specified pin.
     
     - Parameter id: The Digital id on the board, the default input mode is `.pullDown`.
     
     ### Usage Example: ###
     ````
     let pin = DigitalIn(.D0)
     ````
     */
    public convenience init(_ id: DigitalIOId) {
        self.init(id, mode: .pullDown)
    }

    /**
     Initialize a DigitalIn to a specified pin.
     
     - parameter id: The Digital id on the board.
     - parameter mode: The input mode.
     
     This text is above the horizontal rule.
     - - -
     And this is below.
     
     For more information, see [The Swift Programming Language.](http://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/)
     
     - SeeAlso:
     [The Swift Standard Library Reference](https://developer.apple.com/library/prerelease/ios//documentation/General/Reference/SwiftStandardLibraryReference/index.html)
     
     ### Usage Example: ###
     ````
     let pin = DigitalIn(.D0, mode: .pullDown)
     ````
     */
	public init(_ id: DigitalIOId, mode: DigitalInMode) {
        obj = DigitalIOObject()
        obj.id = id.rawValue
        obj.direction = DigitalIODirection.input.rawValue
        obj.inputMode = mode.rawValue
		swiftHal_gpioInit(&obj)
	}

    deinit {
        if obj.callback != nil {
            removeCallback()
        }
        swiftHal_gpioDeinit(&obj)
    }

    /**
     Set the input mode for a digital pin.
     
     - Parameter mode : The input mode.
     */
	public func setMode(_ mode: DigitalInMode) {
		obj.inputMode = mode.rawValue
		swiftHal_gpioConfig(&obj)
	}


    /**
     Read the value on a digital pin.
     
     - Attention: Depends on the hardware, the internal pull resister may be very weak. **Don't** just rely on the pull resister for reading the value. **Especially** when you just changed the input mode, the internel pad need some time to charge or discharge through the pull resister!
     
     - Returns: `true` or `false` of the logic value.
     */
	public func read() -> Bool {
		return value
	}

    /**
     Add a callback function to a pin.
    
     
     - Returns: 0 or 1 of the logic value.
     */    
    public func on(_ mode: DigitalInCallbackMode, callback: @escaping @convention(c) ()->Void) {
        obj.callbackMode = mode.rawValue
        obj.callback = callback
        swiftHal_gpioAddCallback(&obj)
    }

    public func removeCallback() {
        obj.callbackMode = DigitalInCallbackMode.disable.rawValue
        obj.callback = nil
        swiftHal_gpioRemoveCallback(&obj)
    }

}




