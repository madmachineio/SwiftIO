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
 The DigitalInOut class allows you to set both input and output for a digital pin.

 The digital pins on your board can be used to output signals or read input levels.
 The class ``DigitalOut`` and ``DigitalIn`` give you access to one of the usages
 separately. If a pin is initialized as `DigitalInOut`, you can change its direction
 to use it as an input or output pin.

 ```swift
 // Initialize a DigitalInOut pin. At first, it works as an input pin.
 let pin = DigitalInOut(Id.D0, direction: .input)
 ```

 As for the specific usage like reading values or setting output, it is the same
 as those of `DigitalOut` and `DigitalIn`.

 ```swift
 // Read input value.
 let value = pin.read()
 print(value)

 // Change the pin to output pin and set output to high.
 pin.setToOutput()
 pin.high()
 ```

 For example, for the sensor DHT22, the pin sends out a signal to the sensor,
 then wait for the signal from the sensor. In this case, you can set the pin as
 DigitalInOut and switch the pin between output and input for measurement.

 ### Example: Set input and output on a digital pin.

 ```swift
 // Import the SwiftIO to use the related board functions.
 import SwiftIO
 // Import the MadBoard to decide which pin is used for the specific function.
 import MadBoard

 // Initialize a DigitalInOut to the digital pin D0.
 let pin = DigitalInOut(Id.D0)

 while true {
    // Set the pin to output. The output value is false.
     pin.setToOutput(value: false)
     sleep(ms: 18)

    // Set the pin to input to read incoming signals.
     pin.setToInput()
     while pin.read() != false {
        ...
     }
 }
 ```
 */
public final class DigitalInOut {
    private let id: Int32
    public let obj: UnsafeRawPointer

    private var directionRawValue: swift_gpio_direction_t
    private var outputModeRawValue: swift_gpio_mode_t
    private var inputModeRawValue: swift_gpio_mode_t

    public private(set) var direction: Direction {
        willSet {
            directionRawValue = DigitalInOut.getDirectionRawValue(newValue)
        } 
    }

    public private(set) var outputMode: DigitalOut.Mode {
        willSet {
            outputModeRawValue = DigitalOut.getModeRawValue(newValue)
        }
    }

    public private(set) var inputMode: DigitalIn.Mode {
        willSet {
            inputModeRawValue = DigitalIn.getModeRawValue(newValue)
        }
    }

    /// Initializes a digital pin as input or output pin.
    ///
    /// The statement below shows how to initialize a pin as digital output at
    /// first, as the default setting for a pin is output.
    ///
    /// ```swift
    ///  let pin = DigitalInOut(Id.D0)
    /// ```
    ///
    /// If you want an input instead, you can define the direction:
    /// ```swift
    ///  let pin = DigitalInOut(Id.D0, direction: input)
    /// ```
    /// - Parameters:
    ///   - idName: **REQUIRED** The name of digital pin. See Id for the board in
    ///   [MadBoards](https://github.com/madmachineio/MadBoards) library for reference.
    ///   - direction: **OPTIONAL** Whether the pin serves as input or output.
    ///   - outputMode: **OPTIONAL** The output mode of the pin.
    ///     `.pushPull` by default.
    ///   - inputMode: **OPTIONAL** The input mode. `.pullUp` by default.
    ///   - outputValue: **OPTIONAL** The output value after initialization.
    ///     `false` by default.
    public init(
        _ idName: IdName,
        direction: Direction = .output,
        outputMode: DigitalOut.Mode = .pushPull,
        inputMode: DigitalIn.Mode = .pullUp,
        outputValue: Bool = false
    ) {
        
        self.id = idName.value
        self.direction = direction
        self.outputMode = outputMode
        self.inputMode = inputMode

        outputModeRawValue = DigitalOut.getModeRawValue(outputMode)
        inputModeRawValue = DigitalIn.getModeRawValue(inputMode)
        directionRawValue = DigitalInOut.getDirectionRawValue(direction)

        let modeRawValue: swift_gpio_mode_t
        switch direction {
            case .output:
            modeRawValue = outputModeRawValue
            case .input:
            modeRawValue = inputModeRawValue
        }
    
        if let ptr = swifthal_gpio_open(id, directionRawValue, modeRawValue) {
            obj = UnsafeRawPointer(ptr)
            if direction == .output {
                swifthal_gpio_set(obj, outputValue ? 1 : 0)
            }
        } else {
            fatalError("DigitalInOut \(idName.value) init failed")
        }
    }


    deinit {
        swifthal_gpio_close(obj)
    }

    /// Knows if the pin is used for input or output.
    /// - Returns: The pin's function: `input` or `output`.
    public func getDirection() -> Direction {
        return direction
    }

    /// Gets the current output mode on a specified pin.
    /// - Returns: The current mode: `.pushPull` or `.openDrain`.
    public func getOutputMode() -> DigitalOut.Mode {
        return outputMode
    }

    /// Gets the current input mode on a specified pin.
    /// - Returns: The current input mode: `.pullUp`, `.pullDown` or `.pullNone`.
    public func getInputMode() -> DigitalIn.Mode {
        return inputMode
    }

    /// Sets the pin to output digital signal.
    /// - Parameters:
    ///   - mode: The output mode: `.pushPull` or `.openDrain`. If you don't
    ///     set it, it remains the same as the mode after initialization.
    ///   - value: The output value: true or false. If you don't set it,
    ///     it remains the same as the value after initialization.
    /// - Returns: Whether the configuration succeeds. If it fails, it returns
    /// the specific error.
    @discardableResult
    public func setToOutput(_ mode: DigitalOut.Mode? = nil, value: Bool? = nil) -> Result<(), Errno> {
        direction = .output
        let oldOutputMode = outputMode

        if let mode = mode {
            outputMode = mode
        }

        let result = nothingOrErrno(
            swifthal_gpio_config(obj, directionRawValue, outputModeRawValue)
        )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            outputMode = oldOutputMode
        }
        
        if let value = value {
            swifthal_gpio_set(obj, value ? 1 : 0)
        }

        return result
	}

    /// Sets the pin to read digital input.
    /// - Parameter mode: The input mode: `.pullUp`, `.pullDown` or `.pullNone`.
    ///  If you don't set it, it remains the same as the mode after
    ///  initialization.
    /// - Returns: Whether the configuration succeeds. If it fails, it returns
    /// the specific error.
    @discardableResult
    public func setToInput(_ mode: DigitalIn.Mode? = nil) -> Result<(), Errno> {
        direction = .input
        let oldInputMode = inputMode

        if let mode = mode {
            inputMode = mode
        }

        let result = nothingOrErrno(
            swifthal_gpio_config(obj, directionRawValue, inputModeRawValue)
        )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            inputMode = oldInputMode
        }

        return result
	}

    /// Sets the output value of the specific pin: true for high voltage and
    /// false for low voltage.
    ///
    /// > Note: If the pin is used as input before, it will be automatically set
    /// to output.
    /// - Parameter value: The output value: `true` or `false`.
    @inlinable
	public func write(_ value: Bool) {
        if direction == .output {
            swifthal_gpio_set(obj, value ? 1 : 0)
        } else {
            setToOutput(value: value)
        }
	}

    /// Sets the output value to true.
    /// > Note: If the pin is used as input before, it will be automatically set
    /// to output.
    @inlinable
    public func high() {
        write(true)
    }

    /// Sets the output value to false.
    /// > Note: If the pin is used as input before, it will be automatically set
    /// to output.
    @inlinable
    public func low() {
        write(false)
    }

    /// Reads the value from the pin.
    /// - Returns: `true` or `false` of the logic value.
    @inlinable
	public func read() -> Bool {
        if direction == .output {
            setToInput()
        }
		return swifthal_gpio_get(obj) == 1 ? true : false
	}
}


extension DigitalInOut {
    /// The functions of the specified digital pin: input or output.
    public enum Direction {
        case output, input
    }

    private static func getDirectionRawValue(_ dir: Direction) -> swift_gpio_direction_t {
        switch dir {
        case .output:
            return SWIFT_GPIO_DIRECTION_OUT
        case .input:
            return SWIFT_GPIO_DIRECTION_IN
        }
    }
}


