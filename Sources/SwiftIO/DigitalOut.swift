//=== DigitalOut.swift ----------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 05/09/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO

/**
 The DigitalOut class configures a specified pin as a digital output pin and
 set its state (high or low output).

At first, you need to initialize a pin as a DigitalOut pin. A pin on board may
 be multifunctional (digital input/output, analog...), plus many pins can be
 used as digital output pins. So you should specify a pin and its function.
 - `DigitalOut` tells the pin's usage.
 - `Id.D0` defines which pin is used. You may refer to the board's pinout
 which shows all pins and their corresponding functions in a diagram.

 ```swift
 let pin = DigitalOut(Id.D0)
 ```

 During initialization, you can also set the default output value for the pin.
 By default, it outputs a low voltage. If you would like a high output, the statement
 is:

 ```swift
 let pin = DigitalOut(Id.D0, value: true)
 ```

 > Important: The driving capability of the digital output pins is not very
 strong. It is a **SIGNAL** output and is not capable of driving a device that
 requires large current.

 
 ### Example: Reverse the output value on a digital output pin

 ```swift
 // Import the SwiftIO to use the related board functions.
 import SwiftIO
 // Import the MadBoard to decide which pin is used for the specific function.
 import MadBoard
 
 // Configure the pin 0 as a digital output pin. By default, the pin is set to low.
 let pin = DigitalOut(Id.D0)
 
 // Reverse the output value every 1 second.
 // It means the pin is high for 1s, low for 1s...
 while true {
     pin.toggle()
     sleep(ms: 1000)
 }
 ```
 **or**

 ```swift
 import SwiftIO
 import MadBoard
 
 // Set the onboard green LED as a digital output.
 // Then you can change the output to turn on or off it.
 // By default, it turns on due to a low output.
 let greenLED = DigitalOut(Id.GREEN)

 // Control the LED by switching between high and low output.
 while true {
    // Set a high voltage to turn off the onboard LED.
     greenLED.write(true)
     sleep(ms: 1000)
    // Set a low voltage to turn on the LED.
     greenLED.write(false)
     sleep(ms: 1000)
 }
 ```
 or

 ```swift
 import SwiftIO
 import MadBoard

 let greenLED = DigitalOut(Id.GREEN)

 // Control the LED by switching between high and low output.
 while true {
    // A more intuitive way to set the pin to high.
     greenLED.high()
     sleep(ms: 1000)

     greenLED.low()
     sleep(ms: 1000)
 }
 ```
 */
public final class DigitalOut {
    private let id: Int32
    private let obj: UnsafeMutableRawPointer

    private let direction: swift_gpio_direction_t = SWIFT_GPIO_DIRECTION_OUT

    private var modeRawValue: swift_gpio_mode_t
    public private(set) var mode: Mode {
        willSet {
            modeRawValue = DigitalOut.getModeRawValue(newValue)
        }
    }

    /**
     The current state of the output value.
     Write to this property would change the output value.
     
     */
    public var value: Bool {
        willSet {
			swifthal_gpio_set(obj, newValue ? 1 : 0)
		}
	}

    /// Initializes a DigitalOut to a specific pin.
    ///
    /// The id of the pin is required to initialize a digital out pin. It can be
    /// any pin with that function, D0, D1, D2... The prefix D means Digital.
    /// If you connect a device to the pin D10, you should initialize the pin
    /// using `Id.D10`.
    ///
    /// All ids for different boards are in the
    /// [MadBoards](https://github.com/madmachineio/MadBoards) library.
    /// Take pin 0 for example, the pin works as a DigitalOut pin after
    /// initialization:
    ///
    /// ```swift
    /// // The simplest way to initialize a pin, with other parameters set to default.
    /// let outputPin0 = DigitalOut(Id.D0)
    /// ```
    /// There are two more optional parameters to configure the pin.
    ///
    /// ```swift
    /// // Initialize the pin D1 with the output mode openDrain.
    /// let outputPin1 = DigitalOut(Id.D1, mode: .openDrain)
    ///
    /// // Initialize the pin D2 with a High voltage output.
    /// let outputPin2 = DigitalOut(Id.D2, value: true)
    ///
    /// // Initialize the pin D3 with the openDrain mode and a High voltage output.
    /// let outputPin3 = DigitalOut(Id.D3, mode: .openDrain, value: true)
    /// ```
    ///
    /// - Parameters:
    ///   - idName: **REQUIRED** The name of output pin. See Id for the board in
    ///   [MadBoards](https://github.com/madmachineio/MadBoards) library for reference.
    ///   - mode: **OPTIONAL** The output mode of the pin, `.pushPull` by default.
    ///   - value: **OPTIONAL** The output value after initialization, `false` by default.
    public init(_ idName: IdName,
                mode: Mode = .pushPull,
                value: Bool = false) {
        self.id = idName.value
        self.value = value
        self.mode = mode
        self.modeRawValue = DigitalOut.getModeRawValue(mode)

        guard let ptr = swifthal_gpio_open(id, direction, modeRawValue) else {
            fatalError("DigitalOut \(idName.value) init failed")
        }
            
        obj = ptr
        swifthal_gpio_set(obj, value ? 1 : 0)
    }

    deinit {
        swifthal_gpio_close(obj)
    }

    /// Returns the current output mode in a format of ``Mode`` enum.
    ///
    /// Here is an example:
    /// ```swift
    /// let pin = DigitalOut(Id.D0)
    /// if pin.getMode() == .pushPull {
    ///    //do something
    /// }
    /// ```
    /// - Returns: The output mode: `.pushPull` or `.openDrain`.
    public func getMode() -> Mode {
        return mode
    }

    /// Sets the output mode.
    /// - Parameter mode: The output mode: `.pushPull` or `.openDrain`.
    /// - Returns: Whether the configuration succeeds. If it fails, it returns
    /// the specific error.
    @discardableResult
    public func setMode(_ mode: Mode) -> Result<(), Errno> {
        let oldMode = self.mode
        self.mode = mode
        let result = nothingOrErrno(
		    swifthal_gpio_config(obj, direction, modeRawValue)
        )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            self.mode = oldMode
        }

        return result
	}


    /**
     Sets the output value of the specific pin: true for high voltage and false
     for low voltage.

     - Parameter value : The output value: `true` or `false`.
     */
    @inlinable
	public func write(_ value: Bool) {
        self.value = value
	}

    /**
     Sets the output value to true.

     `high()` and `write(true)` work the same way, and this is more straightforward.
     
     */
    @inlinable
    public func high() {
        value = true
    }

    /**
     Sets the output value to false.

     `low()` and `write(false)` work the same way, and this is more straightforward.
     */
    @inlinable
    public func low() {
        value = false
    }

    /**
     Reverses the current output value of the specific pin.

     It is really convenient if you don't care about the current output state.
     The output switches between high and low automatically.

     */
    @inlinable
    public func toggle() {
        value.toggle()
    }

    /**
     Gets the current output value in Boolean format.
     
     - Returns: `true` or `false` of the logic value.

     - Attention: The return value **has nothing to do with the actual electrical
     state** of the pin. For example, a pin is set to `true` but it is short to ground.
     The actual pin voltage would be low. However, this method will still return `true`
     despite of the actual low output, since this pin is set to HIGH.
     */
    @inlinable
    public func getValue() -> Bool {
        return value
    }
    
}


extension DigitalOut {
    /**
     The Mode enum includes the available output modes.

     The output mode in most cases is pushPull. This mode enables the
     digital pin to output high and low voltage levels, while the open-drain
     output cannot truly output a high level.
     
     */
    
    public enum Mode {
        case pushPull, openDrain
    }

    internal static func getModeRawValue(_ mode: Mode) -> swift_gpio_mode_t {
        switch mode {
            case .pushPull:
            return SWIFT_GPIO_MODE_PULL_UP
            case .openDrain:
            return SWIFT_GPIO_MODE_OPEN_DRAIN
        }
    }
}


