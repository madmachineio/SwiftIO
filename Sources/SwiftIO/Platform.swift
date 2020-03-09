func getClassPtr<T: AnyObject>(_ obj: T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

public func wait(us: Int) {
    swiftHal_usWait(Int32(us))
}

public func sleep(ms: Int) {
    swiftHal_msSleep(Int32(ms))
}


public func getPowerUpMilliseconds() -> Int64 {
    return swiftHal_getUpTimeInMs()
}

public func getClockCycle() -> UInt {
    return UInt(swiftHal_getClockCycle())
}

public func calcNanoseconds(_ cycles: UInt) -> UInt {
    return UInt(swiftHal_computeNanoseconds(UInt32(cycles)))
}