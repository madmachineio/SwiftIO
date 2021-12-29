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