/**
 Use the AnalogIn class to read the value of a analog pin.
 
 ### Example: A simple hello world.
 
 ````
 import SwiftIO
 
 main() {
 //Create a AnalogIn to .A0
 let pin = AnalogIn(.A0)
 
 //Read the analog value of the pin every 1 second
 while true {
 var value = pin.read()
 print("The analog value is \(value)")
 sleep(1000)
 }
 }
 ````
 
 */public class AnalogIn {
    var obj: AnalogInObject

    public init(_ id: AnalogInId) {
        obj = AnalogInObject()
        obj.id = id.rawValue
        obj.resolution = 4095
        obj.refVoltage = 3.3
        swiftHal_AnalogInInit(&obj)
    }

    deinit {
        swiftHal_AnalogInDeinit(&obj)
    }

    public func getResolution() -> UInt {
        return UInt(obj.resolution)
    }

    public func getReference() -> Float {
        return obj.refVoltage
    }

    public func read() -> UInt {
        return UInt(swiftHal_AnalogInRead(&obj))
    }

    public func readPercent() -> Float {
        let val: Float = Float(swiftHal_AnalogInRead(&obj))
        return val / Float(obj.resolution)
    }

    public func readVoltage() -> Float {
        let val: Float = Float(swiftHal_AnalogInRead(&obj))
        return obj.refVoltage * val / Float(obj.resolution)
    }
}
