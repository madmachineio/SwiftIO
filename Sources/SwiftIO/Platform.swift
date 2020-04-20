import CHal

public protocol IdName {
    var number: UInt8 { get }
}


@inline(__always)
func getClassPtr<T: AnyObject>(_ obj: T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

/**
When you invoke the wait function, the CPU keeps on working and checking if the time set (in microsecond）is up. In addition, this function is more accurate than the sleep function.
*/
@inline(__always)
public func wait(us: Int) {
    swiftHal_usWait(Int32(us))
}

/**
 The sleep function will suspend the processor's work in a given time period (in millisecond).
 */
@inline(__always)
public func sleep(ms: Int) {
    swiftHal_msSleep(Int32(ms))
}

/**
Get the elapsed time in millisecond since the board powered up.
- Returns: The elapsed time in millisecond.
*/
@inline(__always)
public func getPowerUpMilliseconds() -> Int64 {
    return swiftHal_getUpTimeInMs()
}

/**
Get the clock cycle time of the processor.
- Returns: The time period.
*/
@inline(__always)
public func getClockCycle() -> UInt {
    return UInt(swiftHal_getClockCycle())
}

/**
Convert the clock cycle into nanosecond. This function is usually used together with getClockCycle.
 - Returns: The time in nanosecond after the calculation.
*/
@inline(__always)
public func calcNanoseconds(_ cycles: UInt) -> UInt {
    return UInt(swiftHal_computeNanoseconds(UInt32(cycles)))
}
