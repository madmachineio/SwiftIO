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

    static var mac: [UInt8] = [UInt8](repeating: 0x00, count: 6)
    static var txHandler: EthernetTxHandler?
    static public let rxHandler: EthernetRxHandler = { pointer, length in
        return swift_eth_rx(pointer, UInt16(length))
    }

    public static func setup(mac: [UInt8], txHandler: EthernetTxHandler) {
        guard mac.count == 6 else {
            fatalError("error: mac address must be 6 bytes")
        }
        Ethernet.mac = mac
        Ethernet.txHandler = txHandler

        swift_eth_setup_mac(Ethernet.mac)
        swift_eth_tx_register(Ethernet.txHandler)
    }

    public static func up() {
        swift_eth_event_send(ETH_EVENT_IFACE_UP, nil, 0, -1)
        swift_eth_event_send(ETH_EVENT_IFACE_CONNECTED, nil, 0, -1)
    }

    public static func down() {
        swift_eth_tx_register(nil)
        swift_eth_event_send(ETH_EVENT_IFACE_DISCONNECTED, nil, 0, -1)
        Ethernet.mac = [UInt8](repeating: 0x00, count: 6)
        Ethernet.txHandler = nil
    }
 }