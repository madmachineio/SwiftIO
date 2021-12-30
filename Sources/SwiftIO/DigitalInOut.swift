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



/// The digital pin can be used to output voltages and read input levels.
/// If a pin is initialized as `DigitalInOut`, you can change its direction
/// to use it as an input or output pin.
public final class DigitalInOut {
    private let id: Int32


    private var direction: Direction

    private var outputMode: DigitalOut.Mode

    private var inputMode: DigitalIn.Mode

    public let alwaysSuccess: Result<(), Errno> = .success(())
    public var written: [Bool] = []

    public var expectRead: [Bool] = [] {
        willSet {
            readIndex = 0
        }
    }
    public var readIndex = 0

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
    }


    deinit {

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

        let result = alwaysSuccess

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            outputMode = oldOutputMode
        }
        
        if let value = value {
            written.append(value)
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

        let result = alwaysSuccess
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
            written.append(value)
        } else {
            setToOutput(value: value)
        }
	}

    /// Set the output value to true.
    @inline(__always)
    public func high() {
        write(true)
        written.append(true)
    }

    /// Set the output value to false.
    @inline(__always)
    public func low() {
        write(false)
        written.append(true)
    }

    /// Read the value from the pin.
    /// - Returns: `true` or `false` of the logic value.
    @inline(__always)
	public func read() -> Bool {
        if direction == .output {
            setToInput()
        }
        let value = expectRead[readIndex]
        readIndex += 1

		return value
	}
}


extension DigitalInOut {
    /// It decides the functionalities of the specified digital pin.
    /// It can serve as input or output.
    public enum Direction {
        case output, input
    }

}


