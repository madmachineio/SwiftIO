# SwiftIO

![build](https://github.com/madmachineio/SwiftIO/actions/workflows/build.yml/badge.svg)
[![Discord](https://img.shields.io/discord/592743353049808899?&logo=Discord&colorB=7289da)](https://madmachine.io/discord)
[![twitter](https://img.shields.io/twitter/follow/madmachineio?label=%40madmachineio&style=social)](https://twitter.com/madmachineio)

A Swift framework for microcontrollers. You can program microcontrollers easily without worrying about complicated low-level stuff. After downloading your project to your board, you'll get the results in real time.


## Documentation

SwiftIO library provides easy access to communicate with the external circuits simply by invoking the related classes/methods. You can read or write digital and analog signals, as well as use communication protocols.

Go to [API Documentation](https://madmachineio.github.io/SwiftIO/documentation/swiftio/) for more detailed usage of all the functionalities.


## Library structure

SwiftIO contains several classes to access different functionalities of the board:

* AnalogIn - read analog input
* Counter - count the number of clock ticks
* DigitalIn - read digital input
* DigitalOut - set high/low digital output
* DigitalInOut - set a digital pin as both input and output
* FileDescriptor - perform low-level file operations
* I2C - use the I2C protocol to communicate with other devices
* I2SIn - receive audio data from external devices
* I2SOut - send audio data to external devices
* KernelTiming - global functions related to time
* PWMOut - modulate the pulse width of signal
* SPI - use the SPI protocol to communicate with other devices
* Timer - set a time interval to do a specified task
* UART - use the UART protocol to communicate with other devices


## Usage example

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
    // The onboard LED needs a low voltage to be turned on due to circuit connection.
    led.write(true)
    sleep(ms: 1000)

    // Set a low voltage to turn on the onboard LED.
    led.write(false)
    sleep(ms: 1000)
}
```

## Examples

Before starting to create your project, let's start with these examples to get familiar with library usage.

* [GetStarted](https://docs.madmachine.io/projects/general/getting-started/overview) - get started and learn basic skills
* [SimpleIO](https://docs.madmachine.io/projects/general/simpleio/overview) - dive deeper into the microcontroller world and strengthen your programming skills


## Preparation

We created the MadMachine extension for Visual Studio Code for easier usage. Please install and configure it following [this instruction](https://docs.madmachine.io/overview/getting-started/software-prerequisite).

Besides, if you are more comfortable with the command line, welcome to try [mm sdk](https://github.com/madmachineio/mm-sdk).
