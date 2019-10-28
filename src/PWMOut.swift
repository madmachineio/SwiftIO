public class PWMOut {
    var obj: PWMOutObject


    public init(_ id: Id,
                period: UInt = 1000,
                pulse: UInt = 0) {
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

    public func set(period: UInt, pulse: UInt) {
        obj.period = UInt32(period)
        obj.pulse = UInt32(pulse)
        swiftHal_PWMOutConfig(&obj)
    }

    public func setPeriod(_ us: UInt) {
        obj.period = UInt32(us)
        swiftHal_PWMOutConfig(&obj)
    }


    public func setFrequency(_ hz: UInt) {
        obj.period = obj.countPerSecond / UInt32(hz)
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