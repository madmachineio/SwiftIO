public class AnalogIn {
    var obj: AnalogInObject

    public init(_ id: AnalogInId) {
        obj = AnalogInObject()
        obj.id = id.rawValue

        swiftHal_ADCInit(&obj)
    }


    public func read() -> Int {
        return Int(swiftHal_ADCRead(&obj))
    }
}