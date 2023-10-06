//=== Timer.swift ---------------------------------------------------------===//
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

/**
 The Timer class can measure the time passed. If the time limit is reached, it
 can execute a specified task.

 A timer must be initialize at first. It can be one shot or periodic. And you can
 set the period of the timer.

 ```swift
 /// Create a periodic timer whose period is 2000s.
 let timer = Timer(period: 2000)
 ```

 The timer can be really useful to carry out an operation after a speicified time
 using ``setInterrupt(start:_:)``. Here'a an example:


 ### Example: Reverse the output value on a digital output pin

 ```swift
 // Import the SwiftIO to use the related board functions.
 import SwiftIO
 // Import the MadBoard to decide which pin is used for the specific function.
 import MadBoard

 // Initialize a timer with a default period 1000ms.
 let timer = Timer()
 // Initialize the onboard green LED.
 let led = DigitalOut(Id.GREEN)

 // The setInterrupt function can be written as follow:
 func toggleLed() {
    led.toggle()
 }
 timer.setInterrupt(toggleLed)

 while true {
    sleep(ms: 1000)
 }
 ```

 **or**

 ```swift
 import SwiftIO
 import MadBoard

 let timer = Timer()
 let led = DigitalOut(Id.GREEN)

 // Set interrupt with a closure.
 timer.setInterrupt() {
    led.toggle()
 }

 while true {
    sleep(ms: 1000)
 }
 ```
*/
public final class Timer {
    public let obj: UnsafeMutableRawPointer

    private var modeRawValue: swift_timer_type_t

    private var mode: Mode {
        willSet {
            modeRawValue = Timer.getModeRawvalue(newValue)
        }
    }
    private var period: Int
    private var callback: (()->Void)?


    /// Initializes a timer.
    /// - Parameters:
    ///   - mode: **OPTIONAL** Whether the timer is periodic or just run once,
    ///   `.period` by default.
    ///   - period: **OPTIONAL** The timer interval in millisecond, 1000 by default.
    public init(mode: Mode = .period, period: Int = 1000) {
        self.mode = mode
        self.modeRawValue = Timer.getModeRawvalue(mode)

        self.period = period

        if let ptr = swifthal_timer_open() {
            obj = ptr
        } else {
            fatalError("Timer init failed!")
        }
    }

    deinit {
        swifthal_timer_close(obj)
    }

    /// Executes a designated task at a scheduled time interval.
    ///
    /// > Important: The task for the interrupt should be executed in a very short
    /// time, usually in nanoseconds, like changing a number or a boolean value.
    /// Besides, changing digital output runs extremely quickly, so it also works.
    /// However, printing a value usually takes several milliseconds and should
    /// be avoided.
    /// - Parameters:
    ///   - start: Whether to start the timer once it's set, true by default.
    ///   - callback: A task to execute once the time is up. It should be a void
    ///   function without a return value.
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

    /// Starts the timer and reset its status to zero.
    /// - Parameters:
    ///   - mode: The mode of the timer. If it's nil, it adopts the mode set
    ///   when initializing the timer.
    ///   - period: The period of the timer in millisecond. If it's nil, it equals
    ///   the period set when initializing the timer.
    public func start(mode: Mode? = nil, period: Int? = nil) {
        if let mode = mode {
            self.mode = mode
        }
        if let period = period {
            self.period = period
        }
        swifthal_timer_start(obj, self.modeRawValue, self.period)
    }

    /**
     Stops the timer.
     */
    public func stop() {
        swifthal_timer_stop(obj)
    }

    /// Gets the timer's status which indicates how many times the timer has expired
    /// since it was last read. It will reset the status to zero.
    ///
    /// - Returns: Timer status.
    public func getStatus() -> UInt32 {
        return swifthal_timer_status_get(obj)
    }


    /// Get time remaining before a timer next expires. This routing computes the
    /// (approximate) time remaining before a running timer next expires.
    /// If the timer is not running, it returns zero.
    ///
    /// - Returns: Remaining time (in milliseconds).
    public func getRemaining() -> UInt32 {
        return swifthal_timer_status_get(obj)
    }

}


extension Timer {
    /**
     There are two timer modes: `oneShot` means the timer works only once;
     `period` means the timer works periodically.
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
