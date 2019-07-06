public class DigitalInOut {
		
	let instanceNumber: Int32
	var outputMode: DigitalOutMode = .pushPull
	var inputMode: DigitalInMode = .pullDown
    var direction: DigitalDirection

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
    
	public var currentDirection: DigitalDirection {
		return direction
	}

	public init(_ name: DigitalName, mode: DigitalOutMode) {
		instanceNumber = name.rawValue
		direction = .output
		inputMode = .pullDown
		outputMode = mode
		swiftHal_pinConfig(instanceNumber, outputMode.rawValue)
		outputValue = 0
	}

	public init(_ name: DigitalName, mode: DigitalInMode) {
		instanceNumber = name.rawValue
		direction = .input
		outputMode = .pushPull
		inputMode = mode
		swiftHal_pinConfig(instanceNumber, inputMode.rawValue)
		outputValue = 0
	}

	public func setToOutput(_ mode: DigitalOutMode) {
		outputMode = mode
		direction = .output
		swiftHal_pinConfig(instanceNumber, outputMode.rawValue)
	}

	public func setToInput(_ mode: DigitalInMode) {
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



