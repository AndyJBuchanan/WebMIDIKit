//
//  MIDIPortMap.swift
//  WebMIDIKit
//
//  Created by Adam Nemecek on 1/31/17.
//
//

import CoreMIDI

public class MIDIPortMap<Value: MIDIPort> : Collection {
  public typealias Key = String
  public typealias Index = Dictionary<Key, Value>.Index

  private var content: [Key: Value]

//  public init() {
//    content = [:]
//  }

  public var startIndex: Index {
    return content.startIndex
  }

  public var endIndex: Index {
    return content.endIndex
  }

  public subscript (key: Key) -> Value? {
    get {
      return content[key]
    }
    //
    // this is called by the notification handler in midiaccess
    //
    set {
      content[key] = newValue
    }
  }

  public subscript(index: Index) -> (Key, Value) {
    return content[index]
  }

  public func index(after i: Index) -> Index {
    return content.index(after: i)
  }

//  public var description: String {
//    return dump(self).description
//  }

  internal let client: MIDIClient

  internal init(client: MIDIClient) {
    self.client = client
    content = [:]
  }
  //
  // todo should this be doing key, value?
  //
  internal subscript (endpoint: MIDIEndpoint) -> Value? {
    get {
      return content.first { $0.value.endpoint == endpoint }?.value
    }
    set {
      _ = (newValue ?? self[endpoint]).map {
        self[String($0.id)] = newValue
      }
    }
  }
//  public init(arrayLiteral literal: Value...) {
//
//  }
}


public class MIDIInputMap : MIDIPortMap<MIDIInput> {
  internal override init(client: MIDIClient) {
    super.init(client: client)
    MIDISources().forEach {
      self[$0] = MIDIInput(client: client, endpoint: $0)
    }
  }
}

public class MIDIOutputMap : MIDIPortMap<MIDIOutput> {
  internal override init(client: MIDIClient) {
    super.init(client: client)
    MIDIDestinations().forEach {
      self[$0] = MIDIOutput(client: client, endpoint: $0)
    }
  }
}

//
//extension MIDIPortMap where Value: Equatable {
//
//}
