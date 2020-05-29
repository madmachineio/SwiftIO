public enum Id: UInt32, IdName {
    case D0 = 0x0000, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D16,
         D17, D18, D19, D20, D21, D22, D23, D24, D25, D26, D27, D28, D29, D30, D31,
         D32, D33, D34, D35, D36, D37, D38, D39, D40, D41, D42, D43, D44, D45,
         RED, GREEN, BLUE
    case A0 = 0x0100, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11
    case PWM0A = 0x0200, PWM1A, PWM2B, PWM2A, PWM3B, PWM3A, PWM4A, PWM5A, PWM6A, PWM6B, PWM7A, PWM7B, PWM8A, PWM8B
    case I2C0 = 0x0300, I2C1
    case SPI0 = 0x0400, SPI1
    case UART0 = 0x0500, UART1, UART2, UART3
    case C0 = 0x0600, C1, C2, C3

    public var number: UInt8 {
        UInt8(self.rawValue & UInt32(0xFF))
    }
}
