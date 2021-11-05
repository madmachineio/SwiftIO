//=== Counter.swift -------------------------------------------------------===//
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
The counter class can be used to count the external signal and measure the
 number of the pulse. It can detect the rising edge or both edges.
 
- Attention: The maximum count value depends on the lowlevel hardware.
 For example, SwiftIO Board’s counter is 16bit, so the max count value is 65535.
 If the counter reaches the value, it will overflow and start from 0 again.
 
### Example: Read the count value every 10ms

````
import SwiftIO

// Initiate the counter0.
let counter = Counter(Id.C0)

// Count and print the value every 10ms. Use wait here to get a more precise delay.
while true {
    // Clear the counter to set the value to 0.
    counter.clear()
    wait(us: 10_000)
    // Read the value accumulated in 10ms.
    let value = counter.read()
    print("Conter value = \(value)")
}

````
 **or**

 ````
 import SwiftIO

 // Initiate the counter0.
 let counter = Counter(Id.C0)

 // Initialize a timer to set interrupt.
 let timer = Timer()

 // Use the timer to read and print the value every 10ms.
 timer.setInterrupt(ms: 10) {
     let value = counter.read()
     // Clear the value to to 0.
     counter.clear()
     print("Conter value = \(value)")
 }

 while true {
 }

 ````
*/
public final class Counter {
    private let id: Int32
    private let obj: UnsafeMutableRawPointer
    private var info = swift_counter_info_t()
    private var modeRawValue: swift_counter_mode_t

    private var mode: Mode {
        willSet {
            switch newValue {
                case .rising:
                modeRawValue = SWIFT_COUNTER_RISING_EDGE
                case .bothEdge:
                modeRawValue = SWIFT_COUNTER_BOTH_EDGE
            }
        }
    }
    
    /**
     The maximum count value.
     */
    public var maxCountValue: Int {
        Int(info.max_count_value)
    }
    /**
     Initialize the counter.
     
     - Parameter id: **REQUIRED** The id of the counter. See the Id enumeration
        for reference.
     - Parameter mode: **OPTIONAL** The edge of the external signal to detect,
        rising edge or both edges.
     - Parameter start: **OPTIONAL** Whether or not to start the counter after initialization.
     
     ### Usage Example ###
     ````
     let counter = Counter(Id.C0)
     let counter = Counter(Id.C0, mode: .rising)
     let counter = Counter(Id.C0, start: false)

     ````
     */
    public init(_ idName: IdName, mode: Mode = .rising, start: Bool = true) {
        id = idName.value
        self.mode = mode
        switch mode {
            case .rising:
            modeRawValue = SWIFT_COUNTER_RISING_EDGE
            case .bothEdge:
            modeRawValue = SWIFT_COUNTER_BOTH_EDGE
        }
        
        if let ptr = swifthal_counter_open(id) {
            obj = UnsafeMutableRawPointer(ptr)
        } else {
            fatalError("Counter\(idName.value) initialization failed!")
        }

        swifthal_counter_info_get(obj, &info)
        if start {
            self.start()
        }
    }

    deinit {
        swifthal_counter_close(obj)
    }
    /**
     Change the mode to decide whether it detects the rising edge or both
     rising and falling edges.
     
     - Parameter mode : The edge of the external signal to detect, rising edge
        or both edges.
     */
    public func setMode(_ mode: Mode) {
        self.mode = mode
        swifthal_counter_start(obj, modeRawValue)
    }
    /**
     Read the number of edges that has been detected.
     
     - Returns: Return the number of edges. 
     */
    @inline(__always)
    public func read(clear: Bool = true) -> Int {
        let value = Int(swifthal_counter_read(obj))
        if clear {
            swifthal_counter_clear(obj)
        }
        return value
    }
    /**
     Start the counter to measure the value.
     */
    @inline(__always)
    public func start() {
        swifthal_counter_start(obj, modeRawValue)
    }
    /**
     Stop the counter.
     */
    @inline(__always)
    public func stop() {
        swifthal_counter_stop(obj)
    }
    /**
     Clear the value of counter, it will set the value to 0.
     */
    @inline(__always)
    public func clear() {
        swifthal_counter_clear(obj)
    }
}


extension Counter {
    /**
     The Mode enumerate is to decide whether the count detects the rising edge
     or both rising and falling edges.
     
     */
    public enum Mode {
        case rising, bothEdge
    }
}
