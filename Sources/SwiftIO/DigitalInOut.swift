import CSwiftIO

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

    private var outputMode: OutputMode {
        willSet {
            switch newValue {
                case .pushPull:
                outputModeRawValue = SWIFT_GPIO_MODE_PULL_UP
                case .openDrain:
                outputModeRawValue = SWIFT_GPIO_MODE_OPEN_DRAIN
            }
        }
    }

    private var inputMode: InputMode {
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

    public init(_ idName: IdName,
                direction: Direction = .output,
                outputMode: OutputMode = .pushPull,
                inputMode: InputMode = .pullUp,
                outputValue: Bool = false) {
        
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
            fatalError("DigitalInOut\(idName.value) initialization failed!")
        }
    }


    deinit {
        swifthal_gpio_close(obj)
    }

    public func getDirection() -> Direction {
        return direction
    }

    public func getOutputMode() -> OutputMode {
        return outputMode
    }

    public func getInputMode() -> InputMode {
        return inputMode
    }

    public func setToOutput(_ mode: OutputMode) {
        direction = .output
        outputMode = mode

        if swifthal_gpio_config(obj, directionRawValue, outputModeRawValue) != 0 {
            print("DigitalInOut\(id) setOutputMode failed!")
        }
	}

    public func setToInput(_ mode: InputMode) {
        direction = .input
        inputMode = mode

        if swifthal_gpio_config(obj, directionRawValue, inputModeRawValue) != 0 {
            print("DigitalInOut\(id) setInputMode failed!")
        }
	}

    @inline(__always)
	public func write(_ value: Bool) {
        if direction == .input {
            direction = .output
            swifthal_gpio_config(obj, directionRawValue, outputModeRawValue)
        }
        swifthal_gpio_set(obj, value ? 1 : 0)
	}


    @inline(__always)
    public func high() {
        write(true)
    }


    @inline(__always)
    public func low() {
        write(false)
    }

    @inline(__always)
	public func read() -> Bool {
        if direction == .output {
            direction = .input
            swifthal_gpio_config(obj, directionRawValue, inputModeRawValue)
        }
		return swifthal_gpio_get(obj) == 1 ? true : false
	}
}


extension DigitalInOut {
    public enum Direction {
        case output, input
    }

    public enum OutputMode {
        case pushPull, openDrain
    }

    public enum InputMode {
        case pullDown, pullUp, pullNone
    }
}


