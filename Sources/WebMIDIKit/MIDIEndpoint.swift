//
//  MIDIEndpoint.swift
//  WebMIDIKit
//
//  Created by Adam Nemecek on 2/2/17.
//
//

import CoreMIDI

//
// you can think of this as the HW port
//

internal struct MIDIEndpoint : Equatable, Comparable, Hashable {
  let ref: MIDIEndpointRef

  init(ref: MIDIEndpointRef = MIDIEntityRef()) {
    self.ref = ref
  }

  var hashValue: Int {
    return ref.hashValue
  }

  static func ==(lhs: MIDIEndpoint, rhs: MIDIEndpoint) -> Bool {
    return lhs.id == rhs.id
  }

  static func <(lhs: MIDIEndpoint, rhs: MIDIEndpoint) -> Bool {
    return lhs.id < rhs.id
  }

  //todo
  var isVirtual: Bool {
    return ref == 0
  }

  var id: Int {
    return self[int: kMIDIPropertyUniqueID]
  }

  var manufacturer: String {
    return self[string: kMIDIPropertyManufacturer]
  }

  /// The system name of the port.
  var name: String {
    return self[string: kMIDIPropertyName]
  }

  var type: MIDIPortType {
    return MIDIPortType(MIDIObjectGetType(id: id))
  }

  var version: Int {
    return self[int: kMIDIPropertyDriverVersion]
  }

  private subscript(string property: CFString) -> String {
    return MIDIObjectGetStringProperty(ref: ref, property: property)
  }

  private subscript(int property: CFString) -> Int {
    return MIDIObjectGetIntProperty(ref: ref, property: property)
  }
}
