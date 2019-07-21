/// Use the DigitalIn class to read the value of a digital input pin.
public class DigitalIn {
		
    var obj: DigitalIOObject

    /**
     Use this property to get the input value.
     
     - Attention: This property is **read only!**
     */
	public var inputValue: Int {
		return Int(swiftHal_pinRead(&obj))
	}

    /**
     Create a DigitalIn to a specified pin.
     
     - Parameter name: The Digital pin name on the board, the default input mode is `.pullDown`.
     
     ### Usage Example: ###
     ````
     let pin = DigitalIn(.D0)
     ````
     */
    public convenience init(_ id: DigitalIOId) {
        self.init(id, mode: .pullDown)
    }

    /**
     Create a DigitalIn to a specified pin.
     
     - parameter name: The Digital pin name on the board.
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
        obj.direction = DigitalDirection.input.rawValue
        obj.inputMode = mode.rawValue
		swiftHal_pinInit(&obj)
	}

    deinit {
        print("DigitalIn Deinit")
        if obj.callbackMode != DigitalCallbackMode.disable.rawValue {
            removeCallback()
        }
        swiftHal_pinDeinit(&obj)
    }

    /**
     Set the input mode for a digital pin.
     
     - Parameter mode : The input mode.
     */
	public func setMode(_ mode: DigitalInMode) {
		obj.inputMode = mode.rawValue
		swiftHal_pinConfig(&obj)
	}


    /**
     Read value from a digital pin.
     
     - Attention: Depends on the hardware, the internal pull resister may be very weak. **Don't** just rely on the pull resister for reading the value. **Especially** when you just changed the input mode, the internel pad need some time to charge or discharge through the pull resister!
     
     - Returns: 0 or 1 of the logic value.
     */
	public func read() -> Int {
		return inputValue
	}
    /*
    public func addCallback(_ callback: @escaping @convention(c) ()->Void, mode: DigitalCallbackMode) {
        obj.callbackMode = mode.rawValue
        swiftHal_pinAddCallback(&obj, callback)
    }*/

    public func addCallback(_ callback: @escaping @convention(c) ()->Void, mode: DigitalCallbackMode) {
        obj.callbackMode = mode.rawValue
        obj.callback = callback
        swiftHal_pinAddCallback(&obj)
    }

    public func removeCallback() {
        obj.callbackMode = DigitalCallbackMode.disable.rawValue
        swiftHal_pinRemoveCallback(&obj)
    }

}




