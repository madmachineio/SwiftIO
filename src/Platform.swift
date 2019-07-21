public func usWait(_ us: Int) {
    swiftHal_usWait(Int32(us))
}

public func msSleep(_ ms: Int) {
    swiftHal_msSleep(Int32(ms))
}

public func getUpTime() -> UInt {
    return UInt(swiftHal_getUpTimeInMs32())
}

public func getUpTime64() -> Int64 {
    return Int64(swiftHal_getUpTimeInMs64())
}

public func getClockCycle() -> UInt {
    return UInt(swiftHal_getClockCycle())
}

public func calcNanoseconds(_ cycles: UInt) -> UInt {
    return UInt(swiftHal_computeNanoseconds(UInt32(cycles)))
}