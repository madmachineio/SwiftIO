/**
 Use the RGBLED class to control the state of the on board RGB LED.
 
 ### Example: Blink the blue LED every 1 second.
 
 ````
 import SwiftIO
 
 func main() {
    //Create rgb to the specific device
    let rgb = RGBLED()
 
    //This loop runs for ever
    while true {
        rgb.turnOn(.blue)
        sleep(1000)
        rgb.turnOff(.blue)
        sleep(1000)
    }
 }
 ````
 
 */
public class RGBLED {
	var obj: RGBLEDObject

    /**
     Create a RGBLED, since there is only 1 RGB LED on board, we don't need to specify the id
     
     ### Usage Example: ###
     ````
     let rgb = RGBLED()
     ````
     */
    public init() {
		obj = RGBLEDObject()
		swiftHal_rgbInit(&obj)
	}

	deinit {
		swiftHal_rgbDeinit(&obj)
	}

    /**
     Turn on the specified color of the RGB LED
     
     - Parameter color : The color need to be turned on.
     */
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

    /**
     Turn off the specified color of the RGB LED
     
     - Parameter color : The color need to be turned off.
     */
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

    /**
     Set the new state of three colors at the same time
     
     - Parameter red : The new state of the red color
     - Parameter green : The new state of the green color
     - Parameter blue : The new state of the blue color
     ### Usage Example: ###
     ````
     let rgb = RGBLED()
     rgb.set(red: false, green: false, blue: true)
     ````
     */
    public func set(red: Bool, green: Bool, blue: Bool) {
		obj.redState = red ? 1 : 0
		obj.greenState = green ? 1 : 0
		obj.blueState = blue ? 1 : 0
		swiftHal_rgbConfig(&obj)
	}

    /**
     Reverse the state of the specified color of the RGB LED
     
     - Parameter color : The color need to be reversed
     */
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




