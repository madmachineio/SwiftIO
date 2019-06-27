public class DigitalInOut {

	public enum Direction {
		case output, input
	}
		
	let instanceNumber: Int32
	var outputMode: OutputMode = .pushPull
	var inputMode: InputMode = .pullDown
	var direction: Direction

	public var outputValue: Int {
		willSet {
			if direction == .output {
				swiftHal_pinWrite(instanceNumber, Int32(newValue))
			}
		}
	}

	public var inputValue: Int {
		get {
			if direction == .input {
				return Int(swiftHal_pinRead(instanceNumber))
			} else {
				return -1
			}
		}
	}

	public var directionStatus: Direction {
		return direction
	}

	public init(_ name: DigitalName, mode: OutputMode) {
		instanceNumber = name.rawValue
		direction = .output
		inputMode = .pullDown
		outputMode = mode
		swiftHal_pinConfig(instanceNumber, outputMode.rawValue)
		outputValue = 0
	}

	public init(_ name: DigitalName, mode: InputMode) {
		instanceNumber = name.rawValue
		direction = .input
		outputMode = .pushPull
		inputMode = mode
		swiftHal_pinConfig(instanceNumber, inputMode.rawValue)
		outputValue = 0
	}

	public func setToOutput(_ mode: OutputMode) {
		outputMode = mode
		direction = .output
		swiftHal_pinConfig(instanceNumber, outputMode.rawValue)
	}

	public func setToInput(_ mode: InputMode) {
		inputMode = mode
		direction = .input
		swiftHal_pinConfig(instanceNumber, inputMode.rawValue)
	}

	public func write(_ value: Int) {
		outputValue = value
	}

	public func read() -> Int {
		return inputValue
	}

    /**
     Reverse the current output value of a pin.
     */
    public func reverse() {
        outputValue = outputValue == 1 ? 0 : 1
    }
}




