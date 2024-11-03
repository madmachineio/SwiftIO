import CSwiftIO

public func createThread(
  name: String = "",
  priority: Int,
  stackSize: Int,
  p1: UnsafeMutableRawPointer? = nil,
  p2: UnsafeMutableRawPointer? = nil,
  p3: UnsafeMutableRawPointer? = nil,
  _ deadloop: @escaping swifthal_task
) {
  var cName = [CChar](name.utf8CString)
}

public func yield() {
}

public struct Mutex: @unchecked Sendable {

  public init() {
  }

  @discardableResult
  public func lock(_ timeout: Int = Int(SWIFT_FOREVER)) -> Result<(), Errno> {
    return nothingOrErrno(0)
  }

  @discardableResult
  public func unlock() -> Result<(), Errno> {
    return nothingOrErrno(0)
  }

  public func destroy() {
  }
}

public struct MessageQueue: @unchecked Sendable {

  public init(maxMessageBytes: Int, maxMessageCount: Int) {
  }

  public func destroy() {
  }

  @discardableResult
  public func send(data: UnsafeRawPointer, timeout: Int = Int(SWIFT_FOREVER)) -> Result<(), Errno> {
    return nothingOrErrno(0)
  }

  @discardableResult
  public func receive(into data: UnsafeMutableRawPointer, timeout: Int = Int(SWIFT_FOREVER))
    -> Result<(), Errno>
  {
    return nothingOrErrno(0)
  }

  // public func peek(into data: UnsafeMutableRawPointer) {
  //     swifthal_os_mq_peek(queue, data)
  // }

  public func purge() {
  }
}

public struct Semaphore: @unchecked Sendable {

  public init(initialCount: Int = 0, maxCount: Int = 1) {
    guard initialCount >= 0 && maxCount >= 1 else {
      print("error: Semaphore initialCount must >= 0 and maxCount must >= 1")
      fatalError()
    }
  }

  @discardableResult
  public func take(_ timeout: Int = Int(SWIFT_FOREVER)) -> Result<(), Errno> {
    return nothingOrErrno(0)
  }

  public func give() {
  }

  public func reset() {
  }

  public func destroy() {
  }
}
