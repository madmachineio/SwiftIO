# ``SwiftIO``

The SwiftIO library allows you to access and control the hardware in an easy way.

## Overview

The SwiftIO abstracts low-level hardware stuffs. Hence you can program your board
using simple APIs to access the specific function of the hardware.

![The structure of SwiftIO](structure.png)

This library has done all the necessary work to control your board. For all your
projects, you can invoke the provided functions to get your board to work, and 
even create libraries based on it for future usage.

Besides, it isn't specific to a certain type of board, that's to say, it can 
work with all our boards. As for the board type, it is defined when you create 
projects. 

For some more complicated functions, there are plenty of uncertainties due to 
all kinds of reasons (normally IO errors). So the library adopts error handling 
pattern. You can provide some solutions to deal with errors in advance. 
But it comes at a cost: increased complexity of code to some extent.

Let's start with a hello world project:

```swift
// Import the SwiftIO to use the related board functions.
import SwiftIO
// Import the MadBoard to decide which pin is used for the specific function.
import MadBoard

// Initialize the onboard blue LED to control it by setting output signal.
let led = DigitalOut(Id.BLUE)
​
while true {
    // Set a high voltage to turn off the onboard LED.
    // Please note that the onboard LED needs a low voltage to be turned on 
    // due to circuit connection.
    led.write(true)
    sleep(ms: 1000)

    // Set a low voltage to turn on the onboard LED.
    led.write(false)
    sleep(ms: 1000)
}
```

BTW, if you are new to electronics, there are some [tutorials](https://docs.madmachine.io/tutorials/overview) for you to get started.

