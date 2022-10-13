//=== Network.swift --------------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 10/13/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

import CSwiftIO


 public final class Network {

    public typealias InterFaceTxHandler = @convention(c) (
        UnsafeRawPointer?,
        Int32
    ) -> Int32

    var mac: [UInt8]
    var txHandler: InterFaceTxHandler?
    public var rxBuffer: [UInt8]

    public init(rxBufferSize: Int = 4096) {
        mac = [UInt8](repeating: 0x00, count: 6)
        txHandler = nil
        rxBuffer = [UInt8](repeating: 0x00, count: rxBufferSize)
    }

    deinit {
        swift_eth_tx_register(nil)
        swift_eth_event_send(ETH_EVENT_IFACE_DISCONNECTED, nil, 0, -1)
    }

    public func ifConfig(mac: [UInt8], tx: InterFaceTxHandler) {
        guard mac.count == 6 else {
            fatalError("error: network mac address must be 6 bytes")
        }
        self.mac = mac
        self.txHandler = tx

        swift_eth_setup_mac(self.mac)
        swift_eth_tx_register(self.txHandler!)
    }

    public func ifReceive(into buffer: inout [UInt8], count: Int? = nil) {
        var length: Int
        if count != nil && count! < buffer.count {
            length = count!
        } else {
            length = buffer.count
        }

        buffer.withUnsafeMutableBytes { pointer in
            let ptr = pointer.baseAddress
            swift_eth_rx(ptr, UInt16(length))
        }
    }

    public func ifUp() {
        swift_eth_event_send(ETH_EVENT_IFACE_UP, nil, 0, -1)
        swift_eth_event_send(ETH_EVENT_IFACE_CONNECTED, nil, 0, -1)
    }

    public func ifDown() {
        swift_eth_event_send(ETH_EVENT_IFACE_DISCONNECTED, nil, 0, -1)
    }
 }