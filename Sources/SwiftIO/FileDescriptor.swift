//=== FileDescriptor.swift ------------------------------------------------===//
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

/**
The FileDescriptor struct is used to perform low-level file operations.

### Example: Open and read an ASCII file

 ```swift
 import SwiftIO

 // Open the file located in "/subDir/hello.txt"
 if let file = try? FileDescriptor.open("/SD:/subDir/hello.txt") {
     //Initialize a buffer to store the reading bytes.
     var buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 10, alignment: 4)

     do {
         // Read bytes into the buffer
         try file.read(into: buffer)

         // Print the reding bytes.
         for i in 0..<buffer.count {
             print(buffer[i])
         }
     } catch {
         print("Unexpected error: \(error).")
     }
 }

 while true {
    sleep(ms: 1000)
 }
 ```

*/

public struct FileDescriptor {

  private let dirEntry: swift_fs_dirent_t
  private let filePointer: UnsafeMutableRawPointer

  private let filePath: FilePath

  /// Size of the file.
  public var size: Int { Int(dirEntry.size) }

  /**
     Open or creates, if does not exist, file.
     > Attention:
     The root directory for the micro SD card is "/SD:/"

     - Parameter path: **REQUIRED** The location of the file to open.
     - Parameter mode: **OPTIONAL** The read and write access to use.
     - Parameter options: **OPTIONAL** The behavior for opening the file.
     - Returns: A file descriptor for the open file.
     */
  public static func open(
    _ path: String,
    _ mode: FileDescriptor.AccessMode = .readWrite,
    options: FileDescriptor.OpenOptions = FileDescriptor.OpenOptions()
  ) throws -> FileDescriptor {
    let _filePath = FilePath(path)
    var _dirEntry = swift_fs_dirent_t()

    var _filePointer: UnsafeMutableRawPointer? = nil
    let flags: UInt8 = mode.rawValue | options.rawValue

    var result = nothingOrErrno(
      swifthal_fs_stat(_filePath.bytes, &_dirEntry)
    )
    switch result {
    case .success:
      if _dirEntry.type == SWIFT_FS_DIR_ENTRY_DIR {
        throw Errno.notSupported
      }
    case .failure(let err):
      if err == Errno.noSuchFileOrDirectory && (options.contains(.append) || options.contains(.create)) {
        break
      }
      throw err
    }

    result = nothingOrErrno(
      swifthal_fs_open(&_filePointer, _filePath.bytes, flags)
    )

    if case .failure(let err) = result {
      throw err
    }

    return FileDescriptor(dirEntry: _dirEntry, filePointer: _filePointer!, filePath: _filePath)
  }

  /**
     Flushes the associated stream and closes the file.

     */
  public func close() throws {
    let result = nothingOrErrno(
      swifthal_fs_close(filePointer)
    )

    if case .failure(let err) = result {
      throw err
    }
  }

  /**
     Get current file position.
     - Returns: Current position in file.
     */
  public func tell() throws -> Int {
    let result = valueOrErrno(
      swifthal_fs_tell(filePointer)
    )
    switch result {
    case .success(let value):
      return value
    case .failure(let err):
      throw err
    }
  }

  /**
     Reads bytes at the current file offset into a buffer.
     - Parameter buffer: **REQUIRED** The region of memory to read into.
     - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The bytes successfully read.
     */
  @discardableResult
  public func read(
    into buffer: UnsafeMutableRawBufferPointer,
    count: Int? = nil
  ) throws -> Int {
    let length: Int

    if let count = count {
      length = min(count, buffer.count)
    } else {
      length = buffer.count
    }

    let readResult = valueOrErrno(
      swifthal_fs_read(filePointer, buffer.baseAddress!, length)
    )

    switch readResult {
    case .success(let value):
      return value
    case .failure(let err):
      throw err
    }
  }

  /**
     Reads bytes at the specified offset into a buffer.
     - Parameter offset: **REQUIRED** The file offset where reading begins.
     - Parameter buffer: **REQUIRED** Te region of memory to read into.
     - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The bytes successfully read.
     */
  @discardableResult
  public func read(
    fromAbsoluteOffest offset: Int, into buffer: UnsafeMutableRawBufferPointer, count: Int? = nil
  ) throws -> Int {
    let length: Int

    if let count = count {
      length = min(count, buffer.count)
    } else {
      length = buffer.count
    }
    let seekResult = nothingOrErrno(
      swifthal_fs_seek(filePointer, offset, SeekOrigin.start.rawValue)
    )
    if case .failure(let err) = seekResult {
      throw err
    }

    let readResult = valueOrErrno(
      swifthal_fs_read(filePointer, buffer.baseAddress!, length)
    )

    switch readResult {
    case .success(let value):
      return value
    case .failure(let err):
      throw err
    }
  }

  /**
     Reads bytes at the current file offset into a buffer.
     - Parameter buffer: **REQUIRED** Te region of memory to read into.
     - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The bytes successfully read.
     */
  @discardableResult
  public func read(into buffer: inout [UInt8], count: Int? = nil) throws -> Int {
    let length: Int

    if let count = count {
      length = min(count, buffer.count)
    } else {
      length = buffer.count
    }

    var readResult: Result<Int, Errno> = .success(0)
    buffer.withUnsafeMutableBytes { bufferPointer in
      readResult = valueOrErrno(
        swifthal_fs_read(filePointer, bufferPointer.baseAddress, length)
      )
    }
    switch readResult {
    case .success(let value):
      return value
    case .failure(let err):
      throw err
    }
  }

  /**
     Reads bytes at the specified offset into a buffer.
     - Parameter offset: **REQUIRED** The file offset where reading begins.
     - Parameter buffer: **REQUIRED** Te region of memory to read into.
     - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The bytes successfully read.
     */
  @discardableResult
  public func read(
    fromAbsoluteOffest offset: Int,
    into buffer: inout [UInt8], count: Int? = nil
  ) throws -> Int {
    let length: Int

    if let count = count {
      length = min(count, buffer.count)
    } else {
      length = buffer.count
    }
    let seekResult = nothingOrErrno(
      swifthal_fs_seek(filePointer, offset, SeekOrigin.start.rawValue)
    )
    if case .failure(let err) = seekResult {
      throw err
    }

    var readResult: Result<Int, Errno> = .success(0)
    buffer.withUnsafeMutableBytes { bufferPointer in
      readResult = valueOrErrno(
        swifthal_fs_read(filePointer, bufferPointer.baseAddress, length)
      )
    }
    switch readResult {
    case .success(let value):
      return value
    case .failure(let err):
      throw err
    }
  }

  /**
     Repositions the offset for the given file descriptor.
     - Parameter offset: **REQUIRED** The new offset for the file descriptor.
     - Parameter whence: **OPTIONAL** The origin of the new offset.

     - Returns: The file’s offset location, in bytes from the beginning of the file.
     */
  @discardableResult
  public func seek(offset: Int, from whence: SeekOrigin = .start) throws -> Int {
    let seekResult = valueOrErrno(
      swifthal_fs_seek(filePointer, offset, whence.rawValue)
    )
    switch seekResult {
    case .success(let value):
      return value
    case .failure(let err):
      throw err
    }
  }

  /**
     Writes the contents of a string at the current file offset.
      - Parameter string: **REQUIRED** The string being written.

     - Returns: The number of bytes that were written.
     */
  @discardableResult
  public func write(_ string: String) throws -> Int {
    let data = string.utf8CString
    let size = data.count - 1

    var writeResult: Result<Int, Errno> = .success(0)
    data.withUnsafeBytes { dataPointer in
      writeResult = valueOrErrno(
        swifthal_fs_write(filePointer, dataPointer.baseAddress, size)
      )
    }
    switch writeResult {
    case .success(let value):
      return value
    case .failure(let err):
      throw err
    }
  }

  /**
     Writes the contents of a buffer at the current file offset.
      - Parameter buffer: **REQUIRED** The region of memory that contains the
        data being written.
      - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The number of bytes that were written.
     */
  @discardableResult
  public func write(_ buffer: UnsafeRawBufferPointer, count: Int? = nil) throws -> Int {
    let length: Int

    if let count = count {
      length = min(count, buffer.count)
    } else {
      length = buffer.count
    }

    let writeResult = valueOrErrno(
      swifthal_fs_write(filePointer, buffer.baseAddress!, length)
    )

    switch writeResult {
    case .success(let value):
      return value
    case .failure(let err):
      throw err
    }
  }

  /**
     Writes the contents of a buffer at the specified offset.
      - Parameter offset: **REQUIRED** The file offset where writing begins.
      - Parameter buffer: **REQUIRED** Te region of memory that contains the
        data being written.
      - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The number of bytes that were written.
     */
  @discardableResult
  public func write(
    toAbsoluteOffset offset: Int,
    _ buffer: UnsafeRawBufferPointer, count: Int? = nil
  ) throws -> Int {
    let length: Int

    if let count = count {
      length = min(count, buffer.count)
    } else {
      length = buffer.count
    }

    let seekResult = nothingOrErrno(
      swifthal_fs_seek(filePointer, offset, SeekOrigin.start.rawValue)
    )
    if case .failure(let err) = seekResult {
      throw err
    }

    let writeResult = valueOrErrno(
      swifthal_fs_write(filePointer, buffer.baseAddress!, length)
    )
    switch writeResult {
    case .success(let value):
      return value
    case .failure(let err):
      throw err
    }
  }

  /**
     Writes the contents of a buffer at the current file offset.
      - Parameter buffer: **REQUIRED** The region of memory that contains the
        data being written.
      - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The number of bytes that were written.
     */
  @discardableResult
  public func write(_ buffer: [UInt8], count: Int? = nil) throws -> Int {
    let length: Int

    if let count = count {
      length = min(count, buffer.count)
    } else {
      length = buffer.count
    }

    var writeResult: Result<Int, Errno> = .success(0)
    buffer.withUnsafeBytes { bufferPointer in
      writeResult = valueOrErrno(
        swifthal_fs_write(filePointer, bufferPointer.baseAddress, length)
      )
    }

    switch writeResult {
    case .success(let value):
      return value
    case .failure(let err):
      throw err
    }
  }

  /**
     Writes the contents of a buffer at the specified offset.
      - Parameter offset: **REQUIRED** The file offset where writing begins.
      - Parameter buffer: **REQUIRED** Te region of memory that contains the
        data being written.
      - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The number of bytes that were written.
     */
  @discardableResult
  public func write(
    toAbsoluteOffset offset: Int,
    _ buffer: [UInt8], count: Int? = nil
  ) throws -> Int {
    let length: Int

    if let count = count {
      length = min(count, buffer.count)
    } else {
      length = buffer.count
    }

    let seekResult = nothingOrErrno(
      swifthal_fs_seek(filePointer, offset, SeekOrigin.start.rawValue)
    )
    if case .failure(let err) = seekResult {
      throw err
    }

    var writeResult: Result<Int, Errno> = .success(0)
    buffer.withUnsafeBytes { bufferPointer in
      writeResult = valueOrErrno(
        swifthal_fs_write(filePointer, bufferPointer.baseAddress, length)
      )
    }

    switch writeResult {
    case .success(let value):
      return value
    case .failure(let err):
      throw err
    }
  }

  /**
     Flushes any cached write of an open file.
     > Attention:
     This method can be used to flush the cache of an open file. This can be
     called to ensure data gets written to the storage media immediately.
     This may be done to avoid data loss if power is removed unexpectedly.
     Note that closing a file will cause caches to be flushed correctly
     so it needs not be called if the file is being closed.
     */
  public func sync() throws {
    let result = nothingOrErrno(
      swifthal_fs_sync(filePointer)
    )
    if case .failure(let err) = result {
      throw err
    }
  }
}

/// A null-terminated sequence of bytes that represents a location in the file system.
struct FilePath {
  internal var bytes: [CChar]
  private(set) var description: String = ""

  public var length: Int {
    bytes.count - 1
  }

  /**
     Creates a file path from a string.
      - Parameter string: **REQUIRED** A string whose ASCII contents to use
        as the contents of the path.
     */
  init(_ string: String) {
    description = string
    bytes = [CChar](string.utf8CString)
    //print(bytes)
  }

}

extension FileDescriptor {

  /// The desired read and write access for a newly opened file.
  public struct AccessMode: RawRepresentable {
    public var rawValue: UInt8

    public init(rawValue: UInt8) { self.rawValue = rawValue }

    /// Opens the file for reading only.
    public static var readOnly: AccessMode {
      AccessMode(rawValue: UInt8(SWIFT_FS_O_READ))
    }
    /// Opens the file for writing only.
    public static var writeOnly: AccessMode {
      AccessMode(rawValue: UInt8(SWIFT_FS_O_WRITE))
    }
    /// Opens the file for reading and writing.
    public static var readWrite: AccessMode {
      AccessMode(rawValue: UInt8(SWIFT_FS_O_RDWR))
    }

  }

  /// Options that specify behavior for a newly-opened file.
  public struct OpenOptions: OptionSet {
    public var rawValue: UInt8

    public init(rawValue: UInt8) { self.rawValue = rawValue }

    /// Indicates that opening the file creates the file if it doesn’t exist.
    public static var create: OpenOptions { OpenOptions(rawValue: UInt8(SWIFT_FS_O_CREATE)) }
    /// Indicates that each write operation appends to the file.
    public static var append: OpenOptions { OpenOptions(rawValue: UInt8(SWIFT_FS_O_APPEND)) }
  }

  /**
     Options for specifying what a file descriptor's offset is relative to.

     */
  public struct SeekOrigin: RawRepresentable {
    public var rawValue: Int32

    public init(rawValue: Int32) { self.rawValue = rawValue }

    /// Indicates that the offset should be set to the specified value.
    public static var start: SeekOrigin {
      SeekOrigin(rawValue: SWIFT_FS_SEEK_SET)
    }
    /// Indicates that the offset should be set to the specified number of
    /// bytes after the current location.
    public static var current: SeekOrigin {
      SeekOrigin(rawValue: SWIFT_FS_SEEK_CUR)
    }
    /// Indicates that the offset should be set to the size of the file plus
    /// the specified number of bytes.
    public static var end: SeekOrigin {
      SeekOrigin(rawValue: SWIFT_FS_SEEK_END)
    }
  }
}
