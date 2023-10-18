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


 public final class I2S {
    private let id: Int32
    public let obj: UnsafeMutableRawPointer

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

    public let supportedSampleBits: Set = [
        8, 16, 24, 32
    ]

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
        384_000
    ]

    public init(
        _ idName: IdName,
        rate: Int = 16_000,
        bits: Int = 16,
        mode: Mode = .philips,
        timeout: Int = Int(SWIFT_FOREVER)
    ) {
        guard supportedSampleRate.contains(rate) else {
            fatalError("The specified sampleRate \(rate) is not supported!")
        }
        guard supportedSampleBits.contains(bits) else {
            fatalError("The specified sampleBits \(bits) is not supported!")
        }

        self.id = idName.value
        if let ptr = swifthal_i2s_open(id) {
            obj = ptr
        } else {
            fatalError("I2S\(idName.value) initialization failed!")
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

    @discardableResult
    public func setSampleProperty(
        rate: Int, bits: Int
    ) -> Result<(), Errno> {
        guard supportedSampleRate.contains(rate) else {
            fatalError("The specified sampleRate \(rate) is not supported!")
        }
        guard supportedSampleBits.contains(bits) else {
            fatalError("The specified sampleBits \(bits) is not supported!")
        }

        self.sampleBits = bits
        self.sampleRate = rate

        let result = nothingOrErrno(
            swifthal_i2s_config_set(obj, SWIFT_I2S_DIR_TX, &config)
        )

        if case .failure(let err) = result {
           print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }
        return result
    }

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
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return writeResult
    }

     @discardableResult
    public func write<Element: BinaryInteger>(_ data: [Element], count: Int? = nil) -> Result<Int, Errno> {
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
            print("error: \(self).\(#function) line \(#line) -> " + String(describing: err))
        }

        return writeResult
    }
}

extension I2S {
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

    public struct DataFormat: OptionSet {
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

    public struct ConfigOptions: OptionSet {
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
