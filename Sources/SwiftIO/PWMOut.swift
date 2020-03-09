public class PWMOut {
    var obj: PWMOutObject


    public init(_ id: Id,
                period: Int = 1000,
                pulse: Int = 0) {
        obj = PWMOutObject()
        obj.id = id.rawValue
        obj.period = UInt32(period)
        obj.pulse = UInt32(pulse)
        obj.countPerSecond = 1000000

        swiftHal_PWMOutInit(&obj)
    }

    deinit {
        swiftHal_PWMOutDeinit(&obj)
    }

    public func set(period: Int, pulse: Int) {
        obj.period = UInt32(period)
        obj.pulse = UInt32(pulse)
        swiftHal_PWMOutConfig(&obj)
    }

    public func set(frequency hz: Int, dutycycle: Float) {
        obj.period = UInt32(1000000 / hz)
        obj.pulse = UInt32(1000000.0 / (Float(hz) * dutycycle))
        swiftHal_PWMOutConfig(&obj)
    }

    public func setDutycycle(_ dutycycle: Float) {
        obj.pulse = UInt32(Float(obj.period) * dutycycle)
        swiftHal_PWMOutConfig(&obj)
    }

}


extension PWMOut {
    public enum Id: UInt8 {
        case PWM0, PWM1, PWM2, PWM3, PWM4, PWM5, PWM6, PWM7, PWM8, PWM9, PWM10, PWM11, PWM12, PWM13
    }
}