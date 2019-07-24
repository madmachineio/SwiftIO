public class PWM {
    var obj: PWMObject

    public init(_ id: PWMId, period: UInt, pulse: UInt) {
        obj = PWMObject()
        obj.id = id.rawValue
        obj.period = UInt32(period)
        obj.pulse = UInt32(pulse)

        swiftHal_PWMInit(&obj)
    }

    public func set(period: UInt, pulse: UInt) {
        obj.period = UInt32(period)
        obj.pulse = UInt32(pulse)
        swiftHal_PWMConfig(&obj)
    }

    public func updatePulse(_ pulse: UInt) {
        obj.pulse = UInt32(pulse)
        swiftHal_PWMUpdate(&obj)
    }
}