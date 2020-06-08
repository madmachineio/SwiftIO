import CHal

/**
 The AnalogIn class is used to read the external voltage applied to an analog input pin.
 
 ### Example: Read and print the analog input value on a analog pin
 
 ````
 import SwiftIO
 
 //Initialize an AnalogIn to analog pin A0.
 let pin = AnalogIn(Id.A0)
 
 //Read and print the analog input value every 1 second.
 while true {
     var value = pin.readVoltage()
     print("The analog input volatge is \(value)")
     sleep(ms: 1000)
 }
 ````
 
 */
public final class AnalogIn {
    private var obj: AnalogInObject

    private let id: IdName


    private func objectInit() {
        obj.idNumber = id.number
        swiftHal_AnalogInInit(&obj)
    }

    /**
     The max raw value of the ADC. Different ADC has different resolutions. The max raw value of an 8-bit ADC is 255 and that one of a 10-bit ADC is 4095.

     */
    public var maxRawValue: Int {
        Int(obj.info.maxRawValue)
    }

    /**
     The reference voltage of the board.

     */
    public var refVoltage: Float {
        obj.info.refVoltage
    }

    /**
     Initialize an AnalogIn to a specified pin.
     
     - Parameter id: **REQUIRED** The AnalogIn Id on the board. See Id for reference.
     
     ### Usage Example ###
     ````
     // Initialize an analog pin A0.
     let pin = AnalogIn(Id.A0)
     ````
     */
    public init(_ id: IdName) {
        self.id = id
        obj = AnalogInObject()
        objectInit()
    }

    deinit {
        swiftHal_AnalogInDeinit(&obj)
    }


    /**
     Read the current raw value from the specified analog pin.
     
     - Returns: An integer in the range of 0 to max resolution.
     */
    @inline(__always)
    public func readRawValue() -> Int {
        return Int(swiftHal_AnalogInRead(&obj))
    }

    /**
     Read the input voltage in percentage from a specified analog pin.
     
     - Returns: A percentage of the reference voltage in the range of 0.0 to 1.0.
     */
    @inline(__always)
    public func readPercent() -> Float {
        let rawValue = Float(swiftHal_AnalogInRead(&obj))
        return rawValue / Float(maxRawValue)
    }

    /**
     Read the input voltage from a specified analog pin.
     
     - Returns: A float value in the range of 0.0 to the reference voltage.
     */
    @inline(__always)
    public func readVoltage() -> Float {
        let rawValue = Float(swiftHal_AnalogInRead(&obj))
        return refVoltage * rawValue / Float(maxRawValue)
    }
}


