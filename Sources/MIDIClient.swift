//
//  MIDIClient.swift
//  WebMIDIKit
//
//  Created by Adam Nemecek on 12/13/16.
//
//

import AVFoundation

internal final class MIDIClient: Comparable, Hashable {
    let ref: MIDIClientRef

    internal init(callback: @escaping (UnsafePointer<MIDINotification>) -> ()) {
        self.ref = MIDIClientCreate(name: "WebMIDIKit") { callback($0) }
    }

    deinit {
        MIDIClientDispose(ref)
    }

    internal var hashValue: Int {
        return ref.hashValue
    }

    internal static func ==(lhs: MIDIClient, rhs: MIDIClient) -> Bool {
        return lhs.ref == rhs.ref
    }

    internal static func <(lhs: MIDIClient, rhs: MIDIClient) -> Bool {
        return lhs.ref < rhs.ref
    }
}

protocol MIDIReceiver {
  func receiveMIDI()
}

public struct MIDIInputMap: MutableCollection {
  public typealias Element = MIDIOutput
  public typealias Index = Dictionary<String, Element>.Index

  private var content: [String: MIDIOutput]

  public var startIndex: Index {
    return content.startIndex
  }

  public var endIndex: Index {
    return content.endIndex
  }

  public subscript (index: Index) -> Element? {
//    return content[index]
    get {
      fatalError()
    }
    set {
    }
  }

  public func index(after i: Index) -> Index {
    return content.index(after: i)
  }

}
