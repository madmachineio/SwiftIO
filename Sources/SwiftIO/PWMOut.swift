/**
The PWMOut class is used to vary the output voltage by controlling the duration of high output in the time period on the pin. 


*/
public class PWMOut {
    var obj: PWMOutObject

    /**
     Initialize a PWM output on a specified pin.
     - Parameter id: **REQUIRED** The name of PWMOut pin. See Id for reference.
     - Parameter hz: **OPTIONAL** The frequency of the PWM signal.
     - Parameter dutycycle: **OPTIONAL** The duration of high output in the time period from 0.0 to 1.0.
     
     #### Usage Example
     ````
     // The most simple way of initiating a pin PWM0, with all other parameters set to default.
     let pin = PWMOut(.PWM0)
     ​
     // Initialize the pin PWM0 with the frequency set to 1000hz.
     let pin = PWMOut(.PWM0, hz: 1000)
     ​
     // Initialize the pin PWM0 with the dutycycle set to 0.5.
     let pin = PWMOut(.PWM0, dutycycle: 0.5)
     
     // Initialize the pin PWM0 with the frequency set to 1000hz and the dutycycle set to 0.5.
     let pin = PWMOut(.PWM0, hz: 1000, dutycycle: 0.5)
     ````
     */
    public init(_ id: Id,
                period: Int = 1000,
                pulse: Int = 0) {
        obj = PWMOutObject()
        obj.id = id.rawValue
        obj.period = UInt32(period)
        obj.pulse = UInt32(pulse)
        obj.countPerSecond = 1000000

        swiftHal_PWMOutInit(&obj)
    }

    deinit {
        swiftHal_PWMOutDeinit(&obj)
    }

    /**
     Set the period and pulse width of a PWM output signal.
     - Parameter period: The period of the PWM ouput signal in microsecond.
     - Parameter pulse: The pulse width in the PWM period. This time can't be longer than the period.
     */
    public func set(period: Int, pulse: Int) {
        obj.period = UInt32(period)
        obj.pulse = UInt32(pulse)
        swiftHal_PWMOutConfig(&obj)
    }

    /**
     Set the frequency and the duty cycle of a PWM output signal. The value of the duty cycle should be a float between 0.0 and 1.0.
     - Parameter hz: The frequency of the PWM signal.
     - Parameter dutycycle: The duration of high output in the time period from 0.0 to 1.0.
     */
    public func set(frequency hz: Int, dutycycle: Float) {
        obj.period = UInt32(1000000 / hz)
        obj.pulse = UInt32(1000000.0 / (Float(hz) * dutycycle))
        swiftHal_PWMOutConfig(&obj)
    }

    /**
     Set the duty cycle of a PWM output signal, that's to say, set the duration of the on-state of a signal. The value should be a float between 0.0 and 1.0.
     - Parameter dutycycle: The duration of high output in the time period from 0.0 to 1.0.
     */
    public func setDutycycle(_ dutycycle: Float) {
        obj.pulse = UInt32(Float(obj.period) * dutycycle)
        swiftHal_PWMOutConfig(&obj)
    }

}


extension PWMOut {
    
    /**
     The PWMOut pins are PMW0 to PMW13 marked with a tilde on the board.
     */
    public enum Id: UInt8 {
        case PWM0, PWM1, PWM2, PWM3, PWM4, PWM5, PWM6, PWM7, PWM8, PWM9, PWM10, PWM11, PWM12, PWM13
    }
}
