// public enum Id: Int32, IdName {
//     public var value: Int32 {
//         self.rawValue & Int32(0xFF)
//     }
//     case D0 = 0x0000,
//          D1, D2, D3, D4, D5, D6, D7, D8, D9, D10,
//          D11, D12, D13, D14, D15, D16, D17, D18, D19, D20,
//          D21, D22, D23, D24, D25, D26, D27, D28, D29, D30,
//          D31, D32, D33, D34, D35, RED, GREEN, BLUE

//     case A0 = 0x0100, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13

//     case PWM0A = 0x0200,
//          PWM1A, PWM2B, PWM2A, PWM3B, PWM3A, PWM4A, PWM5A,
//          PWM6A, PWM6B, PWM7A, PWM7B, PWM8A, PWM8B

//     case I2C0 = 0x0300, I2C1

//     case SPI0 = 0x0400, SPI1

//     case UART0 = 0x0500, UART1, UART2

//     case C0 = 0x0600, C1

//     case I2SOut0 = 0x0700
    
//     case I2SIn0 = 0x0800
// }

public extension Id {
  static let D0 = Id(rawValue: 0)
  static let D1 = Id(rawValue: 1)
  static let D2 = Id(rawValue: 2)
  static let D3 = Id(rawValue: 3)
  static let D4 = Id(rawValue: 4)
  static let D5 = Id(rawValue: 5)
  static let D6 = Id(rawValue: 6)
  static let D7 = Id(rawValue: 7)
  static let D8 = Id(rawValue: 8)
  static let D9 = Id(rawValue: 9)

  static let D10 = Id(rawValue: 10)
  static let D11 = Id(rawValue: 11)
  static let D12 = Id(rawValue: 12)
  static let D13 = Id(rawValue: 13)
  static let D14 = Id(rawValue: 14)
  static let D15 = Id(rawValue: 15)
  static let D16 = Id(rawValue: 16)
  static let D17 = Id(rawValue: 17)
  static let D18 = Id(rawValue: 18)
  static let D19 = Id(rawValue: 19)

  static let D20 = Id(rawValue: 20)
  static let D21 = Id(rawValue: 21)
  static let D22 = Id(rawValue: 22)
  static let D23 = Id(rawValue: 23)
  static let D24 = Id(rawValue: 24)
  static let D25 = Id(rawValue: 25)
  static let D26 = Id(rawValue: 26)
  static let D27 = Id(rawValue: 27)
  static let D28 = Id(rawValue: 28)
  static let D29 = Id(rawValue: 29)

  static let D30 = Id(rawValue: 30)
  static let D31 = Id(rawValue: 31)
  static let D32 = Id(rawValue: 32)
  static let D33 = Id(rawValue: 33)
  static let D34 = Id(rawValue: 34)
  static let D35 = Id(rawValue: 35)
  static let D36 = Id(rawValue: 36)
  static let D37 = Id(rawValue: 37)
  static let D38 = Id(rawValue: 38)
  static let D39 = Id(rawValue: 39)

  static let D40 = Id(rawValue: 40)
  static let D41 = Id(rawValue: 41)
  static let D42 = Id(rawValue: 42)
  static let D43 = Id(rawValue: 43)
  static let RED = Id(rawValue: 44)
  static let GREEN = Id(rawValue: 45)
  static let BLUE = Id(rawValue: 46)
  static let DL = Id(rawValue: 47)




  static let A0 = Id(rawValue: 0)
  static let A1 = Id(rawValue: 1)
  static let A2 = Id(rawValue: 2)
  static let A3 = Id(rawValue: 3)
  static let A4 = Id(rawValue: 4)
  static let A5 = Id(rawValue: 5)
  static let A6 = Id(rawValue: 6)
  static let A7 = Id(rawValue: 7)
  static let A8 = Id(rawValue: 8)
  static let A9 = Id(rawValue: 9)

  static let A10 = Id(rawValue: 10)
  static let A11 = Id(rawValue: 11)
  static let A12 = Id(rawValue: 12)
  static let A13 = Id(rawValue: 13)




  static let PWM0A = Id(rawValue: 0)
  static let PWM1A = Id(rawValue: 1)
  static let PWM2B = Id(rawValue: 2)
  static let PWM2A = Id(rawValue: 3)
  static let PWM3B = Id(rawValue: 4)
  static let PWM3A = Id(rawValue: 5)
  static let PWM4A = Id(rawValue: 6)
  static let PWM5A = Id(rawValue: 7)
  static let PWM6A = Id(rawValue: 8)
  static let PWM6B = Id(rawValue: 9)

  static let PWM7A = Id(rawValue: 10)
  static let PWM7B = Id(rawValue: 11)
  static let PWM8A = Id(rawValue: 12)
  static let PWM8B = Id(rawValue: 13)




  static let I2C0 = Id(rawValue: 0)
  static let I2C1 = Id(rawValue: 1)




  static let SPI0 = Id(rawValue: 0)
  static let SPI1 = Id(rawValue: 1)




  static let UART0 = Id(rawValue: 0)
  static let UART1 = Id(rawValue: 1)
  static let UART2 = Id(rawValue: 2)




  static let C0 = Id(rawValue: 0)
  static let C1 = Id(rawValue: 1)




  static let I2S0 = Id(rawValue: 0)
}