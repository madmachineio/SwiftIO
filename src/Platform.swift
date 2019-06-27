public func usWait(_ us: Int) {
    swiftHal_usWait(Int32(us))
}

public func msSleep(_ ms: Int) {
    swiftHal_msSleep(Int32(ms))
}

