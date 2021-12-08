//=== Timer.swift ---------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 05/09/2021
// Updated: 11/05/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO

/**
 The Timer class is used to set the occasion to raise the interrupt.


 ### Example: Reverse the output value on a digital output pin

 ````
 import SwiftIO

 let timer = Timer()
 let led = DigitalOut(Id.GREEN)

 // The setInterrupt function can be written as following:
 func toggleLed() {
    led.toggle()
 }
 timer.setInterrupt(ms: 1000, toggleLed)

 while true {
 }
 ````

 **or**

 ````
 import SwiftIO

 let timer = Timer()
 let led = DigitalOut(Id.GREEN)

 // Set interrupt with a closure
 timer.setInterrupt(ms: 1000) {
    led.toggle()
 }

 while true {
 }
 ````
*/
public final class Timer {
    private var obj: UnsafeMutableRawPointer
    private var modeRawValue: swift_timer_type_t

    private var mode: Mode {
        willSet {
            modeRawValue = Timer.getModeRawvalue(newValue)
        }
    }
    private var period: Int32
    private var callback: (()->Void)?

    /**
     Intialize a timer.
     */
    public init(mode: Mode = .period, period: Int = 1000) {
        self.mode = mode
        self.modeRawValue = Timer.getModeRawvalue(mode)

        self.period = Int32(period)

        if let ptr = swifthal_timer_open() {
            obj = UnsafeMutableRawPointer(ptr)
        } else {
            fatalError("Timer init failed!")
        }
    }

    deinit {
        swifthal_timer_close(obj)
    }

    /**
     Execute a designated task  at a scheduled time interval. The task
     should be executed in a very short time, usually in nanoseconds.
     - Parameter ms: **REQUIRED** The time period set for the interrupt.
     - Parameter mode: **OPTIONAL** The times that the interrupt will occur:
        once or continuous.
     - Parameter start: **OPTIONAL** By default, the interrupt will start
        directly to work.
     - Parameter callback: **REQUIRED** A void function without a return value.
     
     */
    public func setInterrupt(
        start: Bool = true,
        _ callback: @escaping ()->Void
    ) {
        self.callback = callback
        swifthal_timer_add_callback(obj, getClassPointer(self)) { (ptr)->Void in
            let mySelf = Unmanaged<Timer>.fromOpaque(ptr!).takeUnretainedValue()
            mySelf.callback!()
        }

        if start {
            swifthal_timer_start(obj, self.modeRawValue, self.period)
        } else {
            swifthal_timer_stop(obj)
        }
    }

    /**
     Start the timer. The timer's status will be reset to zero.
     */
    public func start(mode: Mode? = nil, period: Int? = nil) {
        if let mode = mode {
            self.mode = mode
        }
        if let period = period {
            self.period = Int32(period)
        }
        swifthal_timer_start(obj, self.modeRawValue, self.period)
    }

    /**
     Stop the timer.
     */
    public func stop() {
        swifthal_timer_stop(obj)
    }

    /**
     Get the timer's status. The timer status will be reset to zero.
     */
    public func getStatus() -> Int {
        return Int(swifthal_timer_status_get(obj))
    }

    // TODO
    public func getRemaining() -> UInt32 {
        //return swifthal_timer_remaining_get(obj)
        return 0
    }

}


extension Timer {
    /**
     There are two timer modes: if set to `oneShot`, the interrupt happens
     only once; if set to `period`, the interrupt happens continuously.
     */
    public enum Mode {
        case oneShot, period
    }

    private static func getModeRawvalue(_ mode: Mode) -> swift_timer_type_t {
        switch mode {
            case .oneShot:
            return SWIFT_TIMER_TYPE_ONESHOT
            case .period:
            return SWIFT_TIMER_TYPE_PERIOD
        }
    }
}
