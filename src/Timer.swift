public class Timer {
    var obj: TimerObject

    public init(_ callback: @escaping @convention(c) ()->Void) {
        obj = TimerObject()
        obj.expiryCallback = callback
        swiftHal_timerInit(&obj)
    }

    deinit {
        swiftHal_timerDeinit(&obj)
    }

    public func start(_ period: Int, mode: TimerType) {
        obj.period = Int32(period)
        obj.timerType = mode.rawValue
        swiftHal_timerStart(&obj)
    }

    public func stop() {
        swiftHal_timerStop(&obj)
    }

    public func clear() {
        swiftHal_timerCount(&obj)
    }
}