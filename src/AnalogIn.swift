/**
 Use AnalogIn class to read the external voltage applied to an analog input pin.
 
 ### Example: Read and print the analog input value on a specified pin
 
 ````
 import SwiftIO
 
 func main() {
     //Initialize an AnalogIn to Id.A0
     let pin = AnalogIn(.A0)
 
     //Read and print the analog input value on .A0 every 1 second
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

    /**
     Initialize an AnalogIn to a specified pin.
     
     - Parameter id: The AnalogIn Id on the board.
     
     ### Usage Example: ###
     ````
     let pin = AnalogIn(.A0)
     ````
     */
    public init(_ id: Id) {
        obj = AnalogInObject()
        obj.id = id.rawValue
        obj.resolution = 4095
        obj.refVoltage = 3.3
        swiftHal_AnalogInInit(&obj)
    }

    deinit {
        swiftHal_AnalogInDeinit(&obj)
    }

    /**
     Get the current resolution.
     
     - Returns: The current resolution.
     */
    public func getResolution() -> UInt {
        return UInt(obj.resolution)
    }

    /**
     Get the current reference voltage.
     
     - Returns: The current reference voltage.
     */
    public func getReference() -> Float {
        return obj.refVoltage
    }

    /**
     Read the input voltage.
     
     - Returns: An UInt in the range of 0 to max resolution.
     */
    public func read() -> UInt {
        return UInt(swiftHal_AnalogInRead(&obj))
    }

    /**
     Read the input voltage.
     
     - Returns: The percentage of the referenced voltage in the range of 0.0 to 1.0.
     */
    public func readPercent() -> Float {
        let val: Float = Float(swiftHal_AnalogInRead(&obj))
        return val / Float(obj.resolution)
    }

    /**
     Read the input voltage.
     
     - Returns: A float value in the range of 0.0 to the reference voltage.
     */
    public func readVoltage() -> Float {
        let val: Float = Float(swiftHal_AnalogInRead(&obj))
        return obj.refVoltage * val / Float(obj.resolution)
    }
}


extension AnalogIn {

    public enum Id: UInt8 {
        case A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11
    }
}