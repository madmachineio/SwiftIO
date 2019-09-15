public class PWMOut {
    var obj: PWMOutObject

    public convenience init(_ id: PWMOutId) {
        self.init(id, period: 1000, pulse: 0)
    }

    public init(_ id: PWMOutId, period: UInt, pulse: UInt) {
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
