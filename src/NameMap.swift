public enum DigitalIOId: UInt8 {
    case D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D16,
         D17, D18, D19, D20, D21, D22, D23, D24, D25, D26, D27, D28, D29, D30, D31,
         D32, D33, D34, D35, D36, D37, D38, D39, D40, D41, D42, D43, D44, D45,
         RED, GREEN, BLUE
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
    case rising = 1, falling, bothEdge
}

public enum DigitalInCallbackState: UInt8 {
    case disable, enable
}














public enum UARTId: UInt8 {
    case UART0 = 0, UART1, UART2, UART3
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




public enum PWMOutId: UInt8 {
    case PWM0, PWM1, PWM2, PWM3, PWM4, PWM5, PWM6, PWM7, PWM8, PWM9, PWM10, PWM11, PWM12, PWM13
}

public enum AnalogInId: UInt8 {
    case A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11
}
