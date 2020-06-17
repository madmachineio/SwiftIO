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
- Returns: The elapsed time since power up in millisecond.
*/
@inline(__always)
public func getPowerUpMilliseconds() -> Int64 {
    return swiftHal_getUpTimeInMs()
}

/**
Get the current clock cycle of the low level 32bit timer.
 - Attention:
    This value is got from a 32bit register driven by the CPU frequency, it would overflow every a few seconds.
    This function is only used to measure very short time duration with `cyclesToNanoseconds(start: UInt, stop: UInt)`.

 - Returns: The current clock cycle in UInt.
*/
@inline(__always)
public func getClockCycle() -> UInt {
    return UInt(swiftHal_getClockCycle())
}

/**
Convert the clock cycle into nanoseconds. This function is usually used together with `getClockCycle()`.
 - Parameter start: The start cycle get by `getClockCycle()`.
 - Parameter stop: The stop cycle get by `getClockCycle()`.
 - Returns: The duration in nanoseconds.
*/
public func cyclesToNanoseconds(start: UInt, stop: UInt) -> Int64 {
    var cycles: UInt

    if stop >= start {
        cycles = stop - start
    } else {
        cycles = UInt.max - start + stop + 1
    }

    return Int64(swiftHal_computeNanoseconds(UInt32(cycles)))
}
