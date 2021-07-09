import CSwiftIO

/**
The FileDescriptor struct is used to perform low-level file operations.

### Example: Open and read a ASCII file

````
import SwiftIO

// Open the file located in "/subDir/hello.txt"
let file = FileDescriptor.open("/SD:/subDir/hello.txt")

//Initialize a buffer to store the reading bytes.
var buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 10, alignment: 4)

// Read bytes into the buffer
file.read(into: buffer)
 
// Print the reding bytes.
for i in 0..<buffer.count {
    print(buffer[i])
}

while true {
    sleep(ms: 1000)
}
````

*/

public struct FileDescriptor {

    private var dirEntry: swift_fs_dirent_t
    private var filePointer: UnsafeMutableRawPointer

    private(set) var filePath: FilePath

    public var size: Int { Int(dirEntry.size) }

    /**
     Open or creates, if does not exist, file.
     - Parameter path: **REQUIRED** The location of the file to open.
     - Attention:
        The root directory for the micro SD card is "/SD:/"
     */
    public static func open(
        _ path: String,
        _ mode: FileDescriptor.AccessMode = .readWrite,
        options: FileDescriptor.OpenOptions = FileDescriptor.OpenOptions()
    ) -> FileDescriptor {
        let _filePath = FilePath(path)
        var _dirEntry = swift_fs_dirent_t()

        let flags: UInt8 = mode.rawValue | options.rawValue

        if let _filePointer = swifthal_fs_open(_filePath.bytes, flags) {
            swifthal_fs_stat(_filePath.bytes , &_dirEntry)
            if _dirEntry.type == SWIFT_FS_DIR_ENTRY_DIR {
                fatalError("Open directory is not supported!")
            }
            return FileDescriptor(dirEntry: _dirEntry, filePointer: _filePointer, filePath: _filePath)
        } else {
            fatalError("Open file failed!")
        }
    }


    /**
     Flushes the associated stream and closes the file.
     
     */
    public func close() {
        swifthal_fs_close(filePointer)
    }

    /**
     Get current file position.
     - Returns: Current position in file.
     */
    public func tell() -> Int {
        return Int(swifthal_fs_tell(filePointer))
    }

    /**
     Reads bytes at the current file offset into a buffer
     - Parameter buffer: **REQUIRED** The region of memory to read into.
     - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The bytes successfully read.
     */
    public func read(into buffer: UnsafeMutableRawBufferPointer, count: Int? = nil) -> Int {
        let length: Int

        if let count = count {
            length = min(count, buffer.count)
        } else {
            length = buffer.count
        }

        return Int(swifthal_fs_read(filePointer, buffer.baseAddress!, UInt32(length)))
    }

    /**
     Reads bytes at the specified offset into a buffer.
     - Parameter offset: **REQUIRED** The file offset where reading begins.
     - Parameter buffer: **REQUIRED** Te region of memory to read into.
     - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The bytes successfully read.
     */
    public func read(fromAbsoluteOffest offset: Int, into buffer: UnsafeMutableRawBufferPointer, count: Int? = nil) -> Int {
        let length: Int

        if let count = count {
            length = min(count, buffer.count)
        } else {
            length = buffer.count
        }
        swifthal_fs_seek(filePointer, Int32(offset), SeekOrigin.start.rawValue)
        return Int(swifthal_fs_read(filePointer, buffer.baseAddress!, UInt32(length)))
    }

    /**
     Reads bytes at the current file offset into a buffer
     - Parameter buffer: **REQUIRED** Te region of memory to read into.
     - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The bytes successfully read.
     */
    public func read(into buffer: inout [UInt8], count: Int? = nil) -> Int {
        let length: Int

        if let count = count {
            length = min(count, buffer.count)
        } else {
            length = buffer.count
        }

        var ret: Int = 0
        buffer.withUnsafeMutableBytes { bufferPointer in
            ret = Int(swifthal_fs_read(filePointer, bufferPointer.baseAddress, UInt32(length)))
        }
        return ret
    }

    /**
     Reads bytes at the specified offset into a buffer.
     - Parameter offset: **REQUIRED** The file offset where reading begins.
     - Parameter buffer: **REQUIRED** Te region of memory to read into.
     - Parameter count: **OPTIONAL** The bytes you want to read.

     - Returns: The bytes successfully read.
     */
    public func read(fromAbsoluteOffest offset: Int, into buffer: inout [UInt8], count: Int? = nil) -> Int {
        let length: Int

        if let count = count {
            length = min(count, buffer.count)
        } else {
            length = buffer.count
        }
        swifthal_fs_seek(filePointer, Int32(offset), SeekOrigin.start.rawValue)
        var ret: Int = 0
        buffer.withUnsafeMutableBytes { bufferPointer in
            ret = Int(swifthal_fs_read(filePointer, bufferPointer.baseAddress, UInt32(length)))
        }
        return ret
    }

    /**
     Reposition the offset for the given file descriptor.
     - Parameter offset: **REQUIRED** The new offset for the file descriptor.
     - Parameter whence: **OPTIONAL** The origin of the new offset.
     */
    public func seek(offset: Int, from whence: SeekOrigin = .start) -> Int {
        Int(swifthal_fs_seek(filePointer, Int32(offset), whence.rawValue))
    }

    /**
     Writes the contents of a string at the current file offset.
      - Parameter string: **REQUIRED** The string being written.
     */
    public func write(_ string: String) {
        let data = string.utf8CString
        let size = UInt32(data.count - 1) 

        _ = data.withUnsafeBytes { dataPointer in
            swifthal_fs_write(filePointer, dataPointer.baseAddress, size)
        }
    }

    /**
     Writes the contents of a buffer at the current file offset.
      - Parameter buffer: **REQUIRED** The region of memory that contains the data being written.
      - Parameter count: **OPTIONAL** The bytes you want to read.
     */
    public func write(_ buffer: UnsafeRawBufferPointer, count: Int? = nil) {
        let length: Int

        if let count = count {
            length = min(count, buffer.count)
        } else {
            length = buffer.count
        }
        swifthal_fs_write(filePointer, buffer.baseAddress!, UInt32(length))
    }

    /**
     Writes the contents of a buffer at the specified offset.
      - Parameter offset: **REQUIRED** The file offset where writing begins.
      - Parameter buffer: **REQUIRED** Te region of memory that contains the data being written.
      - Parameter count: **OPTIONAL** The bytes you want to read.
     */
    public func write(toAbsoluteOffset offset: Int, _ buffer: UnsafeRawBufferPointer, count: Int? = nil) {
        let length: Int

        if let count = count {
            length = min(count, buffer.count)
        } else {
            length = buffer.count
        }
        swifthal_fs_seek(filePointer, Int32(offset), SeekOrigin.start.rawValue)
        swifthal_fs_write(filePointer, buffer.baseAddress!, UInt32(length))
    }

    /**
     Writes the contents of a buffer at the current file offset.
      - Parameter buffer: **REQUIRED** The region of memory that contains the data being written.
      - Parameter count: **OPTIONAL** The bytes you want to read.
     */
    public func write(_ buffer: [UInt8], count: Int? = nil) {
        let length: Int

        if let count = count {
            length = min(count, buffer.count)
        } else {
            length = buffer.count
        }
        _ = buffer.withUnsafeBytes { bufferPointer in
            swifthal_fs_write(filePointer, bufferPointer.baseAddress, UInt32(length))
        }
    }

    /**
     Writes the contents of a buffer at the specified offset.
      - Parameter offset: **REQUIRED** The file offset where writing begins.
      - Parameter buffer: **REQUIRED** Te region of memory that contains the data being written.
      - Parameter count: **OPTIONAL** The bytes you want to read.
     */
    public func write(toAbsoluteOffset offset: Int, _ buffer: [UInt8], count: Int? = nil) {
        let length: Int

        if let count = count {
            length = min(count, buffer.count)
        } else {
            length = buffer.count
        }
        swifthal_fs_seek(filePointer, Int32(offset), SeekOrigin.start.rawValue)
        _ = buffer.withUnsafeBytes { bufferPointer in
            swifthal_fs_write(filePointer, bufferPointer.baseAddress, UInt32(length))
        }
    }

    /**
     Flushes any cached write of an open file.
     - Attention:
     This method  can be used to flush the cache of an open file. This can be called to ensure data gets written to the storage media immediately. This may be done to avoid data loss if power is removed unexpectedly. Note that closing a file will cause caches to be flushed correctly so it need not be called if the file is being closed.
     */
    public func sync() {
        swifthal_fs_sync(filePointer)
    }

}

/**
A null-terminated sequence of bytes that represents a location in the file system.

*/
struct FilePath {
    internal var bytes: [CChar]
    private(set) var description: String = ""

    public var length: Int {
        bytes.count - 1
    }

    /**
     Creates a file path from a string.
      - Parameter string: **REQUIRED** A string whose ASCII contents to use as the contents of the path.
     */
    init(_ string: String) {
        description = string
        bytes = Array<CChar>(string.utf8CString)
        //print(bytes)
    }

}


extension FileDescriptor {

  public struct AccessMode: RawRepresentable {
    public var rawValue: UInt8

    public init(rawValue: UInt8) { self.rawValue = rawValue }

    public static var readOnly: AccessMode { AccessMode(rawValue: UInt8(SWIFT_FS_O_READ)) }
    public static var writeOnly: AccessMode { AccessMode(rawValue: UInt8(SWIFT_FS_O_WRITE)) }
    public static var readWrite: AccessMode { AccessMode(rawValue: UInt8(SWIFT_FS_O_RDWR)) }

  }

    public struct OpenOptions: OptionSet {
        public var rawValue: UInt8

        public init(rawValue: UInt8) { self.rawValue = rawValue }

        public static var create: OpenOptions { OpenOptions(rawValue: UInt8(SWIFT_FS_O_CREATE)) }
        public static var append: OpenOptions { OpenOptions(rawValue: UInt8(SWIFT_FS_O_APPEND)) }
    }


    /**
     Options for specifying what a file descriptor's offset is relative to.

     */
    public struct SeekOrigin: RawRepresentable {
        public var rawValue: Int32

        public init(rawValue: Int32) { self.rawValue = rawValue }

        public static var start: SeekOrigin { SeekOrigin(rawValue: SWIFT_FS_SEEK_SET)}
        public static var current: SeekOrigin { SeekOrigin(rawValue: SWIFT_FS_SEEK_CUR)}
        public static var end: SeekOrigin { SeekOrigin(rawValue: SWIFT_FS_SEEK_END)}
    }
}