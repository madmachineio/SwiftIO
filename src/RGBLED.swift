public class RGBLED {	
	var obj: RGBLEDObject

	public init() {
		obj = RGBLEDObject()
		swiftHal_rgbInit(&obj)
	}

	deinit {
		swiftHal_rgbDeinit(&obj)
	}

	public func turnOn(_ color: RGBLEDColor) {
		switch(color) {
			case .red:
				obj.redState = 1
			case .green:
				obj.greenState = 1
			case .blue:
				obj.blueState = 1
		}
		swiftHal_rgbConfig(&obj)
	}

	public func turnOff(_ color: RGBLEDColor) {
		switch(color) {
			case .red:
				obj.redState = 0
			case .green:
				obj.greenState = 0
			case .blue:
				obj.blueState = 0
		}
		swiftHal_rgbConfig(&obj)
	}

	public func set(red: Bool, green: Bool, blue: Bool) {
		obj.redState = red ? 1 : 0
		obj.greenState = green ? 1 : 0
		obj.blueState = blue ? 1 : 0
		swiftHal_rgbConfig(&obj)
	}

	public func reverse(_ color: RGBLEDColor) {
		switch(color) {
			case .red:
				obj.redState = obj.redState == 1 ? 0 : 1
			case .green:
				obj.greenState = obj.greenState == 1 ? 0 : 1
			case .blue:
				obj.blueState = obj.blueState == 1 ? 0 : 1
		}
		swiftHal_rgbConfig(&obj)
	}
}




