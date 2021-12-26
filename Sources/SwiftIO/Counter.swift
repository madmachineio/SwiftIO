//=== Counter.swift -------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 05/09/2021
// Updated: 11/12/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO


public final class Counter {
    private let id: Int32
    private let obj: UnsafeMutableRawPointer

    private var mode: Mode
    private var periodTicks: UInt32
    private var callback: ((UInt32)->Void)?

    public let counterFrequency: UInt32
    public let maxCountTicks: UInt32
    public let maxCountMicroseconds: UInt64

    public init(_ idName: IdName, mode: Mode = .period, period: UInt64 = 1_000_000) {
        self.id = idName.value
        self.mode = mode

        guard let ptr = swifthal_counter_open(id) else {
            fatalError("Counter \(idName.value) init failed")
        }
            
        obj = UnsafeMutableRawPointer(ptr)
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

    public func stop() {
        swifthal_counter_cancel_channel_alarm(obj)
        swifthal_counter_stop(obj)
    }

    public func getTicks() -> UInt32 {
        return swifthal_counter_read(obj)
    }

    public func getTicks(_ period: UInt64) -> UInt32 {
        return swifthal_counter_us_to_ticks(obj, period)
    }
    
}




extension Counter {
    public enum Mode {
        case oneShot, period
    }
}