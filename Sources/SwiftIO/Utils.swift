//=== Utils.swift ---------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 12/08/2021
// Updated: 12/08/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CNewlib

@inline(__always)
internal func getClassPointer<T: AnyObject>(_ obj: T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

internal func system_strerror(_ __errnum: Int32) -> UnsafeMutablePointer<Int8>! {
  strerror(__errnum)
}

@inline(__always)
internal func valueOrErrno<D>(
    _ data: D, _ ret: CInt
) -> Result<D, Errno> {
  ret < 0 ? .failure(Errno(ret)) : .success(data)
}

@inline(__always)
internal func valueOrErrno(
    _ ret: CInt
) -> Result<Int, Errno> {
  ret < 0 ? .failure(Errno(ret)) : .success(Int(ret))
}

@inline(__always)
internal func nothingOrErrno(
    _ ret: CInt
) -> Result<(), Errno> {
  valueOrErrno(ret).map { _ in () }
}


@inline(__always)
internal func validateLength(_ array: [UInt8], count: Int?, length: inout Int) -> Result<(), Errno> {
    if let count = count {
        if count > array.count || count < 0 {
            return .failure(Errno.invalidArgument)
        } else {
            length = count
        }
    } else {
        length = array.count
    }

    return .success(())
}


@inline(__always)
internal func validateLength(_ buffer: UnsafeMutableBufferPointer<UInt8>, count: Int?, length: inout Int) -> Result<(), Errno> {
    if let count = count {
        if count > buffer.count || count < 0 {
            return .failure(Errno.invalidArgument)
        } else {
            length = count
        }
    } else {
        length = buffer.count
    }

    return .success(())
}



@inline(__always)
internal func validateLength(_ buffer: UnsafeBufferPointer<UInt8>, count: Int?, length: inout Int) -> Result<(), Errno> {
    if let count = count {
        if count > buffer.count || count < 0 {
            return .failure(Errno.invalidArgument)
        } else {
            length = count
        }
    } else {
        length = buffer.count
    }

    return .success(())
}





public enum Endian {
    case big
    case little
}


public extension FixedWidthInteger {
    public func getBytes(endian: Endian = .big) -> [UInt8] {
        let bytes = self.bitWidth / 8
        var result = [UInt8](repeating: 0, count: bytes)

        switch endian {
            case .big:
                for i in 0..<bytes {
                    result[i] = UInt8(truncatingIfNeeded: self >> (i * 8))
                }
            case .little:
                for i in 0..<bytes {
                    result[bytes - 1 - i] = UInt8(truncatingIfNeeded: self >> (i * 8))
                }
        }
        
        return result
    }
}


public extension Array where Element == UInt8 {
    public func getUInt16(from index: Int = 0, endian: Endian = .big) -> UInt16 {
        let msb, lsb: UInt16
        
        switch endian {
            case .big:
                msb = UInt16(self[index]) << 8
                lsb = UInt16(self[index + 1])
            case .little:
                msb = UInt16(self[index + 1]) << 8
                lsb = UInt16(self[index])
        }
        return (msb | lsb)
    }
    
    public func getInt16(from index: Int = 0, endian: Endian = .big) -> Int16 {
        let msb, lsb: Int16
        
        switch endian {
            case .big:
                msb = Int16(self[index]) << 8
                lsb = Int16(self[index + 1])
            case .little:
                msb = Int16(self[index + 1]) << 8
                lsb = Int16(self[index])
        }
        return (msb | lsb)
    }
}