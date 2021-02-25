import CSwiftIO

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
    private let id: Int32 
    private var obj: UnsafeMutableRawPointer 

    private let direction: swift_gpio_direction_t = SWIFT_GPIO_DIRECTION_IN
    private var modeRawValue: swift_gpio_mode_t
    private var interruptModeRawValue: swift_gpio_int_mode_t

    private var mode: Mode {
        didSet {
            switch mode {
                case .pullDown:
                modeRawValue = SWIFT_GPIO_MODE_PULL_DOWN
                case .pullUp:
                modeRawValue = SWIFT_GPIO_MODE_PULL_UP
                case .pullNone:
                modeRawValue = SWIFT_GPIO_MODE_PULL_NONE
            }
        }
    }
    private var interruptMode: InterruptMode {
        didSet {
            switch interruptMode {
                case .rising:
                interruptModeRawValue = SWIFT_GPIO_INT_MODE_RISING_EDGE
                case .falling:
                interruptModeRawValue = SWIFT_GPIO_INT_MODE_FALLING_EDGE
                case .bothEdge:
                interruptModeRawValue = SWIFT_GPIO_INT_MODE_BOTH_EDGE
            }
        }
    }
    private var interruptState: InterruptState = .disable

    private var callback: (()->Void)?

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
	public init(_ idName: IdName,
                mode: Mode = .pullDown) {
        self.id = idName.value
        self.mode = mode
        switch mode {
            case .pullDown:
            modeRawValue = SWIFT_GPIO_MODE_PULL_DOWN
            case .pullUp:
            modeRawValue = SWIFT_GPIO_MODE_PULL_UP
            case .pullNone:
            modeRawValue = SWIFT_GPIO_MODE_PULL_NONE
        }
        self.interruptMode = .rising
        switch interruptMode {
            case .rising:
            interruptModeRawValue = SWIFT_GPIO_INT_MODE_RISING_EDGE
            case .falling:
            interruptModeRawValue = SWIFT_GPIO_INT_MODE_FALLING_EDGE
            case .bothEdge:
            interruptModeRawValue = SWIFT_GPIO_INT_MODE_BOTH_EDGE
        }

        if let ptr = swifthal_gpio_open(id, direction, modeRawValue) {
            obj = UnsafeMutableRawPointer(ptr)
        } else {
            fatalError("DigitalIn\(idName.value) initialization failed!")
        }
	}

    deinit {
        if callback != nil {
            removeInterrupt()
        }
        swifthal_gpio_close(obj)
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
		swifthal_gpio_config(obj, direction, modeRawValue)
	}


    /**
     Read the value from a digital input pin.
     
     - Attention: Dependind on the hardware, the internal pull resister may be very weak. **Don't** just rely on the pull resister for reading the value. **Especially** when you just changed the input mode, the internel pad need some time to charge or discharge through the pull resister!
     
     - Returns: `true` or `false` of the logic value.
     */
    @inline(__always)
	public func read() -> Bool {
		return swifthal_gpio_get(obj) == 1 ? true : false
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

        if self.callback != nil {
            removeInterrupt()
        }

        self.callback = callback
        swifthal_gpio_interrupt_config(obj, interruptModeRawValue)
        swifthal_gpio_interrupt_callback_install(obj, getClassPointer(self)) { (ptr)->Void in
            let mySelf = Unmanaged<DigitalIn>.fromOpaque(ptr!).takeUnretainedValue()
            mySelf.callback!()
        }

        if enable {
            enableInterrupt()
        } else {
            disableInterrupt()
        }
    }

    /**
     Trigger the interrupt after detecting the edge.
    
     */
    public func enableInterrupt() {
        if callback != nil {
            interruptState = .enable
            swifthal_gpio_interrupt_enable(obj)
        } else {
            print("DigitalIn \(id) han't set an interrupt!")
        }
    }

    /**
     Disable the interrupt until the interrupt state is changed.
    
     */
    public func disableInterrupt() {
        interruptState = .disable
        swifthal_gpio_interrupt_disable(obj)
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
        swifthal_gpio_interrupt_disable(obj)
        swifthal_gpio_interrupt_callback_uninstall(obj)
        callback = nil
    }

}




extension DigitalIn {
    /**
     The digital input modes can change the default state (high, low or floating) of a pin by using the pull resistors. 
     - Attention: The pins D26 to D37 are connected separately to an external 10kΩ resistor on the board. So even if they are changed to pullUp, the output voltage of these pins is still low.
     */
    public enum Mode {
        case pullDown, pullUp, pullNone
    }

    /**
     The interrupt mode determines the edge to raise the interrupt: rising, falling or both edges. A rising edge is the transition of a digital input signal from high to low and a falling edge is from low to high.

     */
    public enum InterruptMode {
        case rising, falling, bothEdge
    }

    /**
     The interrupt state determines whether the interrupt will be enabled and occur.

     */
    public enum InterruptState {
        case disable, enable
    }
}
