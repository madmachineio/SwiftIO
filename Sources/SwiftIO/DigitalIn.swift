//=== DigitalIn.swift -----------------------------------------------------===//
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



/**
 The DigitalIn class is intended to detect the state of a digital input pin.
 The input value is either true(1) or false(0).
 
 ### Example: Read and print the input value on a digital input pin.
 
 ````
 import SwiftIO
 
 //Initialize a DigitalIn to the digital pin D0.
 let pin = DigitalIn(Id.D0)
 
 //Read and print the input value every 1 second.
 while true {
     var value = pin.read()
     print("The input value is \(value)")
     sleep(ms: 1000)
 }
 ````
 */
public final class DigitalIn {
    private let id: Int32 



    private var mode: Mode

    public let alwaysSuccess: Result<(), Errno> = .success(())

    private var interruptMode: InterruptMode
    private var interruptState: InterruptState = .disable

    private var callback: (()->Void)?

    public var expectRead: [Bool] = [] {
        willSet {
            readIndex = 0
        }
    }
    public var readIndex = 0
    
    /**
     Initialize a DigitalIn to a specified pin.
     
     - parameter id: **REQUIRED** The Digital id on the board.
        See Id for the specific board in MadBoards library for reference.
     - parameter mode: **OPTIONAL** The input mode. `.pullDown` by default.
     
     
     ### Usage Example ###
     ````
     // The most simple way of initiating a pin D0, with all other parameters
     set to default.
     let pin = DigitalIn(Id.D0)
     
     // Initialize the pin D0 with the pulldown mode.
     let pin = DigitalIn(Id.D0, mode: .pullDown)
     ````
     */
	public init(_ idName: Id,
                mode: Mode = .pullDown) {
        self.id = id
        self.mode = mode
        self.interruptMode = .falling

	}

    deinit {
        if callback != nil {
            removeInterrupt()
        }
    }

    /**
     Get the current input mode on a specified pin.
     
     - Returns: The current input mode: `.pullUp`, `.pullDown` or `.pullNone`.
     */
    public func getMode() -> Mode {
        return mode
    }

    /**
     Set the input mode for a digital input pin.
     
     - Parameter mode : The input mode.
     */
    @discardableResult
	public func setMode(_ mode: Mode) -> Result<(), Errno> {
        let oldMode = self.mode
		self.mode = mode

        let result = alwaysSuccess

        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            self.mode = oldMode
        }

        return result
	}


    /**
     Read the value from a digital input pin.
     
     - Attention: Dependind on the hardware, the internal pull resister may be
     very weak. **Don't** just rely on the pull resister for reading the value. **Especially** when you just changed the input mode, the internel pad need
     some time to charge or discharge through the pull resister!
     
     - Returns: `true` or `false` of the logic value.
     */
    @inline(__always)
	public func read() -> Bool {
        let result = alwaysSuccess

        switch result {
        case .success:
            let value = expectRead[readIndex]
            readIndex += 1
            return value
        case .failure(let err):
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            return false
        }
	}

    /**
     Add a callback function to a specified digital pin to set interrupt by
     detcting the changes of the signal. Once the risng or falling edge is
     detected, the processor will suspend the normal execution to execute the
     designated task.
     
     The task should be able to finish in a very short time, usually in
     nanoseconds. Then,  the processor will return back to where it stopped
     and continue the previous operation.
     - Parameter mode : The interrupt mode to detect rising or falling edge.
     - Parameter enable : Whether to enable the interrupt.
     - Parameter callback : A void function without a return value.
     */
    @discardableResult
    public func setInterrupt(
        _ mode: InterruptMode,
        enable: Bool = true,
        callback: @escaping ()->Void
    ) -> Result<(), Errno> {
        let oldInterruptMode = interruptMode
        interruptMode = mode

        if self.callback != nil {
            removeInterrupt()
        }
        self.callback = callback

        var result = alwaysSuccess
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            interruptMode = oldInterruptMode
            return result
        }

        // result = nothingOrErrno(
        //     swifthal_gpio_interrupt_callback_install(
        //         obj, getClassPointer(self)
        //     ) { (ptr)->Void in
        //         let mySelf = Unmanaged<DigitalIn>.fromOpaque(ptr!).takeUnretainedValue()
        //         mySelf.callback!()
        //     }
        // )
        if case .failure(let err) = result {
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            return result
        }

        if enable {
            result = enableInterrupt()
            if case .failure(let err) = result {
                print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            }
        }

        return result
    }

    /**
     Trigger the interrupt after detecting the edge.
    
     */
    @discardableResult
    public func enableInterrupt() -> Result<(), Errno> {
        guard callback != nil else {
            let err = Errno.resourceBusy
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
            return .failure(err)
        }

        let result = alwaysSuccess
        if case .success = result {
            interruptState = .enable
        }
        return result
    }

    /**
     Disable the interrupt until the interrupt state is changed.
    
     */
    @discardableResult
    public func disableInterrupt() -> Result<(), Errno> {
        let result = alwaysSuccess
        if case .success = result {
            interruptState = .disable
        }
        return result
    }

    /**
     Check whether the interrupt is enabled.
     
     - Returns: The input mode: `.enable` or `.diable`.
     */
    public func getInterruptState() -> InterruptState {
        return interruptState
    }

    /**
     Remove the interrupt.
    
     */
    @discardableResult
    public func removeInterrupt() -> Result<(), Errno> {
        if interruptState != .disable {
            disableInterrupt()
        }

        let result = alwaysSuccess
        callback = nil
        return result
    }
}

extension DigitalIn {
    /**
     The digital input modes can change the default state (high, low or
     floating) of a pin by using the pull resistors.
     - Attention: The pins D26 to D37 are connected separately to an external
     10kΩ resistor on the board. So even if they are changed to pullUp,
     the output voltage of these pins is still low.
     */
    public enum Mode {
        case pullDown, pullUp, pullNone
    }


    /**
     The interrupt mode determines the edge to raise the interrupt: rising,
     falling or both edges. A rising edge is the transition of a digital input
     signal from high to low and a falling edge is from low to high.

     */
    public enum InterruptMode {
        case rising, falling, bothEdge
    }


    /**
     The interrupt state determines whether the interrupt will be enabled and occur.

     */
    public enum InterruptState {
        case disable, enable
    }
}
