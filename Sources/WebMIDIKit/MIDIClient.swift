//
//  MIDIClient.swift
//  WebMIDIKit
//
//  Created by Adam Nemecek on 12/13/16.
//
//

import Foundation
import CoreMIDI

internal extension Notification.Name {
  static let MIDISetupNotification = Notification.Name(rawValue: "\(MIDIObjectAddRemoveNotification.self)")
}


fileprivate func MIDIClientCreate(callback: @escaping (UnsafePointer<MIDINotification>) -> ()) -> MIDIClientRef {
  var ref = MIDIClientRef()
  MIDIClientCreateWithBlock("WebMIDIKit" as CFString, &ref, callback)
  return ref
}

/// on endpoint add/remove
fileprivate func MIDIClientCreateExt(callback: @escaping (MIDIObjectAddRemoveNotification) -> ()) -> MIDIClientRef {
  return MIDIClientCreate {
    _ = MIDIObjectAddRemoveNotification(ptr: $0).map(callback)
  }
}


/// Kind of like a session, context or handle, it doesn't really do anything
/// besidesbeing passed around.
internal final class MIDIClient : Equatable, Comparable, Hashable {
  let ref: MIDIClientRef

  internal init() {
    ref = MIDIClientCreateExt {
      NotificationCenter.default.post(name: .MIDISetupNotification, object: $0)
    }
  }

  deinit {
    MIDIClientDispose(ref)
  }

  var hashValue: Int {
    return ref.hashValue
  }

  static func ==(lhs: MIDIClient, rhs: MIDIClient) -> Bool {
    return lhs.ref == rhs.ref
  }

  static func <(lhs: MIDIClient, rhs: MIDIClient) -> Bool {
    return lhs.ref < rhs.ref
  }
}



