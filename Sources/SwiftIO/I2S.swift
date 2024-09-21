//=== I2S.swift --------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 05/07/2023
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO

/// I2S (inter-integrated circuit sound) is a serial communication protocol
/// that is designed specifically for digital audio data.
///
/// The I2S class allows the board to send and receive audio data as a master
/// device. Make sure that the sample rate and sample bits match the audio.
///
///  ```swift
/// // Initialize an I2S interface.
/// let i2c = I2S(Id.I2S0, rate: 44_100, bits: 16)
/// ```
public final class I2S {
  private let id: Int32
  @_spi(SwiftIOPrivate) public let obj: UnsafeMutableRawPointer

  private var config = swift_i2s_cfg_t()

  private var mode: Mode {
    willSet {
      switch newValue {
      case .philips:
        config.mode = SWIFT_I2S_MODE_PHILIPS
      case .rightJustified:
        config.mode = SWIFT_I2S_MODE_RIGHT_JUSTIFIED
      case .leftJustified:
        config.mode = SWIFT_I2S_MODE_LEFT_JUSTIFIED
      }
    }
  }

  private var configOptions: ConfigOptions {
    get {
      ConfigOptions(rawValue: config.options)
    }
    set {
      config.options = newValue.rawValue
    }
  }

  private var sampleBits: Int {
    get {
      Int(config.sample_bits)
    }
    set {
      config.sample_bits = Int32(newValue)
    }
  }

  private var sampleRate: Int {
    get {
      Int(config.sample_rate)
    }
    set {
      config.sample_rate = Int32(newValue)
    }
  }

  private var timeout: Int {
    get {
      Int(config.timeout)
    }
    set {
      config.timeout = Int32(newValue)
    }
  }

  /// The sample bits for the I2S data transmission, which refers to the
  /// number of bits used to represent each sample.
  ///
  /// The supported sample bits are 8, 16, 24, 32.
  public let supportedSampleBits: Set = [
    8, 16, 24, 32,
  ]

  /// The sample rate for the audio data, which defines how many times the
  /// signal is sampled in one second.
  ///
  /// The supported sample rates are
  /// 8_000, 11_025, 12_000, 16_000,
  /// 22_050, 24_000, 32_000, 44_100,
  /// 48_000, 96_000, 192_000, 384_000.
  public let supportedSampleRate: Set = [
    8_000,
    11_025,
    12_000,
    16_000,
    22_050,
    24_000,
    32_000,
    44_100,
    48_000,
    96_000,
    192_000,
    384_000,
  ]

  /// Initializes an I2S interface with the specified sample rate and sample bits.
  /// - Parameters:
  ///   - idName: **REQUIRED** Name/label for a physical pin which is associated
  ///   with the I2S peripheral. See Id for the board in
  ///   [MadBoards](https://github.com/madmachineio/MadBoards) library for reference.
  ///   - rate: **OPTIONAL** The audio sample rate, 16KHz by default.
  ///   Ensure that it aligns with one of the rates in the ``supportedSampleRate``.
  ///   - bits: **OPTIONAL** The audio sample bit, 16-bit by default.
  ///   Ensure that it aligns with one of the settings in ``supportedSampleBits``.
  ///   - mode: **OPTIONAL** The I2S mode which defines when data is sent,
  ///   `.philips` by default.
  ///   - timeout: **OPTIONAL** Wait time for data transmission.
  public init(
    _ idName: Id,
    rate: Int = 16_000,
    bits: Int = 16,
    mode: Mode = .philips,
    timeout: Int = Int(SWIFT_FOREVER)
  ) {
    guard supportedSampleRate.contains(rate) else {
      print("error: The specified sampleRate \(rate) is not supported!")
      fatalError()
    }
    guard supportedSampleBits.contains(bits) else {
      print("error: The specified sampleBits \(bits) is not supported!")
      fatalError()
    }

    self.id = idName.rawValue
    if let ptr = swifthal_i2s_open(id) {
      obj = ptr
    } else {
      print("error: I2S \(id) initialization failed!")
      fatalError()
    }

    self.mode = mode

    config.sample_bits = Int32(bits)
    config.sample_rate = Int32(rate)
    config.timeout = Int32(timeout)

    switch mode {
    case .philips:
      config.mode = SWIFT_I2S_MODE_PHILIPS
    case .rightJustified:
      config.mode = SWIFT_I2S_MODE_RIGHT_JUSTIFIED
    case .leftJustified:
      config.mode = SWIFT_I2S_MODE_LEFT_JUSTIFIED
    }

    config.channels = 2
    configOptions = ConfigOptions.defaultConfig

    swifthal_i2s_config_set(obj, SWIFT_I2S_DIR_TX, &config)
    swifthal_i2s_trigger(obj, SWIFT_I2S_DIR_TX, SWIFT_I2S_TRIGGER_START)
  }

  deinit {
    swifthal_i2s_close(obj)
  }

  /// Set audio sample rate and bit.
  /// - Parameters:
  ///   - rate: The audio sample rate. Ensure that it aligns with one of the
  ///   rates in the ``supportedSampleRate``.
  ///   - bits: The audio sample bit. Ensure that it aligns
  ///   with one of the settings in ``supportedSampleBits``.
  /// - Returns: Whether the configration succeeds. If not, it returns the
  /// specific error.
  @discardableResult
  public func setSampleProperty(
    rate: Int, bits: Int
  ) -> Result<(), Errno> {
    guard supportedSampleRate.contains(rate) else {
      print("error: The specified sampleRate \(rate) is not supported!")
      fatalError()
    }
    guard supportedSampleBits.contains(bits) else {
      print("error: The specified sampleBits \(bits) is not supported!")
      fatalError()
    }

    self.sampleBits = bits
    self.sampleRate = rate

    let result = nothingOrErrno(
      swifthal_i2s_config_set(obj, SWIFT_I2S_DIR_TX, &config)
    )

    if case .failure(let err) = result {
      //print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
      let errDescription = err.description
      print("error: \(self).\(#function) line \(#line) -> " + errDescription)
    }
    return result
  }

  /// Write an array of data to audio device.
  /// - Parameters:
  ///   - data: The audio data stored in a UInt8 array.
  ///   - count: The count of data to be sent. If nil, it equals the count of
  ///   elements in `data`.
  /// - Returns: The result of the data transmission.
  @discardableResult
  public func write(
    _ data: [UInt8],
    count: Int? = nil
  ) -> Result<Int, Errno> {
    var writeLength = 0
    let validateResult = validateLength(data, count: count, length: &writeLength)
    var writeResult: Result<Int, Errno> = .success(0)

    if case .success = validateResult {
      writeResult = valueOrErrno(
        data.withUnsafeBytes { pointer in
          swifthal_i2s_write(obj, pointer.baseAddress, writeLength)
        }
      )
    } else {
      return .failure(Errno.invalidArgument)
    }

    if case .failure(let err) = writeResult {
      //print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
      let errDescription = err.description
      print("error: \(self).\(#function) line \(#line) -> " + errDescription)
    }

    return writeResult
  }

  /// Write an array of binary integers to audio device.
  /// - Parameters:
  ///   - data: The audio data stored in the specified format.
  ///   - count: The count of data to be sent. If nil, it equals the count of
  ///   elements in `data`.
  /// - Returns: The result of the data transmission.
  @discardableResult
  public func write<Element: BinaryInteger>(_ data: [Element], count: Int? = nil) -> Result<
    Int, Errno
  > {
    var writeLength = 0
    let validateResult = validateLength(data, count: count, length: &writeLength)
    var writeResult: Result<Int, Errno> = .success(0)

    if case .success = validateResult {
      writeResult = valueOrErrno(
        data.withUnsafeBytes { pointer in
          swifthal_i2s_write(obj, pointer.baseAddress, writeLength)
        }
      )
    } else {
      return .failure(Errno.invalidArgument)
    }

    if case .failure(let err) = writeResult {
      //print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
      let errDescription = err.description
      print("error: \(self).\(#function) line \(#line) -> " + errDescription)
    }

    return writeResult
  }
}

extension I2S {
  /// The Mode enum inludes the ways that determine when the data is transmitted.
  public enum Mode {
    case philips
    case rightJustified
    case leftJustified
  }

  public enum Direction {
    case rx
    case tx
    case both
  }

  public enum Trigger {
    case start
    case stop
    case drain
    case drop
    case prepare
  }

  public enum State {
    case notReady
    case ready
    case running
    case stopping
    case error
  }

  public struct DataFormat: OptionSet, Sendable {
    public let rawValue: Int32

    public init(rawValue: Int32) {
      self.rawValue = rawValue
    }

    static let dataOrderMSB = DataFormat(rawValue: Int32(SWIFT_I2S_DATA_ORDER_MSB))
    static let dataOrderLSB = DataFormat(rawValue: Int32(SWIFT_I2S_DATA_ORDER_LSB))

    static let invertBitClock = DataFormat(rawValue: Int32(SWIFT_I2S_BIT_CLK_INV))
    static let invertFrameClock = DataFormat(rawValue: Int32(SWIFT_I2S_FRAME_CLK_INV))

    static let defaultDataFormat: DataFormat = [.dataOrderMSB]
  }

  public struct ConfigOptions: OptionSet, Sendable {
    public let rawValue: Int32

    public init(rawValue: Int32) {
      self.rawValue = rawValue
    }

    static let continuouslyClock = ConfigOptions(rawValue: Int32(SWIFT_I2S_BIT_CLK_CONT))
    static let gatedClock = ConfigOptions(rawValue: Int32(SWIFT_I2S_BIT_CLK_GATED))

    static let bitClockMaster = ConfigOptions(rawValue: Int32(SWIFT_I2S_BIT_CLK_MASTER))
    static let bitClockSlave = ConfigOptions(rawValue: Int32(SWIFT_I2S_BIT_CLK_SLAVE))

    static let frameClockMaster = ConfigOptions(rawValue: Int32(SWIFT_I2S_FRAME_CLK_MASTER))
    static let frameClockSlave = ConfigOptions(rawValue: Int32(SWIFT_I2S_FRAME_CLK_SLAVE))

    static let defaultConfig: ConfigOptions = [.gatedClock, bitClockMaster, frameClockMaster]
  }
}
