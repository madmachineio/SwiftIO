
public class Timer {
    var obj: TimerObject
    var callback: (()->Void)?


    public init() {
        obj = TimerObject()
        swiftHal_timerInit(&obj)
    }

    deinit {
        swiftHal_timerDeinit(&obj)
    }

    public func addCallback(_ callback: @escaping ()->Void) {
        self.callback = callback
        swiftHal_timerAddSwiftMember(&obj, getClassPtr(self)) {(ptr)->Void in
            let mySelf = Unmanaged<Timer>.fromOpaque(ptr!).takeUnretainedValue()
            mySelf.callback!()
        }
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


extension Timer {
    public enum TimerType: UInt8 {
        case oneShot, period
    }
}
