//=== Ethernet.swift --------------------------------------------------===//
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


 public final class Ethernet {

    public typealias EthernetTxHandler = @convention(c) (
        UnsafePointer<UInt8>?,
        Int32
    ) -> Int32

    public typealias EthernetRxHandler = @convention(c) (
        UnsafeMutablePointer<UInt8>?,
        Int32
    ) -> Int32

    var mac: [UInt8]
    var txHandler: EthernetTxHandler!
    public static var rxHandler: EthernetRxHandler = { pointer, length in
        return swift_eth_rx(pointer, UInt16(length))
    }

    public init(mac: [UInt8], txHandler: EthernetTxHandler) {
        guard mac.count == 6 else {
            fatalError("error: mac address must be 6 bytes")
        }
        self.mac = mac
        self.txHandler = txHandler

        swift_eth_setup_mac(self.mac)
        swift_eth_tx_register(self.txHandler)
    }

    public init() {
        mac = [UInt8](repeating: 0x00, count: 6)
        txHandler = nil
    }

    deinit {
        swift_eth_tx_register(nil)
        swift_eth_event_send(ETH_EVENT_IFACE_DISCONNECTED, nil, 0, -1)
    }

    public func setup(mac: [UInt8], txHandler: EthernetTxHandler) {
        guard mac.count == 6 else {
            fatalError("error: internet face mac address must be 6 bytes")
        }
        self.mac = mac
        self.txHandler = txHandler

        print("ifconfig mac = \(mac))")
        swift_eth_setup_mac(self.mac)
        swift_eth_tx_register(self.txHandler)
    }

    public func up() {
        swift_eth_event_send(ETH_EVENT_IFACE_UP, nil, 0, -1)
        swift_eth_event_send(ETH_EVENT_IFACE_CONNECTED, nil, 0, -1)
    }

    public func down() {
        swift_eth_event_send(ETH_EVENT_IFACE_DISCONNECTED, nil, 0, -1)
    }
 }