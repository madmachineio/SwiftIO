import CHal

/**
 The DigitalIn class is intended to detect the state of a digital input pin. The input value is either true(1) or false(0).
 
 ### Example: Read and print the input value on a digital input pin.
 
 ````
 import SwiftIO
 
 //Initialize a DigitalIn to the digital pin D0.
 let pin = DigitalIn(Id.D0)
 
 //Read and print the input value every 1 second.
 while true {
     var value = pin.read()
     print("The input value is \(value)")
     sleep(ms: 1000)
 }
 ````
 */
public final class DigitalIn {
		
    private var obj: DigitalIOObject

    private let id: IdName
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
        obj.idNumber = id.number
        obj.direction = Direction.input.rawValue
        obj.inputMode = mode.rawValue
        obj.interruptMode = interruptMode.rawValue
        obj.interruptState = interruptState.rawValue
        swiftHal_gpioInit(&obj)
    }

    /**
     Initialize a DigitalIn to a specified pin.
     
     - parameter id: **REQUIRED** The Digital id on the board. See Id for reference.
     - parameter mode: **OPTIONAL** The input mode. `.pullDown` by default.
     
     
     ### Usage Example ###
     ````
     // The most simple way of initiating a pin D0, with all other parameters set to default.
     let pin = DigitalIn(Id.D0)
     
     // Initialize the pin D0 with the pulldown mode.
     let pin = DigitalIn(Id.D0, mode: .pullDown)
     ````
     */
	public init(_ id: IdName,
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
     Set the input mode for a digital input pin.
     
     - Parameter mode : The input mode.
     */
	public func setMode(_ mode: Mode) {
		self.mode = mode
		swiftHal_gpioConfig(&obj)
	}


    /**
     Read the value from a digital input pin.
     
     - Attention: Dependind on the hardware, the internal pull resister may be very weak. **Don't** just rely on the pull resister for reading the value. **Especially** when you just changed the input mode, the internel pad need some time to charge or discharge through the pull resister!
     
     - Returns: `true` or `false` of the logic value.
     */
    @inline(__always)
	public func read() -> Bool {
		return swiftHal_gpioRead(&obj) == 1 ? true : false
	}

    /**
     Add a callback function to a specified digital pin to set interrupt by detcting the changes of the signal. Once the risng or falling edge is detected, the processor will suspend the normal execution to execute the designated task. 
     
     The task should be able to finish in a very short time, usually in nanoseconds. Then,  the processor will return back to where it stopped and continue the previous operation.
     - Parameter mode : The interrupt mode to detect rising or falling edge.
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
     Trigger the interrupt after detecting the edge.
    
     */
    public func enableInterrupt() {
        interruptState = .enable
        swiftHal_gpioEnableCallback(&obj)
    }

    /**
     Disable the interrupt until the interrupt state is changed.
    
     */
    public func disableInterrupt() {
        interruptState = .disable
        swiftHal_gpioDisableCallback(&obj)
    }

    /**
     Check whether the interrupt is enabled.
     
     - Returns: The input mode: `.enable` or `.diable`.
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
    typealias Direction = DigitalOut.Direction

    /**
     The digital input modes can change the default state (high, low or floating) of a pin by using the pull resistors. 
     - Attention: The pins D26 to D37 are connected separately to an external 10kΩ resistor on the board. So even if they are changed to pullUp, the output voltage of these pins is still low.
     */
    public enum Mode: UInt8 {
        case pullDown = 1, pullUp, pullNone
    }

    /**
     The interrupt mode determines the edge to raise the interrupt: rising, falling or both edges. A rising edge is the transition of a digital input signal from high to low and a falling edge is from low to high.

     */
    public enum InterruptMode: UInt8 {
        case rising = 1, falling, bothEdge
    }

    /**
     The interrupt state determines whether the interrupt will be enabled and occur.

     */
    public enum InterruptState: UInt8 {
        case disable, enable
    }
}
