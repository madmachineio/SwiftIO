/**
 The AnalogIn class is used to read the external voltage applied to an analog input pin.
 
 ### Example: Read and print the analog input value on a analog pin
 
 ````
 import SwiftIO
 
 //Initialize an AnalogIn to analog pin A0.
 let pin = AnalogIn(.A0)
 
 //Read and print the analog input value every 1 second.
 while true {
     var value = pin.readVoltage()
     print("The analog input volatge is \(value)")
     sleep(ms: 1000)
 }
 ````
 
 */
public class AnalogIn {
    var obj: AnalogInObject

    /**
     Initialize an AnalogIn to a specified pin.
     
     - Parameter id: **REQUIRED** The AnalogIn Id on the board. See Id for reference.
     
     ### Usage Example ###
     ````
     // Initialize an analog pin A0.
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
     Get the maximum raw value of the board. Each ADC has different resolution. The maximum raw value of an 8-bit ADC is 255 and that one of a 10-bit ADC is 4095.
     
     - Returns: The maximum raw value.
     */
    public func getMaxRawValue() -> Int {
        return Int(obj.resolution)
    }

    /**
     Get the reference voltage of the board.
     
     - Returns: The reference voltage.
     */
    public func getReference() -> Float {
        return obj.refVoltage
    }

    /**
     Read the current raw value from the specified analog pin.
     
     - Returns: An integer in the range of 0 to max resolution.
     */
    public func readRawValue() -> Int {
        return Int(swiftHal_AnalogInRead(&obj))
    }

    /**
     Read the input voltage in percentage from a specified analog pin.
     
     - Returns: A percentage of the reference voltage in the range of 0.0 to 1.0.
     */
    public func readPercent() -> Float {
        let val = Float(swiftHal_AnalogInRead(&obj))
        return val / Float(obj.resolution)
    }

    /**
     Read the input voltage from a specified analog pin.
     
     - Returns: A float value in the range of 0.0 to the reference voltage.
     */
    public func readVoltage() -> Float {
        let val = Float(swiftHal_AnalogInRead(&obj))
        return obj.refVoltage * val / Float(obj.resolution)
    }
}


extension AnalogIn {

    /**
     The analog input pins are A0 to A11, corresponding to P14 to P25 on the left side of your board.
     
     */
    public enum Id: UInt8 {
        case A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11
    }
}
