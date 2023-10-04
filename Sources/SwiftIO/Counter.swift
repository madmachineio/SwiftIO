//=== Counter.swift -------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 05/09/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO

/// The Counter class is used to track the number of the clock ticks.
///
/// It is actually a hardware timer. The clock tick is derived from hardware clock
/// cycle. To create a counter, you can specify the counter's period in
/// microsecond and don't need to calculate the number of ticks in a period.
///
/// ```swift
/// // Initialize a periodic counter with a default period of 1s.
/// let counter = Counter(Id.C0)
/// ```
///
/// The counter is suitable for some situation that requires more accurate time,
/// but cannot track too long (usually several seconds) in case of overflow.
public final class Counter {
    private let id: Int32
    public let obj: UnsafeRawPointer

    private var mode: Mode
    private var periodTicks: UInt32
    private var callback: ((UInt32)->Void)?

    /// The frequency of counter in Hz.
    public let counterFrequency: UInt32
    /// The maximum number of ticks for counter.
    public let maxCountTicks: UInt32
    /// The maximum time for counter in microsecond.
    public let maxCountMicroseconds: UInt64

    /// Initializes a counter.
    /// - Parameters:
    ///   - idName: **REQUIRED** The id of the counter. See Id in
    ///   [MadBoards](https://github.com/madmachineio/MadBoards) library for reference.
    ///   - mode: **OPTIONAL** Whether the counter is periodic or one shot,
    ///   `.period` by default.
    ///   - period: **OPTIONAL** The period of the counter in microsecond.
    public init(_ idName: IdName, mode: Mode = .period, period: UInt64 = 1_000_000) {
        self.id = idName.value
        self.mode = mode

        guard let ptr = swifthal_counter_open(id) else {
            fatalError("Counter \(idName.value) init failed")
        }
            
        obj = UnsafeRawPointer(ptr)
        counterFrequency = swifthal_counter_freq(obj)
        maxCountTicks = swifthal_counter_get_max_top_value(obj)
        maxCountMicroseconds = swifthal_counter_ticks_to_us(obj, maxCountTicks)
        periodTicks = swifthal_counter_us_to_ticks(obj, period)
    }

    deinit {
        swifthal_counter_cancel_channel_alarm(obj)
        swifthal_counter_stop(obj)
        swifthal_counter_close(obj)
    }



    /// Executes a designated task if the specified period has elapsed.
    /// - Parameters:
    ///   - start: Whether to start the counter once it’s set, `true` by default.
    ///   - callback: A task to execute once interrupt is triggered. The callback
    ///   function need a UInt32 as its parameter, such as the number of ticks.
    public func setInterrupt(
        start: Bool = true,
        _ callback: @escaping (UInt32) -> Void
    ) {
        swifthal_counter_stop(obj)

        self.callback = callback
        swifthal_counter_add_callback(obj, getClassPointer(self)) { (ticks, ptr) -> Void in
            let mySelf = Unmanaged<Counter>.fromOpaque(ptr!).takeUnretainedValue()
            if mySelf.mode == .period {
                swifthal_counter_stop(mySelf.obj)
                swifthal_counter_set_channel_alarm(mySelf.obj, mySelf.periodTicks)
                swifthal_counter_start(mySelf.obj)
            } else {
                swifthal_counter_stop(mySelf.obj)
            }
            mySelf.callback!(ticks)
        }

        if start {
            swifthal_counter_set_channel_alarm(obj, periodTicks)
            swifthal_counter_start(obj)
        }
    }

    /// Starts the counter.
    /// - Parameters:
    ///   - mode: The mode of the counter. If it’s nil, it adopts the mode set
    ///   when initializing the counter.
    ///   - period: The period of the counter in microsecond. If it’s nil, it
    ///   equals the period set when initializing the counter.
    public func start(mode: Mode? = nil, period: UInt64? = nil) {
        if let mode = mode {
            self.mode = mode
        }
        if let period = period {
            self.periodTicks = swifthal_counter_us_to_ticks(obj, period)
        }

        swifthal_counter_cancel_channel_alarm(obj)
        swifthal_counter_stop(obj)
        swifthal_counter_set_channel_alarm(obj, periodTicks)
        swifthal_counter_start(obj)
    }

    /// Stops the counter.
    public func stop() {
        swifthal_counter_cancel_channel_alarm(obj)
        swifthal_counter_stop(obj)
    }

    /// Gets the number of ticks that have elapsed. If the elapsed time is too
    /// long, the value may overflow.
    /// 
    /// - Returns: The number of ticks in UInt32.
    public func getTicks() -> Result<UInt32, Errno> {
        var ticks: UInt32 = 0

        let result = nothingOrErrno(
            swifthal_counter_read(obj, &ticks)
        )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            return .failure(err)
        }

        return .success(ticks)
    }

    /// Converts the time in microsecond to the number of ticks.
    /// - Parameter period: The specified time period.
    /// - Returns: The corresponding number of ticks.
    public func getTicks(from period: UInt64) -> UInt32 {
        return swifthal_counter_us_to_ticks(obj, period)
    }
    
}




extension Counter {
    /// There are two modes: oneShot means the counter works only once;
    /// period means it works periodically.
    public enum Mode {
        case oneShot, period
    }
}
