//=== BoardId.swift -------------------------------------------------------===//
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
public struct Id: RawRepresentable, Sendable {
  public var rawValue: Int32

  public init(rawValue: Int32) {
    self.rawValue = rawValue
  }
}