func getClassPtr<T: AnyObject>(_ obj: T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

public func wait(us: Int) {
    swiftHal_usWait(UInt32(us))
}

public func sleep(ms: Int) {
    swiftHal_msSleep(UInt32(ms))
}

public func getPowerUpMilliseconds() -> UInt {
    return UInt(swiftHal_getUpTimeInMs32())
}

public func getPowerUpMilliseconds64() -> Int64 {
    return Int64(swiftHal_getUpTimeInMs64())
}

public func getClockCycle() -> UInt {
    return UInt(swiftHal_getClockCycle())
}

public func calcNanoseconds(_ cycles: UInt) -> UInt {
    return UInt(swiftHal_computeNanoseconds(UInt32(cycles)))
}