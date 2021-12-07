//=== DigitalOut.swift ----------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 05/09/2021
// Updated: 11/05/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO


/// The digital pin can be used to output voltages and read input levels.
/// If a pin is initialized as `DigitalInOut`, you can change its direction
/// to use it as an input or output pin.
public final class DigitalInOut {
    private let id: Int32
    private let obj: UnsafeMutableRawPointer

    private var directionRawValue: swift_gpio_direction_t
    private var outputModeRawValue: swift_gpio_mode_t
    private var inputModeRawValue: swift_gpio_mode_t

    private var direction: Direction {
        willSet {
            switch newValue {
                case .output:
                directionRawValue = SWIFT_GPIO_DIRECTION_OUT
                case .input:
                directionRawValue = SWIFT_GPIO_DIRECTION_IN
            }
        } 
    }

    private var outputMode: DigitalOut.Mode {
        willSet {
            switch newValue {
                case .pushPull:
                outputModeRawValue = SWIFT_GPIO_MODE_PULL_UP
                case .openDrain:
                outputModeRawValue = SWIFT_GPIO_MODE_OPEN_DRAIN
            }
        }
    }

    private var inputMode: DigitalIn.Mode {
        willSet {
            switch newValue {
                case .pullDown:
                inputModeRawValue = SWIFT_GPIO_MODE_PULL_DOWN
                case .pullUp:
                inputModeRawValue = SWIFT_GPIO_MODE_PULL_UP
                case .pullNone:
                inputModeRawValue = SWIFT_GPIO_MODE_PULL_NONE
            }
        }
    }

    /// Initialize a digital pin as input or output pin.
    /// - Parameters:
    ///   - idName: **REQUIRED** The Digital id on the board.
    ///     See Id for the specific board in MadBoards library for reference.
    ///   - direction: **OPTIONAL** Whether the pin serves as input or output.
    ///   - outputMode: **OPTIONAL** The output mode of the pin.
    ///     `.pushPull` by default.
    ///   - inputMode: **OPTIONAL** The input mode. `.pullUp` by default.
    ///   - outputValue: **OPTIONAL** The output value after initiation.
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

        switch outputMode {
            case .pushPull:
            outputModeRawValue = SWIFT_GPIO_MODE_PULL_UP
            case .openDrain:
            outputModeRawValue = SWIFT_GPIO_MODE_OPEN_DRAIN
        }
        switch inputMode {
            case .pullDown:
            inputModeRawValue = SWIFT_GPIO_MODE_PULL_DOWN
            case .pullUp:
            inputModeRawValue = SWIFT_GPIO_MODE_PULL_UP
            case .pullNone:
            inputModeRawValue = SWIFT_GPIO_MODE_PULL_NONE
        }

        let modeRawValue: swift_gpio_mode_t
        switch direction {
            case .output:
            directionRawValue = SWIFT_GPIO_DIRECTION_OUT
            modeRawValue = outputModeRawValue
            case .input:
            directionRawValue = SWIFT_GPIO_DIRECTION_IN
            modeRawValue = inputModeRawValue
        }
    
        if let ptr = swifthal_gpio_open(id, directionRawValue, modeRawValue) {
            obj = UnsafeMutableRawPointer(ptr)
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

    /// Know if the pin is used for input or output.
    /// - Returns: Input or output.
    public func getDirection() -> Direction {
        return direction
    }

    /// Get the current output mode on a specified pin.
    /// - Returns: The current mode: `.pushPull` or `.openDrain`.
    public func getOutputMode() -> DigitalOut.Mode {
        return outputMode
    }

    /// Get the current input mode on a specified pin.
    /// - Returns: The current input mode: `.pullUp`, `.pullDown` or `.pullNone`.
    public func getInputMode() -> DigitalIn.Mode {
        return inputMode
    }

    /// Set the pin to output digital signal.
    /// - Parameters:
    ///   - mode: The output mode: `.pushPull` or `.openDrain`. If you don't
    ///     set it, it remains the same as the mode after initialization.
    ///   - value: The output value: true or false. If you don't set it,
    ///     it remains the same as the value after initialization.
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

    /// Set the pin to read digital input.
    /// - Parameter mode: The input mode: `.pullUp`, `.pullDown` or `.pullNone`.
    ///  If you don't set it, it remains the same as the mode after
    ///  initialization.
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

    /// Set the output value of the specific pin: true for high voltage and
    /// false for low voltage.
    /// - Parameter value: The output value: `true` or `false`.
    @inline(__always)
	public func write(_ value: Bool) {
        if direction == .output {
            swifthal_gpio_set(obj, value ? 1 : 0)
        } else {
            setToOutput(value: value)
        }
	}

    /// Set the output value to true.
    @inline(__always)
    public func high() {
        write(true)
    }

    /// Set the output value to false.
    @inline(__always)
    public func low() {
        write(false)
    }

    /// Read the value from the pin.
    /// - Returns: `true` or `false` of the logic value.
    @inline(__always)
	public func read() -> Bool {
        if direction == .output {
            setToInput()
        }
		return swifthal_gpio_get(obj) == 1 ? true : false
	}
}


extension DigitalInOut {
    /// It decides the functionalities of the specified digital pin.
    /// It can serve as input or output.
    public enum Direction {
        case output, input
    }
}


