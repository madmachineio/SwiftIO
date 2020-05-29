import CHal

public final class Counter {
    private var obj: CounterObject
    private let id: IdName
    private var mode: Mode {
        willSet {
            obj.mode = newValue.rawValue
        }
    }
    
    private func objectInit() {
        obj.idNumber = id.number
        obj.mode = mode.rawValue
        swiftHal_CounterInit(&obj)
    }

    public var maxCountValue: Int {
        Int(obj.info.maxCountValue)
    }

    public init(_ id: IdName, mode: Mode = .rising, start: Bool = true) {
        self.id = id
        self.mode = mode
        obj = CounterObject()
        objectInit()
        if start {
            self.start()
        }
    }

    deinit {
        swiftHal_CounterDeinit(&obj)
    }

    public func setMode(_ mode: Mode) {
        self.mode = mode
        swiftHal_CounterStart(&obj)
    }

    @inline(__always)
    public func read() -> Int {
        return Int(swiftHal_CounterRead(&obj))
    }

    @inline(__always)
    public func start() {
        swiftHal_CounterStart(&obj)
    }

    @inline(__always)
    public func stop() {
        swiftHal_CounterStop(&obj)
    }

    @inline(__always)
    public func clear() {
        swiftHal_CounterClear(&obj)
    }
}


extension Counter {
    public enum Mode: UInt8 {
        case rising = 1, bothEdge
    }
}