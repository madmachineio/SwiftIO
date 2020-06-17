import CHal

/**
 The PWMOut class is used to vary the output voltage by controlling the duration of high output in the time periodCycles on the pin.
 
- Attention: The PWM pins with same number are paired, like PWM3A and PWM3B. They can only share the same frequency.

### Example: Light a LED

````
import SwiftIO
 
// Initiate a PWMOut to Pin PWM0A.
let led = PWMOut(Id.PWM0A)
 
// Set the brightness of the LED by setting the duty cycle.
while true {
    led.setDutycycle(0.5)
}
````
*/
public final class PWMOut {
    private var obj: PWMOutObject

    private let id: IdName

    private func objectInit() {
        obj.idNumber = id.number
        swiftHal_PWMOutInit(&obj)
    }

    /**
     The max frequency of PWM output.
     */

    public var maxFrequency: Int {
        Int(obj.info.maxFrequency)
    }

    /**
     The min frequency of PWM output.
     */
    public var minFrequency: Int {
        Int(obj.info.minFrequency)
    }

    /**
     Initialize a PWM output on a specified pin.
     - Parameter id: **REQUIRED** The name of PWMOut pin. See Id for reference.
     - Parameter frequency: **OPTIONAL** The frequency of the PWM signal.
     - Parameter dutycycle: **OPTIONAL** The duration of high output in the time period from 0.0 to 1.0.
     
     #### Usage Example
     ````
     // The most simple way of initiating a pin PWM0A, with all other parameters set to default.
     let pin = PWMOut(Id.PWM0A)
     ​
     // Initialize the pin PWM0A with the frequency set to 2000hz.
     let pin = PWMOut(Id.PWM0A, frequency: 2000)
     
     // Initialize the pin PWM0A with the frequency set to 2000hz and the dutycycle set to 0.5.
     let pin = PWMOut(Id.PWM0A, frequency: 2000, dutycycle: 0.5)
     ````
     */
    public init(_ id: IdName,
                frequency: Int = 1000,
                dutycycle: Float = 0.0) {

        self.id = id

        obj = PWMOutObject()
        objectInit()

        set(frequency: frequency, dutycycle: dutycycle)
    }

    deinit {
        swiftHal_PWMOutDeinit(&obj)
    }

    /**
     Set the frequency and the dutycycle of a PWM output signal. The value of the dutycycle should be a float between 0.0 and 1.0.
     - Parameter frequency: The frequency of the PWM signal.
     - Parameter dutycycle: The duration of high output in the time period from 0.0 to 1.0.
     */
    public func set(frequency: Int, dutycycle: Float) {
        guard frequency >= 0 && dutycycle >= 0 && dutycycle <= 1.0 else {
            print("Frequency must be non-negative and dutycycle must fit in [0.0, 1.0]!")
            return
        }

        swiftHal_PWMOutSetFrequency(&obj, Int32(frequency), dutycycle)
    }


    /**
     Set the period and pulse width of a PWM output signal.
     - Parameter period: The period of the PWM ouput signal in microsecond.
     - Parameter pulse: The pulse width in the PWM period. This time can't be longer than the period.
     */
    public func set(period: Int, pulse: Int) {
        swiftHal_PWMOutSetUsec(&obj, Int32(period), Int32(pulse))
    }


    /**
     Set the duty cycle of a PWM output signal, that's to say, set the duration of the on-state of a signal. The value should be a float between 0.0 and 1.0.
     - Parameter dutycycle: The duration of high output in the time period from 0.0 to 1.0.
     */
    @inline(__always)
    public func setDutycycle(_ dutycycle: Float) {
        guard dutycycle >= 0 && dutycycle <= 1.0 else {
            print("Dutycycle must fit in [0.0, 1.0]!")
            return
        }
        swiftHal_PWMOutSetDutycycle(&obj, dutycycle);
    }
    
    /**
     Stop the PWM output.
     */
    public func suspend() {
        swiftHal_PWMOutSuspend(&obj)
    }

    /**
     Continue the PWM output.
     */
    public func resume() {
        swiftHal_PWMOutResume(&obj)
    }
}

