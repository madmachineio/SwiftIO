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
  swifthal_os_task_create(&cName, deadloop, p1, p2, p3, Int32(priority), Int32(stackSize))
}

public func yield() {
  swifthal_os_task_yield()
}

public struct Mutex: @unchecked Sendable {
  let mutex: UnsafeRawPointer

  public init() {
    mutex = swifthal_os_mutex_create()
  }

  @discardableResult
  public func lock(_ timeout: Int = Int(SWIFT_FOREVER)) -> Result<(), Errno> {
    return nothingOrErrno(
      swifthal_os_mutex_lock(mutex, Int32(timeout))
    )
  }

  @discardableResult
  public func unlock() -> Result<(), Errno> {
    return nothingOrErrno(
      swifthal_os_mutex_unlock(mutex)
    )
  }

  public func destroy() {
    swifthal_os_mutex_destroy(mutex)
  }
}

public struct MessageQueue: @unchecked Sendable {
  let queue: UnsafeRawPointer

  public init(maxMessageBytes: Int, maxMessageCount: Int) {
    queue = swifthal_os_mq_create(maxMessageBytes, maxMessageCount)
  }

  public func destroy() {
    swifthal_os_mq_destroy(queue)
  }

  @discardableResult
  public func send(data: UnsafeRawPointer, timeout: Int = Int(SWIFT_FOREVER)) -> Result<(), Errno> {
    return nothingOrErrno(
      swifthal_os_mq_send(queue, data, Int32(timeout))
    )
  }

  @discardableResult
  public func receive(into data: UnsafeMutableRawPointer, timeout: Int = Int(SWIFT_FOREVER))
    -> Result<(), Errno>
  {
    return nothingOrErrno(
      swifthal_os_mq_recv(queue, data, Int32(timeout))
    )
  }

  // public func peek(into data: UnsafeMutableRawPointer) {
  //     swifthal_os_mq_peek(queue, data)
  // }

  public func purge() {
    swifthal_os_mq_purge(queue)
  }
}

public struct Semaphore: @unchecked Sendable {
  let sem: UnsafeRawPointer

  public init(initialCount: Int = 0, maxCount: Int = 1) {
    guard initialCount >= 0 && maxCount >= 1 else {
      print("error: Semaphore initialCount must >= 0 and maxCount must >= 1")
      fatalError()
    }
    sem = swifthal_os_sem_create(UInt32(initialCount), UInt32(maxCount))
  }

  @discardableResult
  public func take(_ timeout: Int = Int(SWIFT_FOREVER)) -> Result<(), Errno> {
    return nothingOrErrno(
      swifthal_os_sem_take(sem, Int32(timeout))
    )
  }

  public func give() {
    swifthal_os_sem_give(sem)
  }

  public func reset() {
    swifthal_os_sem_reset(sem)
  }

  public func destroy() {
    swifthal_os_sem_destroy(sem)
  }
}
