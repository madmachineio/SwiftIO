/**
 Use the AnalogIn class to read the external voltage applied to an analog input pin.
 
 ### Example: Read an analog input on AnalogInId.A0
 
 ````
 import SwiftIO
 
 func main() {
     //Create an AnalogIn to AnalogInId.A0
     let pin = AnalogIn(.A0)
 
     //Read and print the analog voltage value on .A0 every 1 second
     while true {
        var value = pin.read()
        print("The analog value is \(value)")
        sleep(1000)
     }
 }
 ````
 
 */
public class AnalogIn {
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
