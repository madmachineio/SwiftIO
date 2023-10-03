//=== PWMOut.swift --------------------------------------------------------===//
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
 The PWMOut class is used to generate periodic square waves and modulate the pulse
 width to get different average output.

 A PWM signal switches rapidly between on and off. The longer the output stays
 high, the higher the average voltage. There are two key factors: the frequency
 and duty cycle. **Frequency** defines the speed of on-off switching.
 **Duty cycle** decides the proportion of high output in a period.

 To start with, you need to initialize a pin as a PWMOut pin. A pin on board may
 be multifunctional (PWM output, analog...), plus many pins can be
 used as PWM output pins. So you should specify a pin and its function.
 - `PWMOut` tells the pin's usage.
 - `Id.PWM0A` defines which pin is used. You may refer to the board's pinout
 which shows all pins and their corresponding functions in a diagram.

```swift
let pin = PWMOut(Id.PWM0A)
```

 You can also set the default frequency and duty cycle of the PWM pin when
 initializing it.

 ```swift
 let pin = PWMOut(Id.PWM0A, frequency: 1500, dutycycle: 0.5)
 ```
 
- Important: The PWM pins with same number are paired, like PWM3A and PWM3B.
 They can only share the same frequency.

### Example 1: Light a LED with a specified brightness

```swift
 // Import the SwiftIO to use the related board functions.
 import SwiftIO
 // Import the MadBoard to decide which pin is used for the specific function.
 import MadBoard
 
// Initialize a PWMOut pin PWM0A with default setting.
let led = PWMOut(Id.PWM0A)
 
// Setting the duty cycle to light the LED with half brightness.
while true {
    led.setDutycycle(0.5)
}
```

 In this case, the duty cycle of PWM output affects the LED brightness, since it
 sets the proportion of the LED on time during a period. The frequency of
 the signal only changes how fast the LED turns on and off. As long as it is not
 too low, the flicker will be unnoticeable.

 ### Example 2: Make sound with a buzzer

 ```swift
 import SwiftIO
 import MadBoard

 let buzzer = PWMOut(Id.PWM0A, frequency: 0)

 // Set the frequency of PWM to decide the sound pitch.
 // The duty cycle can be any value bigger than 0 to generate sound.
 buzzer.set(frequency: 1500, dutycycle: 0.5)
 // Keep the sound for 1s.
 sleep(ms: 1000)
 // Suspend the PWM output to stop the sound.
 buzzer.suspend()

 while true {
    sleep(ms: 1000)
 }
 ```
In this example, the sound from a buzzer relates to the movement of its internal
 component. The faster the movement, the higher the pitch. So the frequency plays
 an important role.

*/
public final class PWMOut {
    private let id: Int32 
    public let obj: UnsafeRawPointer

    private let info: swift_pwm_info_t

    private var period: Int = 0
    private var pulse: Int = 0
    /**
     The max frequency of PWM output.
     */

    public var maxFrequency: Int {
        info.max_frequency
    }

    /**
     The min frequency of PWM output.
     */
    public var minFrequency: Int {
        info.min_frequency
    }

    /**
     Initializes a PWM output pin.
     
     - Parameter idName: **REQUIRED** The name of output pin. See Id for the board in
     [MadBoards](https://github.com/madmachineio/MadBoards) library for reference.
     - Parameter frequency: **OPTIONAL** The frequency of the PWM signal in hertz, 1000hz by default.
     - Parameter dutycycle: **OPTIONAL** The duration of high output in a
     period. It ranges from 0.0 to 1.0, and 0 by default.


     The pin name is required to initialize a PWM pin. The pins able to output PWM
     signal are marked with a tilde (~) on your board. However, the ids of PWM pins
     aren't directly marked, so you need the board pinout.

     ```swift
     // Initialize the pin PWM0A with other parameters set to default.
     let pin = PWMOut(Id.PWM0A)
     ```
     You may notice the id is a little different from those of other pins like D0, A0... Actually, the pins with the same number are paired, like PWM3A and PWM3B.
     And be sure the pins in a group share the same frequency.

     You can also set the default frequency and duty cycle of the PWM output:

     ```swift
     // Initialize the pin PWM0A with the frequency set to 2000hz and the dutycycle set to 0.5.
     let pin = PWMOut(Id.PWM0A, frequency: 2000, dutycycle: 0.5)
     ```

     */
    public init(
        _ idName: IdName,
        frequency: Int = 1000,
        dutycycle: Float = 0.0
    ) {
        self.id = idName.value
        if let ptr = swifthal_pwm_open(id) {
            obj = UnsafeRawPointer(ptr)
        }
        else {
            fatalError("PWM\(idName.value) initialization failed!")
        }

        var _info = swift_pwm_info_t()
        swifthal_pwm_info_get(obj, &_info)
        info = _info

        set(frequency: frequency, dutycycle: dutycycle)
    }

    deinit {
        swifthal_pwm_close(obj)
    }

    /**
     Sets the frequency and the dutycycle of PWM output signal.
     - Parameter frequency: The frequency of the PWM signal.
     - Parameter dutycycle: The duration of high output in the time period
        from 0.0 to 1.0.
     */
    public func set(frequency: Int, dutycycle: Float) {
        guard frequency >= minFrequency && frequency <= maxFrequency else {
            print("Frequency must fit in [\(minFrequency), \(maxFrequency)]!")
            return
        }
        guard dutycycle >= 0 && dutycycle <= 1.0 else {
            print("Dutycycle must fit in [0.0, 1.0]!")
            return
        }

        period = 1_000_000 / frequency
        pulse = Int(Float(period) * dutycycle)
        
        swifthal_pwm_set(obj, period, pulse)
    }


    /**
     Sets the period and pulse width of PWM output signal.
     - Parameter period: The period of the PWM ouput signal in microsecond.
     - Parameter pulse: The pulse width in the PWM period, that is, the duration
     of high voltage in microsecond. This time can't be longer than the period.
     */
    public func set(period: Int, pulse: Int) {
        self.period = period
        self.pulse = pulse

        swifthal_pwm_set(obj, self.period, self.pulse)
    }


    /**
     Sets the duty cycle of a PWM output signal, that's to say, set the duration
    of the on-state of a signal. The value should be a float between 0.0 and 1.0.
     - Parameter dutycycle: The duration of high output in the time period
        from 0.0 to 1.0.
     */
    public func setDutycycle(_ dutycycle: Float) {
        guard dutycycle >= 0 && dutycycle <= 1.0 else {
            print("Dutycycle must fit in [0.0, 1.0]!")
            return
        }

        pulse = Int(Float(period) * dutycycle)
        swifthal_pwm_set(obj, period, pulse)
    }
    
    /**
     Suspends the PWM output.
     */
    public func suspend() {
        swifthal_pwm_suspend(obj)
    }

    /**
     Continues the PWM output.
     */
    public func resume() {
        swifthal_pwm_resume(obj)
    }
}

