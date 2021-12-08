//=== KernelTiming.swift --------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 12/08/2021
// Updated: 12/08/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO


/**
When you invoke the wait function, the CPU keeps on working and checking
 if the time set (in microsecond）is up. In addition, this function is more
 accurate than the sleep function.
*/
@inline(__always)
public func wait(us: Int) {
    swifthal_us_wait(UInt32(us))
}

/**
 The sleep function will suspend the processor's work in a given time period
 (in millisecond).
 */
@inline(__always)
public func sleep(ms: Int) {
    swifthal_ms_sleep(Int32(ms))
}

/**
Get the elapsed time in millisecond since the board powered up.
- Returns: The elapsed time since system power up in millisecond.
*/
public func getSystemUptimeInMilliseconds() -> Int64 {
    return swifthal_uptime_get()
}

/**
Get the current clock cycle of the low level 32bit timer.
 - Attention:
    This value is got from a 32bit register driven by the CPU frequency,
    it would overflow every a few seconds.
    This function is only used to measure very short time duration with `cyclesToNanoseconds(start: UInt, stop: UInt)`.

 - Returns: The current clock cycle in UInt.
*/
@inline(__always)
public func getClockCycle() -> UInt {
    return UInt(swifthal_hwcycle_get())
}

/**
Convert the clock cycle into nanoseconds. This function is usually used
together with `getClockCycle()`.
 - Parameter start: The start cycle get by `getClockCycle()`.
 - Parameter stop: The stop cycle get by `getClockCycle()`.
 - Returns: The duration in nanoseconds.
*/
public func cyclesToNanoseconds(start: UInt, stop: UInt) -> Int64 {
    let cycles = stop >= start ? stop - start : UInt.max - start + stop + 1

    return Int64(swifthal_hwcycle_to_ns(UInt32(cycles)))
}
