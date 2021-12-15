//=== Errno.swift ---------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 11/22/2021
// Updated: 11/22/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CNewlib

public struct Errno: RawRepresentable, Error {

  /// The raw C error number.
  @_alwaysEmitIntoClient
  public let rawValue: CInt

  /// Creates a strongly typed error number from a raw C error number.
  @_alwaysEmitIntoClient
  public init(rawValue: CInt) {
      //self.rawValue = rawValue < 0 ? -rawValue : rawValue
      self.rawValue = abs(rawValue)
  }

  @_alwaysEmitIntoClient
  public init(_ raw: CInt) { self.init(rawValue: raw) }

  /// Success.
  ///
  /// The corresponding C result is 0.
  // @_alwaysEmitIntoClient
  // public static var success: Errno { Errno(0) }

  /// Operation not permitted.
  ///
  /// An attempt was made to perform an operation
  /// limited to processes with appropriate privileges
  /// or to the owner of a file or other resources.
  ///
  /// The corresponding C error is `EPERM`.
  @_alwaysEmitIntoClient
  public static var notPermitted: Errno { Errno(EPERM) }


  /// No such file or directory.
  ///
  /// A component of a specified pathname didn't exist,
  /// or the pathname was an empty string.
  ///
  /// The corresponding C error is `ENOENT`.
  @_alwaysEmitIntoClient
  public static var noSuchFileOrDirectory: Errno { Errno(ENOENT) }


  /// No such process.
  ///
  /// There isn't a process that corresponds to the specified process ID.
  ///
  /// The corresponding C error is `ESRCH`.
  @_alwaysEmitIntoClient
  public static var noSuchProcess: Errno { Errno(ESRCH) }


  /// Interrupted function call.
  ///
  /// The process caught an asynchronous signal (such as `SIGINT` or `SIGQUIT`)
  /// during the execution of an interruptible function.
  /// If the signal handler performs a normal return,
  /// the caller of the interrupted function call receives this error.
  ///
  /// The corresponding C error is `EINTR`.
  @_alwaysEmitIntoClient
  public static var interrupted: Errno { Errno(EINTR) }


  /// Input/output error.
  ///
  /// Some physical input or output error occurred.
  /// This error isn't reported until
  /// you attempt a subsequent operation on the same file descriptor,
  /// and the error may be lost (overwritten) by subsequent errors.
  ///
  /// The corresponding C error is `EIO`.
  @_alwaysEmitIntoClient
  public static var ioError: Errno { Errno(EIO) }


  /// No such device or address.
  ///
  /// Input or output on a special file referred to a device that didn't exist,
  /// or made a request beyond the limits of the device.
  /// This error may also occur when, for example,
  /// a tape drive isn't online or when there isn't a disk pack loaded on a drive.
  ///
  /// The corresponding C error is `ENXIO`.
  @_alwaysEmitIntoClient
  public static var noSuchAddressOrDevice: Errno { Errno(ENXIO) }


  /// The argument list is too long.
  ///
  /// The number of bytes
  /// used for the argument and environment list of the new process
  /// exceeded the limit `NCARGS`, as defined in `<sys/param.h>`.
  ///
  /// The corresponding C error is `E2BIG`.
  @_alwaysEmitIntoClient
  public static var argListTooLong: Errno { Errno(E2BIG) }

  /// Executable format error.
  ///
  /// A request was made to execute a file that,
  /// although it has the appropriate permissions,
  /// isn't in the format required for an executable file.
  ///
  /// The corresponding C error is `ENOEXEC`.
  @_alwaysEmitIntoClient
  public static var execFormatError: Errno { Errno(ENOEXEC) }


  /// Bad file descriptor.
  ///
  /// A file descriptor argument was out of range,
  /// referred to no open file,
  /// or a read (write) request was made to a file
  /// that was only open for writing (reading).
  ///
  /// The corresponding C error is `EBADF`.
  @_alwaysEmitIntoClient
  public static var badFileDescriptor: Errno { Errno(EBADF) }


  /// No child processes.
  ///
  /// A `wait(2)` or `waitpid(2)` function was executed
  /// by a process that dosn't have any existing child processes
  /// or whose child processes are all already being waited for.
  ///
  /// The corresponding C error is `ECHILD`.
  @_alwaysEmitIntoClient
  public static var noChildProcess: Errno { Errno(ECHILD) }


  /// Resource deadlock avoided.
  ///
  /// You attempted to lock a system resource
  /// that would have resulted in a deadlock.
  ///
  /// The corresponding C error is `EDEADLK`.
  @_alwaysEmitIntoClient
  public static var deadlock: Errno { Errno(EDEADLK) }


  /// Can't allocate memory.
  ///
  /// The new process image required more memory
  /// than was allowed by the hardware
  /// or by system-imposed memory management constraints.
  /// A lack of swap space is normally temporary;
  /// however, a lack of core is not.
  /// You can increase soft limits up to their corresponding hard limits.
  ///
  /// The corresponding C error is `ENOMEM`.
  @_alwaysEmitIntoClient
  public static var noMemory: Errno { Errno(ENOMEM) }


  /// Permission denied.
  ///
  /// You attempted to access a file
  /// in a way that's forbidden by the file's access permissions.
  ///
  /// The corresponding C error is `EACCES`.
  @_alwaysEmitIntoClient
  public static var permissionDenied: Errno { Errno(EACCES) }


  /// Bad address.
  ///
  /// An address passed as an argument to a system call was invalid.
  ///
  /// The corresponding C error is `EFAULT`.
  @_alwaysEmitIntoClient
  public static var badAddress: Errno { Errno(EFAULT) }


  /// Resource busy.
  ///
  /// You attempted to use a system resource which was in use at the time,
  /// in a manner that would have conflicted with the request.
  ///
  /// The corresponding C error is `EBUSY`.
  @_alwaysEmitIntoClient
  public static var resourceBusy: Errno { Errno(EBUSY) }


  /// File exists.
  ///
  /// An existing file was mentioned in an inappropriate context;
  /// for example, as the new link name in a link function.
  ///
  /// The corresponding C error is `EEXIST`.
  @_alwaysEmitIntoClient
  public static var fileExists: Errno { Errno(EEXIST) }


  /// Improper link.
  ///
  /// You attempted to create a hard link to a file on another file system.
  ///
  /// The corresponding C error is `EXDEV`.
  @_alwaysEmitIntoClient
  public static var improperLink: Errno { Errno(EXDEV) }


  /// Operation not supported by device.
  ///
  /// You attempted to apply an inappropriate function to a device;
  /// for example, trying to read a write-only device such as a printer.
  ///
  /// The corresponding C error is `ENODEV`.
  @_alwaysEmitIntoClient
  public static var operationNotSupportedByDevice: Errno { Errno(ENODEV) }


  /// Not a directory.
  ///
  /// A component of the specified pathname exists,
  /// but it wasn't a directory,
  /// when a directory was expected.
  ///
  /// The corresponding C error is `ENOTDIR`.
  @_alwaysEmitIntoClient
  public static var notDirectory: Errno { Errno(ENOTDIR) }


  /// Is a directory.
  ///
  /// You attempted to open a directory with write mode specified.
  /// Directories can be opened only in read mode.
  ///
  /// The corresponding C error is `EISDIR`.
  @_alwaysEmitIntoClient
  public static var isDirectory: Errno { Errno(EISDIR) }


  /// Invalid argument.
  ///
  /// One or more of the specified arguments wasn't valid;
  /// for example, specifying an undefined signal to a signal or kill function.
  ///
  /// The corresponding C error is `EINVAL`.
  @_alwaysEmitIntoClient
  public static var invalidArgument: Errno { Errno(EINVAL) }


  /// The system has too many open files.
  ///
  /// The maximum number of file descriptors
  /// allowable on the system has been reached;
  /// requests to open a file can't be satisfied
  /// until you close at least one file descriptor.
  ///
  /// The corresponding C error is `ENFILE`.
  @_alwaysEmitIntoClient
  public static var tooManyOpenFilesInSystem: Errno { Errno(ENFILE) }


  /// This process has too many open files.
  ///
  /// To check the current limit,
  /// call the `getdtablesize` function.
  ///
  /// The corresponding C error is `EMFILE`.
  @_alwaysEmitIntoClient
  public static var tooManyOpenFiles: Errno { Errno(EMFILE) }


  /// Inappropriate control function.
  ///
  /// You attempted a control function
  /// that can't be performed on the specified file or device.
  /// For information about control functions, see `ioctl(2)`.
  ///
  /// The corresponding C error is `ENOTTY`.
  @_alwaysEmitIntoClient
  public static var inappropriateIOCTLForDevice: Errno { Errno(ENOTTY) }


  /// Text file busy.
  ///
  /// The new process was a pure procedure (shared text) file,
  /// which was already open for writing by another process,
  /// or while the pure procedure file was being executed,
  /// an open call requested write access.
  ///
  /// The corresponding C error is `ETXTBSY`.
  @_alwaysEmitIntoClient
  public static var textFileBusy: Errno { Errno(ETXTBSY) }

  /// The file is too large.
  ///
  /// The file exceeds the maximum size allowed by the file system.
  /// For example, the maximum size on UFS is about 2.1 gigabytes,
  /// and about 9,223 petabytes on HFS-Plus and Apple File System.
  ///
  /// The corresponding C error is `EFBIG`.
  @_alwaysEmitIntoClient
  public static var fileTooLarge: Errno { Errno(EFBIG) }


  /// Device out of space.
  ///
  /// A write to an ordinary file,
  /// the creation of a directory or symbolic link,
  /// or the creation of a directory entry failed
  /// because there aren't any available disk blocks on the file system,
  /// or the allocation of an inode for a newly created file failed
  /// because there aren't any inodes available on the file system.
  ///
  /// The corresponding C error is `ENOSPC`.
  @_alwaysEmitIntoClient
  public static var noSpace: Errno { Errno(ENOSPC) }


  /// Illegal seek.
  ///
  /// An `lseek(2)` function was issued on a socket, pipe or FIFO.
  ///
  /// The corresponding C error is `ESPIPE`.
  @_alwaysEmitIntoClient
  public static var illegalSeek: Errno { Errno(ESPIPE) }


  /// Read-only file system.
  ///
  /// You attempted to modify a file or directory
  /// on a file system that was read-only at the time.
  ///
  /// The corresponding C error is `EROFS`.
  @_alwaysEmitIntoClient
  public static var readOnlyFileSystem: Errno { Errno(EROFS) }


  /// Too many links.
  ///
  /// The maximum number of hard links to a single file (32767)
  /// has been exceeded.
  ///
  /// The corresponding C error is `EMLINK`.
  @_alwaysEmitIntoClient
  public static var tooManyLinks: Errno { Errno(EMLINK) }


  /// Broken pipe.
  ///
  /// You attempted to write to a pipe, socket, or FIFO
  /// that doesn't have a process reading its data.
  ///
  /// The corresponding C error is `EPIPE`.
  @_alwaysEmitIntoClient
  public static var brokenPipe: Errno { Errno(EPIPE) }


  /// Numerical argument out of domain.
  ///
  /// A numerical input argument was outside the defined domain of the
  /// mathematical function.
  ///
  /// The corresponding C error is `EDOM`.
  @_alwaysEmitIntoClient
  public static var outOfDomain: Errno { Errno(EDOM) }


  /// Numerical result out of range.
  ///
  /// A numerical result of the function
  /// was too large to fit in the available space;
  /// for example, because it exceeded a floating point number's
  /// level of precision.
  ///
  /// The corresponding C error is `ERANGE`.
  @_alwaysEmitIntoClient
  public static var outOfRange: Errno { Errno(ERANGE) }


  /// Resource temporarily unavailable.
  ///
  /// This is a temporary condition;
  /// later calls to the same routine may complete normally.
  /// Make the same function call again later.
  ///
  /// The corresponding C error is `EAGAIN`.
  @_alwaysEmitIntoClient
  public static var resourceTemporarilyUnavailable: Errno { Errno(EAGAIN) }


  /// Operation now in progress.
  ///
  /// You attempted an operation that takes a long time to complete,
  /// such as `connect(2)` or `connectx(2)`,
  /// on a nonblocking object.
  /// See also `fcntl(2)`.
  ///
  /// The corresponding C error is `EINPROGRESS`.
  @_alwaysEmitIntoClient
  public static var nowInProgress: Errno { Errno(EINPROGRESS) }


  /// Operation already in progress.
  ///
  /// You attempted an operation on a nonblocking object
  /// that already had an operation in progress.
  ///
  /// The corresponding C error is `EALREADY`.
  @_alwaysEmitIntoClient
  public static var alreadyInProcess: Errno { Errno(EALREADY) }


  /// A socket operation was performed on something that isn't a socket.
  ///
  /// The corresponding C error is `ENOTSOCK`.
  @_alwaysEmitIntoClient
  public static var notSocket: Errno { Errno(ENOTSOCK) }


  /// Destination address required.
  ///
  /// A required address was omitted from a socket operation.
  ///
  /// The corresponding C error is `EDESTADDRREQ`.
  @_alwaysEmitIntoClient
  public static var addressRequired: Errno { Errno(EDESTADDRREQ) }


  /// Message too long.
  ///
  /// A message sent on a socket was larger than
  /// the internal message buffer or some other network limit.
  ///
  /// The corresponding C error is `EMSGSIZE`.
  @_alwaysEmitIntoClient
  public static var messageTooLong: Errno { Errno(EMSGSIZE) }


  /// Protocol wrong for socket type.
  ///
  /// A protocol was specified that doesn't support
  /// the semantics of the socket type requested.
  /// For example,
  /// you can't use the ARPA Internet UDP protocol with type `SOCK_STREAM`.
  ///
  /// The corresponding C error is `EPROTOTYPE`.
  @_alwaysEmitIntoClient
  public static var protocolWrongTypeForSocket: Errno { Errno(EPROTOTYPE) }


  /// Protocol not available.
  ///
  /// A bad option or level was specified
  /// in a `getsockopt(2)` or `setsockopt(2)` call.
  ///
  /// The corresponding C error is `ENOPROTOOPT`.
  @_alwaysEmitIntoClient
  public static var protocolNotAvailable: Errno { Errno(ENOPROTOOPT) }


  /// Protocol not supported.
  ///
  /// The protocol hasn't been configured into the system,
  /// or no implementation for it exists.
  ///
  /// The corresponding C error is `EPROTONOSUPPORT`.
  @_alwaysEmitIntoClient
  public static var protocolNotSupported: Errno { Errno(EPROTONOSUPPORT) }


  /// Not supported.
  ///
  /// The attempted operation isn't supported
  /// for the type of object referenced.
  ///
  /// The corresponding C error is `ENOTSUP`.
  @_alwaysEmitIntoClient
  public static var notSupported: Errno { Errno(ENOTSUP) }


  /// Protocol family not supported.
  ///
  /// The protocol family hasn't been configured into the system
  /// or no implementation for it exists.
  ///
  /// The corresponding C error is `EPFNOSUPPORT`.
  @_alwaysEmitIntoClient
  public static var protocolFamilyNotSupported: Errno { Errno(EPFNOSUPPORT) }


  /// The address family isn't supported by the protocol family.
  ///
  /// An address incompatible with the requested protocol was used.
  /// For example, you shouldn't necessarily expect
  /// to be able to use name server addresses with ARPA Internet protocols.
  ///
  /// The corresponding C error is `EAFNOSUPPORT`.
  @_alwaysEmitIntoClient
  public static var addressFamilyNotSupported: Errno { Errno(EAFNOSUPPORT) }


  /// Address already in use.
  ///
  /// Only one use of each address is normally permitted.
  ///
  /// The corresponding C error is `EADDRINUSE`.
  @_alwaysEmitIntoClient
  public static var addressInUse: Errno { Errno(EADDRINUSE) }


  /// Can't assign the requested address.
  ///
  /// This error normally results from
  /// an attempt to create a socket with an address that isn't on this machine.
  ///
  /// The corresponding C error is `EADDRNOTAVAIL`.
  @_alwaysEmitIntoClient
  public static var addressNotAvailable: Errno { Errno(EADDRNOTAVAIL) }


  /// Network is down.
  ///
  /// A socket operation encountered a dead network.
  ///
  /// The corresponding C error is `ENETDOWN`.
  @_alwaysEmitIntoClient
  public static var networkDown: Errno { Errno(ENETDOWN) }


  /// Network is unreachable.
  ///
  /// A socket operation was attempted to an unreachable network.
  ///
  /// The corresponding C error is `ENETUNREACH`.
  @_alwaysEmitIntoClient
  public static var networkUnreachable: Errno { Errno(ENETUNREACH) }


  /// Network dropped connection on reset.
  ///
  /// The host you were connected to crashed and restarted.
  ///
  /// The corresponding C error is `ENETRESET`.
  @_alwaysEmitIntoClient
  public static var networkReset: Errno { Errno(ENETRESET) }


  /// Software caused a connection abort.
  ///
  /// A connection abort was caused internal to your host machine.
  ///
  /// The corresponding C error is `ECONNABORTED`.
  @_alwaysEmitIntoClient
  public static var connectionAbort: Errno { Errno(ECONNABORTED) }


  /// Connection reset by peer.
  ///
  /// A connection was forcibly closed by a peer.
  /// This normally results from a loss of the connection
  /// on the remote socket due to a timeout or a reboot.
  ///
  /// The corresponding C error is `ECONNRESET`.
  @_alwaysEmitIntoClient
  public static var connectionReset: Errno { Errno(ECONNRESET) }


  /// No buffer space available.
  ///
  /// An operation on a socket or pipe wasn't performed
  /// because the system lacked sufficient buffer space
  /// or because a queue was full.
  ///
  /// The corresponding C error is `ENOBUFS`.
  @_alwaysEmitIntoClient
  public static var noBufferSpace: Errno { Errno(ENOBUFS) }


  /// Socket is already connected.
  ///
  /// A `connect(2)` or `connectx(2)` request was made
  /// on an already connected socket,
  /// or a `sendto(2)` or `sendmsg(2)` request was made
  /// on a connected socket specified a destination when already connected.
  ///
  /// The corresponding C error is `EISCONN`.
  @_alwaysEmitIntoClient
  public static var socketIsConnected: Errno { Errno(EISCONN) }

  /// Socket is not connected.
  ///
  /// A request to send or receive data wasn't permitted
  /// because the socket wasn't connected and,
  /// when sending on a datagram socket,
  /// no address was supplied.
  ///
  /// The corresponding C error is `ENOTCONN`.
  @_alwaysEmitIntoClient
  public static var socketNotConnected: Errno { Errno(ENOTCONN) }



  /// Operation timed out.
  ///
  /// A `connect(2)`, `connectx(2)` or `send(2)` request failed
  /// because the connected party didn't properly respond
  /// within the required period of time.
  /// The timeout period is dependent on the communication protocol.
  ///
  /// The corresponding C error is `ETIMEDOUT`.
  @_alwaysEmitIntoClient
  public static var timedOut: Errno { Errno(ETIMEDOUT) }


  /// Connection refused.
  ///
  /// No connection could be made
  /// because the target machine actively refused it.
  /// This usually results from trying to connect to a service
  /// that's inactive on the foreign host.
  ///
  /// The corresponding C error is `ECONNREFUSED`.
  @_alwaysEmitIntoClient
  public static var connectionRefused: Errno { Errno(ECONNREFUSED) }


  /// Too many levels of symbolic links.
  ///
  /// A pathname lookup involved more than eight symbolic links.
  ///
  /// The corresponding C error is `ELOOP`.
  @_alwaysEmitIntoClient
  public static var tooManySymbolicLinkLevels: Errno { Errno(ELOOP) }


  /// The file name is too long.
  ///
  /// A component of a pathname exceeded 255 (`MAXNAMELEN`) characters,
  /// or an entire pathname exceeded 1023 (`MAXPATHLEN-1`) characters.
  ///
  /// The corresponding C error is `ENAMETOOLONG`.
  @_alwaysEmitIntoClient
  public static var fileNameTooLong: Errno { Errno(ENAMETOOLONG) }


  /// The host is down.
  ///
  /// A socket operation failed because the destination host was down.
  ///
  /// The corresponding C error is `EHOSTDOWN`.
  @_alwaysEmitIntoClient
  public static var hostIsDown: Errno { Errno(EHOSTDOWN) }


  /// No route to host.
  ///
  /// A socket operation failed because the destination host was unreachable.
  ///
  /// The corresponding C error is `EHOSTUNREACH`.
  @_alwaysEmitIntoClient
  public static var noRouteToHost: Errno { Errno(EHOSTUNREACH) }


  /// Directory not empty.
  ///
  /// A directory with entries other than `.` and `..`
  /// was supplied to a `remove(2)` directory or `rename(2)` call.
  ///
  /// The corresponding C error is `ENOTEMPTY`.
  @_alwaysEmitIntoClient
  public static var directoryNotEmpty: Errno { Errno(ENOTEMPTY) }



  /// Disk quota exceeded.
  ///
  /// A write to an ordinary file,
  /// the creation of a directory or symbolic link,
  /// or the creation of a directory entry failed
  /// because the user's quota of disk blocks was exhausted,
  /// or the allocation of an inode for a newly created file failed
  /// because the user's quota of inodes was exhausted.
  ///
  /// The corresponding C error is `EDQUOT`.
  /// @_alwaysEmitIntoClient
  /// public static var diskQuotaExceeded: Errno { Errno(EDQUOT) }


  /// Stale NFS file handle.
  ///
  /// You attempted access an open file on an NFS filesystem,
  /// which is now unavailable as referenced by the given file descriptor.
  /// This may indicate that the file was deleted on the NFS server
  /// or that some other catastrophic event occurred.
  ///
  /// The corresponding C error is `ESTALE`.
  /// @_alwaysEmitIntoClient
  /// public static var staleNFSFileHandle: Errno { Errno(ESTALE) }


  /// No locks available.
  ///
  /// You have reached the system-imposed limit
  /// on the number of simultaneous files.
  ///
  /// The corresponding C error is `ENOLCK`.
  @_alwaysEmitIntoClient
  public static var noLocks: Errno { Errno(ENOLCK) }


  /// Function not implemented.
  ///
  /// You attempted a system call that isn't available on this system.
  ///
  /// The corresponding C error is `ENOSYS`.
  @_alwaysEmitIntoClient
  public static var noFunction: Errno { Errno(ENOSYS) }


  /// Operation canceled.
  ///
  /// The scheduled operation was canceled.
  ///
  /// The corresponding C error is `ECANCELED`.
  @_alwaysEmitIntoClient
  public static var canceled: Errno { Errno(ECANCELED) }


  /// Illegal byte sequence.
  ///
  /// While decoding a multibyte character,
  /// the function encountered an invalid or incomplete sequence of bytes,
  /// or the given wide character is invalid.
  ///
  /// The corresponding C error is `EILSEQ`.
  @_alwaysEmitIntoClient
  public static var illegalByteSequence: Errno { Errno(EILSEQ) }


  /// Bad message.
  ///
  /// The message to be received is inappropriate
  /// for the attempted operation.
  ///
  /// The corresponding C error is `EBADMSG`.
  @_alwaysEmitIntoClient
  public static var badMessage: Errno { Errno(EBADMSG) }

  /// Reserved.
  ///
  /// This error is reserved for future use.
  ///
  /// The corresponding C error is `EMULTIHOP`.
  /// @_alwaysEmitIntoClient
  /// public static var multiHop: Errno { Errno(EMULTIHOP) }

  /// No message available.
  ///
  /// No message was available to be received by the requested operation.
  ///
  /// The corresponding C error is `ENODATA`.
  @_alwaysEmitIntoClient
  public static var noData: Errno { Errno(ENODATA) }

  /// Reserved.
  ///
  /// This error is reserved for future use.
  ///
  /// The corresponding C error is `ENOLINK`.
  /// @_alwaysEmitIntoClient
  /// public static var noLink: Errno { Errno(ENOLINK) }

  /// Reserved.
  ///
  /// This error is reserved for future use.
  ///
  /// The corresponding C error is `ENOSR`.
  @_alwaysEmitIntoClient
  public static var noStreamResources: Errno { Errno(ENOSR) }

  /// Reserved.
  ///
  /// This error is reserved for future use.
  ///
  /// The corresponding C error is `ENOSTR`.
  @_alwaysEmitIntoClient
  public static var notStream: Errno { Errno(ENOSTR) }

  /// Protocol error.
  ///
  /// Some protocol error occurred.
  /// This error is device-specific,
  /// but generally isn't related to a hardware failure.
  ///
  /// The corresponding C error is `EPROTO`.
  @_alwaysEmitIntoClient
  public static var protocolError: Errno { Errno(EPROTO) }

  /// Reserved.
  ///
  /// This error is reserved for future use.
  ///
  /// The corresponding C error is `ETIME`.
  @_alwaysEmitIntoClient
  public static var timeout: Errno { Errno(ETIME) }


  /// Operation not supported on socket.
  ///
  /// The attempted operation isn't supported for the type of socket referenced;
  /// for example, trying to accept a connection on a datagram socket.
  ///
  /// The corresponding C error is `EOPNOTSUPP`.
  @_alwaysEmitIntoClient
  public static var notSupportedOnSocket: Errno { Errno(EOPNOTSUPP) }
}


extension Errno {
  @_alwaysEmitIntoClient
  public static func ~=(_ lhs: Errno, _ rhs: Error) -> Bool {
    guard let value = rhs as? Errno else { return false }
    return lhs == value
  }
}

// @available(macOS 10.16, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension Errno: CustomStringConvertible, CustomDebugStringConvertible {
  ///  A textual representation of the most recent error
  ///  returned by a system call.
  ///
  /// The corresponding C function is `strerror(3)`.
  @inline(never)
  public var description: String {
    guard let ptr = system_strerror(self.rawValue) else { return "unknown error" }
    return String(cString: ptr)
  }

  ///  A textual representation,
  ///  suitable for debugging,
  ///  of the most recent error returned by a system call.
  ///
  /// The corresponding C function is `strerror(3)`.
  public var debugDescription: String { self.description }
}