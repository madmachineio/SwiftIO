import CSwiftIO


 public final class I2SOut {
    private let id: Int32
    private let obj: UnsafeMutableRawPointer

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

    private var channel: Channel {
        willSet {
            switch newValue {
                case .stereo:
                config.channel_type = SWIFT_I2S_CHAN_STEREO
                case .monoRight:
                config.channel_type = SWIFT_I2S_CHAN_MONO_RIGHT
                case .monoLeft:
                config.channel_type = SWIFT_I2S_CHAN_MONO_LEFT
            }
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

    public init(_ idName: IdName,
                sampleBits: Int = 16,
                sampleRate: Int = 24_000,
                channel: Channel = .monoLeft,
                mode: Mode = .philips) {
        guard supportedSampleBits.contains(sampleBits) else {
            fatalError("The specified sampleBits \(sampleBits) is not supported!")
        }
        guard supportedSampleBits.contains(sampleRate) else {
            fatalError("The specified sampleRate \(sampleRate) is not supported!")
        }
        self.id = idName.value
        self.channel = channel
        self.mode = mode
        config.sample_bits = Int32(sampleBits)
        config.sample_rate = Int32(sampleRate)
        switch channel {
            case .stereo:
            config.channel_type = SWIFT_I2S_CHAN_STEREO
            case .monoRight:
            config.channel_type = SWIFT_I2S_CHAN_MONO_RIGHT
            case .monoLeft:
            config.channel_type = SWIFT_I2S_CHAN_MONO_LEFT
        }
        switch mode {
            case .philips:
            config.mode = SWIFT_I2S_MODE_PHILIPS
            case .rightJustified:
            config.mode = SWIFT_I2S_MODE_RIGHT_JUSTIFIED
            case .leftJustified:
            config.mode = SWIFT_I2S_MODE_LEFT_JUSTIFIED
        }

        if let ptr = swifthal_i2s_open(id, &config, nil) {
            obj = UnsafeMutableRawPointer(ptr)
        } else {
            fatalError("I2SOut\(idName.value) initialization failed!")
        }
    }

    deinit {
        swifthal_i2s_close(obj)
    }




}

extension I2SOut {
    public enum Mode {
        case philips
        case rightJustified
        case leftJustified
    }

    public enum Channel {
        case stereo
        case monoRight
        case monoLeft
    }
}
