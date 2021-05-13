import CSwiftIO

/**
 The DigitalOut class is used to set a High or Low voltage output to a digital output pin. An initiation is required before using the member functions of this class.

 - Attention: The driving capability of the digital output pins is not very strong. It is meant to be a **SIGNAL** output and is not capable of driving a device requires large current.
 
 
 ### Example: Reverse the output value on a digital output pin

 ````
 import SwiftIO
 
 // Initiate a DigitalOut to Pin 0.
 let pin = DigitalOut(Id.D0)
 
 // Reverse the output value every 1 second.
 while true {
     pin.toggle()
     sleep(ms: 1000)
 }
 ````
 **or**
 ````
 import SwiftIO
 
 // Initiate a DigitalOut to the onboard green LED.
 let greenLED = DigitalOut(Id.GREEN)
 ​
 // Toggle the output of the pin every 1 second using another member function.
 while true {
     greenLED.write(true)
     sleep(ms: 1000)
     greenLED.write(false)
     sleep(ms: 1000)
 }
 ````
 */
public final class DigitalOut {
    private let id: Int32
    private let obj: UnsafeMutableRawPointer

    private let direction: swift_gpio_direction_t = SWIFT_GPIO_DIRECTION_OUT
    private var modeRawValue: swift_gpio_mode_t


    private var mode: Mode {
        willSet {
            switch newValue {
                case .pushPull:
                modeRawValue = SWIFT_GPIO_MODE_PULL_UP
                case .openDrain:
                modeRawValue = SWIFT_GPIO_MODE_OPEN_DRAIN
            }
        }
    }
    /**
     The current state of the output value.
     Write to this property would change the output value.
     
     */
    private var value: Bool {
        willSet {
			swifthal_gpio_set(obj, newValue ? 1 : 0)
		}
	}

    
    /**
     Initialize a DigitalOut to a specific output pin.
     
     - Parameter id: **REQUIRED** The name of output pin. Reference the Id enumerate.
     - Parameter mode: **OPTIONAL** The output mode of the pin. `.pushPull` by default.
     - Parameter value: **OPTIONAL** The output value after initiation. `false` by default.


     #### Usage Example
     ````
     // The most simple way of initiating a pin D0, with all other parameters set to default.
     let outputPin0 = DigitalOut(Id.D0)
     ​
     // Initialize the pin D1 with the output mode openDrain.
     let outputPin1 = DigitalOut(Id.D1, mode: .openDrain)
     ​
     // Initialize the pin D2 with a High voltage output.
     let outputPin2 = DigitalOut(Id.D2, value: true)
     
     // Initialize the pin D3 with the openDrain mode and a High voltage output.
     let outputPin3 = DigitalOut(Id.D3, mode: .openDrain, value: true)
     ````
     */
    public init(_ idName: IdName,
                mode: Mode = .pushPull,
                value: Bool = false) {
        self.id = idName.value
        self.value = value
        self.mode = mode
        switch mode {
            case .pushPull:
            modeRawValue = SWIFT_GPIO_MODE_PULL_UP
            case .openDrain:
            modeRawValue = SWIFT_GPIO_MODE_OPEN_DRAIN
        }
        if let ptr = swifthal_gpio_open(id, direction, modeRawValue) {
            obj = UnsafeMutableRawPointer(ptr)
            swifthal_gpio_set(obj, value ? 1 : 0)
        } else {
            fatalError("DigitalOut\(idName.value) initialization failed!")
        }
    }

    deinit {
        swifthal_gpio_close(obj)
    }

    /**
     Return the current output mode in a format of DigitalOut.Mode enumerate.

     - Returns: The current mode: `.pushPull` or `.openDrain`.
     
     #### Usage Example
     ````
     let pin = DigitalOut(Id.D0)
     if pin.getMode() == .pushPull {
        //do something
     }
     ````
     */
    public func getMode() -> Mode {
        return mode
    }

    /**
     Change the output mode.
     
     - Parameter mode : The output mode: `.pushPull` or `.openDrain`.
     */
    public func setMode(_ mode: Mode) {
        self.mode = mode

        if swifthal_gpio_config(obj, direction, modeRawValue) != 0 {
            print("DigitalOut\(id) setMode failed!")
        }
	}



    /**
     Set the output value of the specific pin: true for high voltage and false for low voltage.

     - Parameter value : The output value: `true`or `false`.
     */
    @inline(__always)
	public func write(_ value: Bool) {
        self.value = value
	}

    /**
     Set the output value to true.
     
     */
    @inline(__always)
    public func high() {
        value = true
    }

    /**
     Set the output value to false.
     
     */
    @inline(__always)
    public func low() {
        value = false
    }

    /**
     Reverse the current output value of the specific pin.
     
     */
    @inline(__always)
    public func toggle() {
        //value = value ? false : true
        value.toggle()
    }

    /**
     Get the current output value in Boolean format.
     
     - Returns: `true` or `false` of the logic value.
     - Attention:
        The return value of this function **has nothing to do with the actual output** of the pin.
        For example, a pin is set to `true` but it is short to ground. The actual pin voltage would be low. This function will still return `true` despite of the actual low output, since this pin is set to HIGH.
     */
    public func getValue() -> Bool {
        return value
    }
    
}


extension DigitalOut {
    /**
     The Mode enumerate includes the available output modes. The default output mode in most cases is pushPull. The pushPull mode enables the digital pin to output high and low voltage levels while the open-drain output cannot truly output a high level.
     
     */
    public enum Mode {
        case pushPull, openDrain
    }
}


