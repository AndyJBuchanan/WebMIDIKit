//
//  Utils.swift
//  WebMIDIKit
//
//  Created by Adam Nemecek on 1/30/17.
//
//


import CoreMIDI
import AXMIDI

internal func MIDIObjectGetStringProperty(ref: MIDIObjectRef, property: CFString) -> String {
  var string: Unmanaged<CFString>? = nil
  MIDIObjectGetStringProperty(ref, property, &string)
  return (string?.takeRetainedValue())! as String
}

internal func MIDIObjectGetIntProperty(ref: MIDIObjectRef, property: CFString) -> Int {
  var val: Int32 = 0
  MIDIObjectGetIntegerProperty(ref, property, &val)
  return Int(val)
}

internal func MIDIObjectGetType(id: Int) -> MIDIObjectType {
  var ref: MIDIObjectRef = 0
  var type: MIDIObjectType = .other
  MIDIObjectFindByUniqueID(MIDIUniqueID(id), &ref, &type)
  return type
}

internal func MIDISources() -> [MIDIEndpointRef] {
  return (0..<MIDIGetNumberOfSources()).map(MIDIGetSource)
}

internal func MIDIDestinations() -> [MIDIEndpointRef] {
  return (0..<MIDIGetNumberOfDestinations()).map(MIDIGetDestination)
}

internal func MIDIInputPortCreate(ref: MIDIClientRef, readmidi: @escaping (UnsafePointer<MIDIPacketList>) -> ()) -> MIDIPortRef {
  var ref = MIDIPortRef()
  MIDIInputPortCreateWithBlock(ref, "MIDI input" as CFString, &ref) {
    packetlist, srcconref in
    readmidi(packetlist)
  }
  return ref
}

internal func MIDIOutputPortRefCreate(ref: MIDIClientRef) -> MIDIPortRef {
  var ref = MIDIPortRef()
  MIDIOutputPortCreate(ref, "MIDI output" as CFString, &ref)
  return ref
}

internal func MIDIClientCreate(name: String, callback: @escaping (UnsafePointer<MIDINotification>) -> ()) -> MIDIClientRef {
  var ref = MIDIClientRef()
  MIDIClientCreateWithBlock(name as CFString, &ref, callback)
  return ref
}

extension MIDIPacket : MutableCollection {
  public typealias Element = UInt8
  public typealias Index = Int

  public var startIndex: Index {
    return 0
  }

  public var endIndex: Index {
    return Index(length)
  }

  public subscript(index: Index) -> Element {
    get {
      return MIDIPacketGetValue(self, Int32(index))
    }
    set {
      MIDIPacketSetValue(&self, Int32(index), newValue)
    }
  }
}

extension MIDIPacket : Equatable {
  public static func ==(lhs: MIDIPacket, rhs: MIDIPacket) -> Bool {
    return (lhs.timeStamp, lhs.count) == (rhs.timeStamp, rhs.count) &&
            lhs.elementsEqual(rhs)
  }
}

extension MIDIPacket : Comparable {
  public static func <(lhs: MIDIPacket, rhs: MIDIPacket) -> Bool {
    return lhs.timeStamp < rhs.timeStamp
  }
}

extension MIDIPacket : Hashable {
  public var hashValue: Int {
    return Int(timeStamp) ^ count
  }
}

extension MIDIPacket : ExpressibleByArrayLiteral {
  public init(arrayLiteral literal: Element...) {
//      self.init()
//      todo does this work?
//      memcmp(&data, literal, literal.count/4)
      self = MIDIPacketCreate(0, literal, Int32(literal.count))
      assert(elementsEqual(literal))
  }
}

extension MIDIPacket : MutableEventType {
  public typealias Timestamp = MIDITimeStamp
  
  public var timestamp: Timestamp {
    get {
      return timeStamp
    }
    set {
      timeStamp = newValue
    }
  }
}

extension MIDIPacketList : Sequence {
	public typealias Element = MIDIPacket

	public func makeIterator() -> AnyIterator<Element> {
		var first = packet
		let s = sequence(first: &first) { MIDIPacketNext($0) }
           .prefix(Int(numPackets)).makeIterator()
		return AnyIterator { s.next()?.pointee }
	}
}

extension MIDIPacketList : Equatable {
  public static func ==(lhs: MIDIPacketList, rhs: MIDIPacketList) -> Bool {
    return lhs.numPackets == rhs.numPackets && lhs.elementsEqual(rhs)
  }
}

extension MIDIPacketList : Hashable {
  public var hashValue: Int {
    return numPackets.hashValue ^ packet.hashValue
  }
}

extension MIDIPacketList {

  var timestamp: Element.Timestamp {
    return packet.timestamp
  }
}

extension Collection where Iterator.Element == UInt8 {
  public func iterateMIDI() -> AnyIterator<MIDIPacket> {
    return AnyIterator {
      todo()
      return nil
    }
  }
}

extension MIDIPacketList : ExpressibleByArrayLiteral {
  //
  //
  //
  public init?<S: Sequence>(seq: S) where S.Iterator.Element == UInt8 {
    fatalError()
  }

  public init(arrayLiteral literal: Element...) {
    self.init()
      //validator
//    self = MIDIPacketListInit
//    MIDIPacketListInit(&self)
//    literal.forEach {
//      var p = $0
//      MIDIPacketListAdd(&self, 0, &p, 0, 0, )
//    }

    //    literal.forEach {
    //      MIDIPacketListAdd(<#T##pktlist: UnsafeMutablePointer<MIDIPacketList>##UnsafeMutablePointer<MIDIPacketList>#>, <#T##listSize: Int##Int#>, <#T##curPacket: UnsafeMutablePointer<MIDIPacket>##UnsafeMutablePointer<MIDIPacket>#>, <#T##time: MIDITimeStamp##MIDITimeStamp#>, <#T##nData: Int##Int#>, <#T##data: UnsafePointer<UInt8>##UnsafePointer<UInt8>#>)
    //    }

    //    assert(literal.count == 1, "implement with pointers")

    //    self.init(numPackets: UInt32(literal.count), packet: literal[0])
    //    self.init(numPackets: 1, packet: literal[0])

    todo("initialization")
  }
}

//extension Sequence where Iterator.Element == MIDIPacket {
//  public func flatten() -> [UInt8] {
//    return flatMap { $0 }
//  }
//}

public struct MIDIPacketListSlice : Sequence {
  public typealias Element = MIDIPacket
  public typealias Base = UnsafePointer<MIDIPacketList>
  public let base: Base

  private let range: ClosedRange<Element.Timestamp>?

  internal init(base: Base, range: ClosedRange<Element.Timestamp>? = nil) {
    self.base = base
    self.range = range

  }

  public func makeIterator() -> AnyIterator<Element> {
    return AnyIterator { nil }
  }


}

extension MIDIObjectAddRemoveNotification {
  internal init?(ptr: UnsafePointer<MIDINotification>) {
    switch ptr.pointee.messageID {
    case .msgObjectAdded, .msgObjectRemoved:
      self = ptr.withMemoryRebound(to: MIDIObjectAddRemoveNotification.self, capacity: 1) {
        $0.pointee
      }
    default: return nil
    }
  }
}




