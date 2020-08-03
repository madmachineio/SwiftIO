
public struct FileDescriptor {
    public enum SeekOrigin: Int32 {
        case start = 0
        case current
        case end
    }

    private var dirEntry: DirEntry
    private var filePointer: UnsafeRawPointer

    private(set) var filePath: FilePath


    public static func open(_ path: String) -> FileDescriptor? {
        let _filePath = FilePath(path)
        var _dirEntry = DirEntry()

        //let mountPoint = swiftHal_FsGetMountPoint()!
        //print(String(cString: mountPoint))

        if let _filePointer = swiftHal_FsOpen(_filePath.value) {
            swiftHal_FsStat(_filePath.value, &_dirEntry)
            //print(_dirEntry.size)
            return FileDescriptor(dirEntry: _dirEntry, filePointer: _filePointer, filePath: _filePath)
        } else {
            return nil
        }
    }


    public func close() {
        swiftHal_FsClose(filePointer)
    }

    public func tell() -> Int {
        return Int(swiftHal_FsTell(filePointer))
    }

    public func read(into buffer: UnsafeMutableRawBufferPointer) -> Int {
        let size = UInt32(buffer.count)
        return Int(swiftHal_FsRead(filePointer, buffer.baseAddress!, size))
    }

    public func read(fromAbsoluteOffest offset: Int, into buffer: UnsafeMutableRawBufferPointer) -> Int {
        let size = UInt32(buffer.count)
        swiftHal_FsSeek(filePointer, Int32(offset), SeekOrigin.start.rawValue)
        return Int(swiftHal_FsRead(filePointer, buffer.baseAddress!, size))
    }


    public func seek(offset: Int, from origin: SeekOrigin) -> Int {
        Int(swiftHal_FsSeek(filePointer, Int32(offset), origin.rawValue))
    }

    public func write(_ data: UnsafeRawBufferPointer) {
        let size = UInt32(data.count)
        swiftHal_FsWrite(filePointer, data.baseAddress!, size)
    }

    public func write(_ str: String) {
        let data = str.utf8CString
        let size = UInt32(data.count - 1) 

        _ = data.withUnsafeBytes { dataPointer in
            swiftHal_FsWrite(filePointer, dataPointer.baseAddress!, size)
        }

    }

    public func write(toAbsoluteOffset offset: Int, _ data: UnsafeRawBufferPointer) {
        let size = UInt32(data.count)
        swiftHal_FsSeek(filePointer, Int32(offset), SeekOrigin.start.rawValue)
        swiftHal_FsWrite(filePointer, data.baseAddress!, size)
    }

    public func sync() {
        swiftHal_FsSync(filePointer)
    }

}


public struct FilePath {
    private(set) var length: Int = 0
    private(set) var description: String = ""

    private(set) var value: [CChar]

    public init(_ str: String) {
        description = str
        length = str.count
        value = Array<CChar>(str.utf8CString)
        //print(value)
    }

}