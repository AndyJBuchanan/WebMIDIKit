//
//  MIDIInput.swift
//  WebMIDIKit
//
//  Created by Adam Nemecek on 1/31/17.
//
//

import CoreMIDI


//protocol EventHandler {
//  func handleEvent()
//}

//public protocol MIDIReceiver {
//  //todo
//  var onMIDIMessage: EventHandler<UnsafePointer<MIDIPacketList>> { get set }
//}

public final class MIDIInput: MIDIPort { //, MIDIReceiver {

  public var onMIDIMessage: EventHandler<UnsafePointer<MIDIPacketList>> = nil {
    didSet {
      open()
    }
  }

  //todo ref var

  internal override init(access: MIDIAccess) {
    super.init(access: access)
//    self.ref = MIDIInputPortCreate(ref: client.ref) { packet in
//      self.onMIDIMessage.map { $0(packet) }
//    }
  }

  internal func connect() {
    
  }


}
