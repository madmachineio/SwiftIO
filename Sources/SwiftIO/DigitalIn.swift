/**
 The DigitalIn class is intended to detect the state of a digital input pin. The input value is either true(1) or false(0).
 
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
        sleep(ms: 1000)
    }
 }
 ````
 */
public class DigitalIn {
		
    var obj: DigitalIOObject

    private let id: Id
    private var mode: Mode {
        willSet {
            obj.inputMode = newValue.rawValue
        }
    }
    private var interruptMode: InterruptMode {
        willSet {
            obj.interruptMode = newValue.rawValue
        }
    }
    private var interruptState: InterruptState {
        willSet {
            obj.interruptState = newValue.rawValue
        }
    }
    private var callback: (()->Void)?

    
    private func objectInit() {
        obj.id = id.rawValue
        obj.direction = Direction.input.rawValue
        obj.inputMode = mode.rawValue
        obj.interruptMode = interruptMode.rawValue
        obj.interruptState = interruptState.rawValue
        swiftHal_gpioInit(&obj)
    }

    /**
     Initialize a DigitalIn to a specified pin.
     
     - parameter id: **REQUIRED** The Digital id on the board. See Id for reference.
     - parameter mode: **OPTIONAL**The input mode.
     
     This text is above the horizontal rule.
     - - -
     And this is below.
     
     For more information, see [The Swift Programming Language.](http://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/)
     
     - SeeAlso:
     [The Swift Standard Library Reference](https://developer.apple.com/library/prerelease/ios//documentation/General/Reference/SwiftStandardLibraryReference/index.html)
     
     ### Usage Example
     ````
     let pin = DigitalIn(.D0, mode: .pullDown)
     ````
     */
	public init(_ id: Id,
                mode: Mode = .pullDown) {
        self.id = id
        self.mode = mode
        self.interruptMode = .rising
        self.interruptState = .disable
        obj = DigitalIOObject()
        objectInit()
	}

    deinit {
        if callback != nil {
            removeInterrupt()
        }
        swiftHal_gpioDeinit(&obj)
    }

    /**
     Get the current input mode on a specified pin.
     
     - Returns: The current input mode: `.pullUp`, `.pullDown` or `.pullNone`.
     */
    public func getMode() -> Mode {
        return mode
    }

    /**
     Set the input mode for a digital pin.
     
     - Parameter mode : The input mode.
     */
	public func setMode(_ mode: Mode) {
		self.mode = mode
		swiftHal_gpioConfig(&obj)
	}


    /**
     Read the value on a digital pin.
     
     - Attention: Depends on the hardware, the internal pull resister may be very weak. **Don't** just rely on the pull resister for reading the value. **Especially** when you just changed the input mode, the internel pad need some time to charge or discharge through the pull resister!
     
     - Returns: `true` or `false` of the logic value.
     */
    @inline(__always)
	public func read() -> Bool {
		return swiftHal_gpioRead(&obj) == 1 ? true : false
	}

    /**
     Add a callback function to a pin.
     - Parameter mode : The input mode.
     - Parameter enable : Whether to enable the interrupt.
     - Parameter callback : A void function without a return value.
     */    
    public func setInterrupt(_ mode: InterruptMode, enable: Bool = true, callback: @escaping ()->Void) {
        interruptMode = mode
        self.callback = callback
        interruptState = enable ? .enable : .disable
        swiftHal_gpioAddSwiftMember(&obj, getClassPtr(self)) {(ptr)->Void in
            let mySelf = Unmanaged<DigitalIn>.fromOpaque(ptr!).takeUnretainedValue()
            mySelf.callback!()
        }
        swiftHal_gpioAddCallback(&obj)
    }

    /**
     Enable the interrupt.
    
     */
    public func enableInterrupt() {
        interruptState = .enable
        swiftHal_gpioEnableCallback(&obj)
    }

    /**
     Disable the interrupt.
    
     */
    public func disableInterrupt() {
        interruptState = .disable
        swiftHal_gpioDisableCallback(&obj)
    }

    /**
     Get the current interrupt state.
     
     - Returns: The current input mode: `.enable` or `.diable`.
     */
    public func getInterruptState() -> InterruptState {
        return interruptState
    }

    /**
     Remove the interrupt.
    
     */
    public func removeInterrupt() {
        interruptState = .disable
        swiftHal_gpioRemoveCallback(&obj)
        callback = nil
    }

}




extension DigitalIn {
    
    /**
     The digital input pins are D0 to D45 on the board.
    
     */
    public typealias Id = DigitalOut.Id
    
    public typealias Direction = DigitalOut.Direction

    /**
     The digital input modes can change the default state (high, low or floating) of a pin by using the pull resistors.

     */
    public enum Mode: UInt8 {
        case pullDown = 1, pullUp, pullNone
    }

    /**
     The interrupt modes are rising, falling and bothEdge. A rising edge is the transition of a digital input signal from high to low and a falling edge is from low to high. The interrupt will be triggered when detecting either or both of them.

     */
    public enum InterruptMode: UInt8 {
        case rising = 1, falling, bothEdge
    }

    /**
     This value determine whether the interrupt will be enabled and occur.

     */
    public enum InterruptState: UInt8 {
        case disable, enable
    }
}
