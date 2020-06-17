import CHal

/**
The counter class can be used to count the external signal and measure the number of the pulse. It can detect the rising edge or both edges.
 
- Attention: The maximum count value depends on the lowlevel hardware. For example, SwiftIO Board’s counter is 16bit, so the max count value is 65535. If the counter reaches the value, it will overflow and start from 0 again.
 
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
    private var obj: CounterObject
    private let id: IdName
    private var mode: Mode {
        willSet {
            obj.mode = newValue.rawValue
        }
    }
    
    private func objectInit() {
        obj.idNumber = id.number
        obj.mode = mode.rawValue
        swiftHal_CounterInit(&obj)
    }
    /**
     The maximum count value.
     */
    public var maxCountValue: Int {
        Int(obj.info.maxCountValue)
    }
    /**
     Initialize the counter.
     
     - Parameter id: **REQUIRED** The id of the counter. See the Id enumeration for reference.
     - Parameter mode: **OPTIONAL** The edge of the external signal to detect, rising edge or both edges.
     - Parameter start: **OPTIONAL** Whether or not to start the counter after initialization.
     
     ### Usage Example ###
     ````
     let counter = Counter(Id.C0)
     let counter = Counter(Id.C0, mode: .rising)
     let counter = Counter(Id.C0, start: false)

     ````
     */
    public init(_ id: IdName, mode: Mode = .rising, start: Bool = true) {
        self.id = id
        self.mode = mode
        obj = CounterObject()
        objectInit()
        if start {
            self.start()
        }
    }

    deinit {
        swiftHal_CounterDeinit(&obj)
    }
    /**
     Change the mode to decide whether it detects the rising edge or both rising and falling edges.
     
     - Parameter mode : The edge of the external signal to detect, rising edge or both edges.
     */
    public func setMode(_ mode: Mode) {
        self.mode = mode
        swiftHal_CounterStart(&obj)
    }
    /**
     Read the number of edges that has been detected.
     
     - Returns: Return the number of edges. 
     */
    @inline(__always)
    public func read() -> Int {
        return Int(swiftHal_CounterRead(&obj))
    }
    /**
     Start the counter to measure the value.
     */
    @inline(__always)
    public func start() {
        swiftHal_CounterStart(&obj)
    }
    /**
     Stop the counter.
     */
    @inline(__always)
    public func stop() {
        swiftHal_CounterStop(&obj)
    }
    /**
     Clear the value of counter, it will set the value to 0.
     */
    @inline(__always)
    public func clear() {
        swiftHal_CounterClear(&obj)
    }
}


extension Counter {
    /**
     The Mode enumerate is to decide whether the count detects the rising edge or both rising and falling edges.
     
     */
    public enum Mode: UInt8 {
        case rising = 1, bothEdge
    }
}
