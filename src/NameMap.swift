public enum DigitalIOId: UInt8 {
    case D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D16,
         D17, D18, D19, D20, D21, D22, D23, D24, D25, D26, D27, D28, D29, D30, D31,
         D32, D33, D34, D35, D36, D37, D38, D39, D40, D41, D42, D43, D44, D45, D46
}


public enum DigitalIODirection: UInt8 {
    case output = 1, input
}

public enum DigitalOutMode: UInt8 {
	case pushPull = 1, openDrain
}

public enum DigitalInMode: UInt8 {
	case pullDown = 1, pullUp, pullNone
}

public enum DigitalInCallbackMode: UInt8 {
    case disable = 0, risingEdge, fallingEdge, bothEdge, highLevel, lowLevel
}




public enum RGBLEDColor: Int32 {
	case red = 9, green = 10, blue = 11
}

public enum RGBLEDState: Int32 {
    case on = 0, off = 1
}




public enum I2CId: UInt8 {
    case I2C0 = 0, I2C1
}

public enum I2CSpeed: UInt32 {
    case standard = 100000, fast = 400000, fastPlus = 1000000
}










public enum UARTId: UInt8 {
    case UART0 = 0, UART1
}

public enum UARTParity: UInt8 {
    case none, odd, even
}

public enum UARTStopBits: UInt8 {
    case oneBit, twoBits
}

public enum UARTDataBits: UInt8 {
    case eightBits
}

public enum UARTBufferLength: UInt32 {
    case small = 64, medium = 256, large = 1024
}




public enum TimerType: UInt8 {
    case oneShot, period
}




public enum PWMId: UInt8 {
    case PWM0, PWM1, PWM2, PWM3, PWM4, PWM5
}

public enum AnalogInId: UInt8 {
    case ADC0, ADC1, ADC2, ADC3, ADC4, ADC5, ADC6, ADC7
}
