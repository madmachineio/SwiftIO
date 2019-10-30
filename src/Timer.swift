
public class Timer {
    private var obj: TimerObject
    private var callback: (()->Void)?

    private var mode: Mode {
        willSet {
            obj.timerType = newValue.rawValue
        }
    }

    private var period: Int {
        willSet {
            obj.period = Int32(newValue)
        }
    }


    public init() {
        mode = .period
        period = 0

        obj = TimerObject()
        obj.timerType = mode.rawValue
        obj.period = Int32(period)
        swiftHal_timerInit(&obj)
    }

    deinit {
        swiftHal_timerDeinit(&obj)
    }

    public func setInterrupt(ms period: Int,
                            mode: Mode = .period,
                            start: Bool = true,
                            _ callback: @escaping ()->Void) {
        let initalSet = self.callback == nil ? true : false

        self.period = period
        self.mode = mode
        self.callback = callback
        swiftHal_timerAddSwiftMember(&obj, getClassPtr(self)) {(ptr)->Void in
            let mySelf = Unmanaged<Timer>.fromOpaque(ptr!).takeUnretainedValue()
            mySelf.callback!()
        }
        if start {
            swiftHal_timerStart(&obj)
        } else if initalSet == false {
            swiftHal_timerStop(&obj)
        }
    }

    public func start() {
        swiftHal_timerStart(&obj)
    }

    public func stop() {
        swiftHal_timerStop(&obj)
    }

    public func reset() {
        swiftHal_timerCount(&obj)
    }

}


extension Timer {
    public enum Mode: UInt8 {
        case oneShot, period
    }
}
