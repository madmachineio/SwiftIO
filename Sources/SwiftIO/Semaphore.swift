
 public class Semaphore {

    private var obj: SemObject
    private let objPtr: UnsafeMutableRawPointer

    private let initalCount: Int
    private let limit: Int

    private func objectInit() {
        obj.initalCount = Int32(initalCount)
        obj.limit = Int32(limit)

        swiftHal_semInit(&obj)
    }

    public init(initalCount: Int = 0,
                limit: Int = 1) {
        self.initalCount = initalCount
        self.limit = limit

        obj = SemObject()
        objPtr = UnsafeMutableRawPointer(&obj)
        objectInit()
    }

    deinit {
        swiftHal_semDeinit(&obj)
    }

    public func give() {
        // swiftHal_semGive(&obj)
        // Since "take" may block the program,
        // It's not allowed to access &obj again druing the time.
        // See "Exclusivity Enforcement" for more info.
        swiftHal_semGive(objPtr)
    }

    public func take(ms: Int = 0) -> Bool {
        let value = swiftHal_semTake(objPtr, Int32(ms))
        return value == 0 ? true : false
    }

    public func takeForever() {
        swiftHal_semTake(objPtr, -1)
    }

    public func getCount() -> Int {
        return Int(swiftHal_semGetCount(objPtr))
    }

    public func reset() {
        swiftHal_semReset(objPtr)
    }

}

