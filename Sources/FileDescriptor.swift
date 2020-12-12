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
    
    /**
     Options for specifying what a file descriptor's offset is relative to.

     */
    public enum SeekOrigin: Int32 {
        case start = 0
        case current
        case end
    }

    private var dirEntry: DirEntry
    private var filePointer: UnsafeRawPointer

    private(set) var filePath: FilePath

    /**
     Open or creates, if does not exist, file.
     - Parameter path: **REQUIRED** The location of the file to open.
     - Attention:
        The root directory for the micro SD card is "/SD:/"
     */
    public static func open(_ path: String) -> FileDescriptor {
        let _filePath = FilePath(path)
        var _dirEntry = DirEntry()

        if let _filePointer = swiftHal_FsOpen(_filePath.value) {
            swiftHal_FsStat(_filePath.value, &_dirEntry)
            return FileDescriptor(dirEntry: _dirEntry, filePointer: _filePointer, filePath: _filePath)
        } else {
            fatalError("Open file failed!")
        }
    }

    /**
     Deletes the specified file or directory
    - Parameter path: **REQUIRED** The location of the file to open.
     */
    public static func unlink(_ path: String) {
        let _filePath = FilePath(path)

        swiftHal_FsRemove(_filePath.value) 
    }

    /**
     Flushes the associated stream and closes the file.
     
     */
    public func close() {
        swiftHal_FsClose(filePointer)
    }

    /**
     Get current file position.
     - Returns: Current position in file.
     */
    public func tell() -> Int {
        return Int(swiftHal_FsTell(filePointer))
    }

    /**
     Reads bytes at the current file offset into a buffer
     - Parameter buffer: **REQUIRED** Te region of memory to read into.
     */
    public func read(into buffer: UnsafeMutableRawBufferPointer) -> Int {
        let size = UInt32(buffer.count)
        return Int(swiftHal_FsRead(filePointer, buffer.baseAddress!, size))
    }

    /**
     Reads bytes at the specified offset into a buffer.
     - Parameter offset: **REQUIRED** The file offset where reading begins.
     - Parameter buffer: **REQUIRED** Te region of memory to read into.
     */
    public func read(fromAbsoluteOffest offset: Int, into buffer: UnsafeMutableRawBufferPointer) -> Int {
        let size = UInt32(buffer.count)
        swiftHal_FsSeek(filePointer, Int32(offset), SeekOrigin.start.rawValue)
        return Int(swiftHal_FsRead(filePointer, buffer.baseAddress!, size))
    }

    /**
     Reposition the offset for the given file descriptor.
     - Parameter offset: **REQUIRED** The new offset for the file descriptor.
     - Parameter whence: **OPTIONAL** The origin of the new offset.
     */
    public func seek(offset: Int, from whence: SeekOrigin = .start) -> Int {
        Int(swiftHal_FsSeek(filePointer, Int32(offset), whence.rawValue))
    }

    /**
     Writes the contents of a buffer at the current file offset.
      - Parameter buffer: **REQUIRED** The region of memory that contains the data being written.
     */
    public func write(_ buffer: UnsafeRawBufferPointer) {
        let size = UInt32(buffer.count)
        swiftHal_FsWrite(filePointer, buffer.baseAddress!, size)
    }

    /**
     Writes the contents of a string at the current file offset.
      - Parameter string: **REQUIRED** The string being written.
     */
    public func write(_ string: String) {
        let data = string.utf8CString
        let size = UInt32(data.count - 1) 

        _ = data.withUnsafeBytes { dataPointer in
            swiftHal_FsWrite(filePointer, dataPointer.baseAddress!, size)
        }

    }

    /**
     Writes the contents of a buffer at the specified offset.
      - Parameter offset: **REQUIRED** The file offset where writing begins.
      - Parameter buffer: **REQUIRED** Te region of memory that contains the data being written.
     */
    public func write(toAbsoluteOffset offset: Int, _ buffer: UnsafeRawBufferPointer) {
        let size = UInt32(buffer.count)
        swiftHal_FsSeek(filePointer, Int32(offset), SeekOrigin.start.rawValue)
        swiftHal_FsWrite(filePointer, buffer.baseAddress!, size)
    }
    
    /**
     Flushes any cached write of an open file.
     - Attention:
     This method  can be used to flush the cache of an open file. This can be called to ensure data gets written to the storage media immediately. This may be done to avoid data loss if power is removed unexpectedly. Note that closing a file will cause caches to be flushed correctly so it need not be called if the file is being closed.
     */
    public func sync() {
        swiftHal_FsSync(filePointer)
    }

}

/**
A null-terminated sequence of bytes that represents a location in the file system.

*/
struct FilePath {
    private(set) var length: Int = 0
    private(set) var description: String = ""

    private(set) var value: [CChar]

    /**
     Creates a file path from a string.
      - Parameter string: **REQUIRED** A string whose ASCII contents to use as the contents of the path.
     */
    init(_ string: String) {
        description = string
        length = string.count
        value = Array<CChar>(string.utf8CString)
        //print(value)
    }

}
