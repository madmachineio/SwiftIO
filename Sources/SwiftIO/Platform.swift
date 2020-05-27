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
 - Attention:
    This is the bottom layer 32bit clock drived by the CPU frequency, it would overflow evey a few seconds.
    This function is only used to mesuare very short time interval with `cyclesToNs(start: UInt, stop: UInt)`
Get the clock cycle of the low level 32bit timer.
- Returns: The current clock cycle in UInt.
*/
@inline(__always)
public func getClockCycle() -> UInt {
    return UInt(swiftHal_getClockCycle())
}

/**

Convert the clock cycle into nanosecond. This function is usually used together with `getClockCycle()`.
 - Parameter start: **REQUIRED** The star cycle get by `getClockCycle()`
 - Parameter callback: **REQUIRED** The stop cycle get by `getClockCycle()`
 - Returns: The time in nanosecond.
*/
@inline(__always)
public func cyclesToNanosecond(start: UInt, stop: UInt) -> Int64 {
    var cycles: UInt

    if stop >= start {
        cycles = stop - start
    } else {
        cycles = UInt.max - start + stop + 1
    }

    return Int64(swiftHal_computeNanoseconds(UInt32(cycles)))
}
