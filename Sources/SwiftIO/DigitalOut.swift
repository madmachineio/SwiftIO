import CHal

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

    private var obj: DigitalIOObject

    private let id: IdName
    private var mode: Mode {
        willSet {
            obj.outputMode = newValue.rawValue
        }
    }

    /**
     The current state of the output value.
     Write to this property would change the output value.
     
     */
    private var value: Bool {
        willSet {
			swiftHal_gpioWrite(&obj, newValue ? 1 : 0)
		}
	}

    private func objectInit() {
        obj.idNumber = id.number
        obj.direction = Direction.output.rawValue
        obj.outputMode = mode.rawValue

        swiftHal_gpioInit(&obj)
		swiftHal_gpioWrite(&obj, value ? 1 : 0)
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
    public init(_ id: IdName,
                mode: Mode = .pushPull,
                value: Bool = false) {
        self.id = id
        self.mode = mode
        self.value = value
        obj = DigitalIOObject()
        objectInit()
    }

    deinit {
        swiftHal_gpioDeinit(&obj)
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
        swiftHal_gpioConfig(&obj)
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
     Reverse the current output value of the specific pin.
     
     */
    @inline(__always)
    public func toggle() {
        value = value ? false : true
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
        **DO NOT USE**
     */
    enum Direction: UInt8 {
        case output = 1, input
    }

    /**
     The Mode enumerate includes the available output modes. The default output mode in most cases is pushPull. The pushPull mode enables the digital pin to output high and low voltage levels while the open-drain output cannot truly output a high level.
     
     */
    public enum Mode: UInt8 {
        case pushPull = 1, openDrain
    }
}


