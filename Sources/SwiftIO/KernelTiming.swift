//=== KernelTiming.swift --------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 12/08/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO


/**
When you invoke the wait function, the CPU keeps on checking if the time
 (in microsecond）is up. In addition, this function is more accurate than
 ``sleep(ms:)`` function.
*/
@inline(__always)
public func wait(us: Int) {
    swifthal_us_wait(UInt32(us))
}

/**
 Suspends the processor's work in a given time period
 (in millisecond).
 */
@inline(__always)
public func sleep(ms: Int) {
    swifthal_ms_sleep(Int32(ms))
}

/**
Gets the elapsed time in millisecond since the board powers up.
- Returns: The elapsed time since system powers up in millisecond.
*/
public func getSystemUptimeInMilliseconds() -> Int64 {
    return swifthal_uptime_get()
}

/**
 Gets the current clock cycle of the low level 32bit timer.

 This function is only used to measure **very short time duration** with ``cyclesToNanoseconds(start:stop:)``.

 - Attention: This value is got from a 32bit register driven by the CPU frequency,
 and will overflow every a few seconds.

 - Returns: The current clock cycle in UInt.
 */
@inline(__always)
public func getClockCycle() -> UInt {
    return UInt(swifthal_hwcycle_get())
}

/**
 Converts the clock cycles into nanoseconds.

 This function is usually used with ``getClockCycle()``. For example,

 ```swift
 let start = getClockCycle()
 ...
 let stop = getClockCycle()
 let time = cyclesToNanoseconds(start: start, stop: stop)
 ```

 - Parameter start: The start cycle get by ``getClockCycle()``.
 - Parameter stop: The stop cycle get by ``getClockCycle()``.
 - Returns: The duration in nanoseconds.
 */
public func cyclesToNanoseconds(start: UInt, stop: UInt) -> Int64 {
    let cycles = stop >= start ? stop - start : UInt.max - start + stop + 1

    return Int64(swifthal_hwcycle_to_ns(UInt32(cycles)))
}
