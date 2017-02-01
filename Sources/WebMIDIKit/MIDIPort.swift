//
//  WebMIDI.swift
//  WebMIDIKit
//
//  Created by Adam Nemecek on 12/6/16.
//
//

import CoreMIDI

fileprivate struct MIDIPortState: Equatable {
  let state: MIDIPortDeviceState, connection: MIDIPortConnectionState

  static func ==(lhs: MIDIPortState, rhs: MIDIPortState) -> Bool {
    return (lhs.state, lhs.connection) == (rhs.state, rhs.connection)
  }
}

//typealias Sink<T> = (T) -> ()

//typealias Source<T> = () -> T

///
/// https://www.w3.org/TR/webmidi/#midiport-interface
///

public class MIDIPort: Hashable, Comparable, CustomStringConvertible, EventTarget {
  //todo this isn't an int
  public typealias Event = Int

  public var id: Int {
    return self[int: kMIDIPropertyUniqueID]
  }

  public var manufacturer: String {
    return self[string: kMIDIPropertyManufacturer]
  }

  public var name: String {
    return self[string: kMIDIPropertyDisplayName]
  }

  public var type: MIDIPortType {
    return MIDIPortType(MIDIObjectGetType(id: id))
  }

  public var version: Int {
    return self[int: kMIDIPropertyDriverVersion]
  }

  public private(set) var state: MIDIPortDeviceState = .disconnected
  public private(set) var connection: MIDIPortConnectionState = .closed
  public var onStateChange: EventHandler<Event> = nil

  public func open(_ eventHandler: EventHandler<MIDIPort> = nil) {
    guard connection != .open else { return }
    connection = .open
    eventHandler?(self)
  }

  public func close(_ eventHandler: EventHandler<MIDIPort> = nil) {
    guard connection != .closed else { return }
    connection = .closed
    onStateChange = nil
    eventHandler?(self)
  }

  public var hashValue: Int {
    return ref.hashValue
  }

  public static func ==(lhs: MIDIPort, rhs: MIDIPort) -> Bool {
    return lhs.ref == rhs.ref
  }

  public static func <(lhs: MIDIPort, rhs: MIDIPort) -> Bool {
    return lhs.ref < rhs.ref
  }

  public var description: String {
    return "Manufacturer: \(manufacturer)\n" +
           "Name: \(name)\n" +
           "Version: \(version)\n" +
           "Type: \(type)\n"
  }

  internal private(set) var ref: MIDIPortRef
  //todo: should this be weak?
  internal let access: MIDIAccess

  internal init(ref: MIDIPortRef = 0) {
    self.ref = ref
    todo("initportstate")
  }

  internal init(access: MIDIAccess/*port state*/) {
    self.access = access
    todo("initportstate")
  }

//  internal init(input client: MIDIClient) {
//    self.ref = 0
//    self.ref = MIDIInputPortCreate(ref: client.ref) {
//      _ in
//    }
//
////    todo("initportstate")
//  }

  private subscript(string property: CFString) -> String {
    return MIDIObjectGetStringProperty(ref: ref, property: property)
  }

  private subscript(int property: CFString) -> Int {
    return MIDIObjectGetIntProperty(ref: ref, property: property)
  }


  //
  // TODO: when is this set again
  //

//  private var _portState: MIDIPortState {
//    didSet {
//      guard _portState != oldValue else { return }
//      todo("dispatch connection event")
//    }
//  }
}





