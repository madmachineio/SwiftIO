//=== DigitalIn.swift -----------------------------------------------------===//
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

/// The DigitalIn class is intended to detect the state of a digital input pin,
/// either true or false.
///
/// You need to initialize a pin before reading input. A physical pin may be connected
/// to various internal peripherals and thus serve multiple functionalities.
/// You need to identify the specific pin using its id and specify the pin's
/// functionality before using it.
///
/// - `DigitalIn` specifies the pin's usage.
/// - `Id.D0` defines which pin is used. You may refer to the board's pinout
/// which shows all pins and their corresponding functions in a diagram.
///
/// ```swift
/// let pin = DigitalIn(Id.D0)
/// ```
///
///
/// ### Example: Read and print the input value on a digital input pin.
///
/// ```swift
/// // Import the SwiftIO to use the related board functions.
/// import SwiftIO
/// // Import the MadBoard to decide which pin is used for the specific function.
/// import MadBoard
///
/// // Initialize a DigitalIn to the digital pin D0.
/// let pin = DigitalIn(Id.D0)
///
/// // Read and print the input value every 1 second.
/// while true {
///     var value = pin.read()
///     print("The input value is \(value)")
///     sleep(ms: 1000)
/// }
/// ```
public final class DigitalIn {
  private let id: Int32
  @_spi(SwiftIOPrivate) public let obj: UnsafeMutableRawPointer

  private let direction: swift_gpio_direction_t = SWIFT_GPIO_DIRECTION_IN

  private var modeRawValue: swift_gpio_mode_t

  /// The current input mode: `.pullUp`, `.pullDown` or `.pullNone`.
  public private(set) var mode: Mode {
    willSet {
      modeRawValue = DigitalIn.getModeRawValue(newValue)
    }
  }

  private var interruptModeRawValue: swift_gpio_int_mode_t

  /// The current interrupt mode: `.rising`, `falling` or `bothEdge`.
  public private(set) var interruptMode: InterruptMode {
    willSet {
      interruptModeRawValue = DigitalIn.getInterruptModeRawValue(
        newValue
      )
    }
  }
  private var interruptState: InterruptState = .disable

  private var callback: (() -> Void)?

  /// Initializes a DigitalIn to a specified pin.
  ///
  /// The id of the pin is required to initialize a digital input pin. It can be
  /// any pin with that function, D0, D1, D2... The prefix D means Digital.
  /// If you connect a device to the pin D10, you should initialize the pin
  /// using `Id.D10`.
  ///
  /// All ids for different boards are in the
  /// [MadBoards](https://github.com/madmachineio/MadBoards) library.
  /// Take pin 0 for example:
  ///
  /// ```swift
  /// // The simplest way to initialize a pin D0, with other parameters set to default.
  /// let pin = DigitalIn(Id.D0)
  /// ```
  /// If the pin needs a pull-up resistor, you can initialize the pin as below:
  ///
  /// ```swift
  /// // Initialize the pin D0 in pullUp mode.
  /// let pin = DigitalIn(Id.D0, mode: .pullUp)
  /// ```
  ///
  /// - Parameters:
  ///   - idName: **REQUIRED** Name/label for a physical pin which is
  ///   associated with the GPIO peripheral. See Id for the board in
  ///   [MadBoards](https://github.com/madmachineio/MadBoards) library for reference.
  ///   - mode: **OPTIONAL** The input mode which defines pull-up and pull-down
  ///   resistor, `.pullDown` by default.
  public init(
    _ idName: Id,
    mode: Mode = .pullDown
  ) {
    self.id = idName.rawValue
    self.mode = mode
    self.modeRawValue = DigitalIn.getModeRawValue(mode)
    self.interruptMode = .falling
    self.interruptModeRawValue = DigitalIn.getInterruptModeRawValue(
      .falling
    )

    guard let ptr = swifthal_gpio_open(id, direction, modeRawValue) else {
      print("error: DigitalIn \(id) init failed!")
      fatalError()
    }
    obj = ptr
  }

  deinit {
    if callback != nil {
      removeInterrupt()
    }
    swifthal_gpio_close(obj)
  }

  /**
     Gets the configuration of the internal pull-up and pull-down resistor on a
     specified input pin.

     - Returns: The current input mode: `.pullUp`, `.pullDown` or `.pullNone`.
     */
  public func getMode() -> Mode {
    return mode
  }

  /// Sets the input mode, which means the pull-up and pull-down resistor pull-up
  /// and pull-down resistor.
  /// - Parameter mode: The input mode: `.pullUp`, `.pullDown` or `.pullNone`.
  /// - Returns: Whether the configuration succeeds. If it fails, it returns
  /// the specific error.
  @discardableResult
  public func setMode(_ mode: Mode) -> Result<(), Errno> {
    let oldMode = self.mode
    self.mode = mode

    let result = nothingOrErrno(
      swifthal_gpio_config(obj, direction, modeRawValue)
    )

    if case .failure(let err) = result {
      //print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
      let errDescription = err.description
      print("error: \(self).\(#function) line \(#line) -> " + errDescription)
      self.mode = oldMode
    }

    return result
  }

  /**
     Reads value from a digital input pin.

     - Attention: Dependind on the hardware, the internal pull resister may be
     very weak. **Don't** just rely on the pull resister for reading the value.
     **Especially** when you just changed the input mode, the internal pad needs
     some time to charge or discharge through the pull resister!

     - Returns: `true` or `false` of the logic value.
     */
  public func read() -> Bool {
    let result = valueOrErrno(
      swifthal_gpio_get(obj)
    )
    switch result {
    case .success(let value):
      return value == 1
    case .failure(let err):
      //print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
      let errDescription = err.description
      print("error: \(self).\(#function) line \(#line) -> " + errDescription)
      return false
    }
  }

  /**
     Adds a callback function to a specified input pin. It sets interrupt by
     detecting the changes of the signal.

     Once the risng or falling edge is detected, the interrupt triggers.
     The processor will suspend the normal execution to execute the designated
     task, called ISR.
     After that, it will return to where it stopped and continue the
     previous operation.

     - Important: The ISR should be able to finish in a very short time,
     usually in nanoseconds, like changing a number or a boolean value.
     Besides, changing digital output runs extremely quickly, so it also works.
     Printing a value usually takes several milliseconds and should be avoided.

     ### Example: Toggle the LED once interrupt triggers

     ```swift
     // Import the SwiftIO to use the related board functions.
     import SwiftIO
     // Import the MadBoard to decide which pin is used for the specific function.
     import MadBoard

     // Initialize an input pin D0 and an output pin for the onboard LED.
     let button = DigitalIn(Id.D0)
     let led = DigitalOut(Id.BLUE)

     // Define a new function used to toggle the LED.
     func toggleLed() {
         led.toggle()
     }

     // Set the interrupt to detect the rising edge.
     // Once detected, the LED will change its state.
     button.setInterrupt(.rising, callback: toggleLed)

     // Sleep if the interrupt hasn't been triggered.
     while true {
         sleep(ms: 1000)
     }
     ```
     **or**

     ```swift
     import SwiftIO
     import MadBoard

     let button = DigitalIn(Id.D0)
     let led = DigitalOut(Id.BLUE)

     button.setInterrupt(.rising) {
         led.toggle()
     }

     while true {
         sleep(ms: 1000)
     }
     ```

     - Parameter mode : The interrupt mode to detect rising or falling edge.
     - Parameter enable : Whether to enable the interrupt.
     - Parameter callback : The task to be executed when interrupt happens.
     It should be a void function without a return value.
     - Returns: Whether the configuration succeeds. If it fails, it returns
     the specific error.

     */
  @discardableResult
  public func setInterrupt(
    _ mode: InterruptMode,
    enable: Bool = true,
    callback: @escaping () -> Void
  ) -> Result<(), Errno> {
    let oldInterruptMode = interruptMode
    interruptMode = mode

    if self.callback != nil {
      removeInterrupt()
    }
    self.callback = callback

    var result = nothingOrErrno(
      swifthal_gpio_interrupt_config(obj, interruptModeRawValue)
    )
    if case .failure(let err) = result {
      //print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
      let errDescription = err.description
      print("error: \(self).\(#function) line \(#line) -> " + errDescription)
      interruptMode = oldInterruptMode
      return result
    }

    result = nothingOrErrno(
      swifthal_gpio_interrupt_callback_install(
        obj, getClassPointer(self)
      ) { (ptr) -> Void in
        let mySelf = Unmanaged<DigitalIn>.fromOpaque(ptr!).takeUnretainedValue()
        mySelf.callback!()
      }
    )
    if case .failure(let err) = result {
      //print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
      let errDescription = err.description
      print("error: \(self).\(#function) line \(#line) -> " + errDescription)
      return result
    }

    if enable {
      result = enableInterrupt()
      if case .failure(let err) = result {
        //print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        let errDescription = err.description
        print("error: \(self).\(#function) line \(#line) -> " + errDescription)
      }
    }

    return result
  }

  /// Enables the interrupt.
  /// - Returns: Whether the configuration succeeds. If it fails, it returns
  /// the specific error.
  @discardableResult
  public func enableInterrupt() -> Result<(), Errno> {
    guard callback != nil else {
      let err = Errno.resourceBusy
      //print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
      let errDescription = err.description
      print("error: \(self).\(#function) line \(#line) -> " + errDescription)
      return .failure(err)
    }

    let result = nothingOrErrno(
      swifthal_gpio_interrupt_enable(obj)
    )
    if case .success = result {
      interruptState = .enable
    }
    return result
  }

  /// Disables the interrupt until you enable it.
  /// - Returns: Whether the configuration succeeds. If it fails, it returns
  /// the specific error.
  @discardableResult
  public func disableInterrupt() -> Result<(), Errno> {
    let result = nothingOrErrno(
      swifthal_gpio_interrupt_disable(obj)
    )
    if case .success = result {
      interruptState = .disable
    }
    return result
  }

  /**
     Checks whether the interrupt is enabled.
     - Returns: The interrupt state: `.enable` or `.disable`.
     */
  public func getInterruptState() -> InterruptState {
    return interruptState
  }

  /// Removes the interrupt.
  /// - Returns: Whether the configuration succeeds. If it fails, it returns
  /// the specific error.
  @discardableResult
  public func removeInterrupt() -> Result<(), Errno> {
    if interruptState != .disable {
      disableInterrupt()
    }

    let result = nothingOrErrno(
      swifthal_gpio_interrupt_callback_uninstall(obj)
    )
    callback = nil
    return result
  }
}

extension DigitalIn {
  /**
     The digital input mode sets the pull resistors connected to a pin.

     There are internal pull resistors for all digital input pins. You can set
     the mode to decide how they are connected.
     - pullUp: the internal pull-up resistor is set.
     - pullDown: the internal pull-down resistor is set.
     - pullNone: neither resistors is used for the pin.

     It can change the default state (high, low or floating) of a pin by using
     the pull resistors.

     - Important: For the **SwiftIO board**, the pins **D26 to D37** are connected separately to an external 10kΩ pull-down resistor on the board. So even if they are changed to pullUp, the output voltage of these pins may be still low.
     For the **SwiftIO Micro**, the pin **D32 to D43** are connected to an 10kΩ pull-down resistor, the pin **DL** are connected to 10kΩ pull-up resistor.
     */
  public enum Mode {
    case pullDown, pullUp, pullNone
  }

  internal static func getModeRawValue(_ mode: Mode) -> swift_gpio_mode_t {
    switch mode {
    case .pullDown:
      return SWIFT_GPIO_MODE_PULL_DOWN
    case .pullUp:
      return SWIFT_GPIO_MODE_PULL_UP
    case .pullNone:
      return SWIFT_GPIO_MODE_PULL_NONE
    }
  }

  /**
     Determines the event to raise an interrupt: rising edge, falling edge or both.

     There are three options:
     - A falling edge is the transition of a digital input signal from high to low.
     - A rising edge is the transition of a digital input signal from low to high.
     - Both edges means as long as the signal changes, an interrupt happens.

     */
  public enum InterruptMode {
    case rising, falling, bothEdge
  }

  private static func getInterruptModeRawValue(
    _ mode: InterruptMode
  ) -> swift_gpio_int_mode_t {
    switch mode {
    case .rising:
      return SWIFT_GPIO_INT_MODE_RISING_EDGE
    case .falling:
      return SWIFT_GPIO_INT_MODE_FALLING_EDGE
    case .bothEdge:
      return SWIFT_GPIO_INT_MODE_BOTH_EDGE
    }
  }

  /// Determines whether the interrupt is enabled and will occur.
  public enum InterruptState {
    case disable, enable
  }
}
