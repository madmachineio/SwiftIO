//=== BoardProtocol.swift -------------------------------------------------===//
//
// Copyright (c) MadMachine Limited
// Licensed under MIT License
//
// Authors: Andy Liu
// Created: 05/09/2021
//
// See https://madmachine.io for more information
//
//===----------------------------------------------------------------------===//

/// The protocol for pin ids on your board.
public protocol IdName {
  var value: Int32 { get }
}
