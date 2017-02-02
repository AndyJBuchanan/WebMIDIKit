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

  internal init(access: MIDIAccess) {
    super.init(access: access, ref: 0)
  }

  final override public func open(_ eventHandler: ((MIDIPort) -> ())? = nil) {
    super.open {
      self.ref = MIDIInputPortCreate(ref: self.access.client!.ref) {
        self.onMIDIMessage?($0)
      }

      eventHandler?($0)
    }
  }

  final override public func close(_ eventHandler: ((MIDIPort) -> ())? = nil) {
    super.close {
      eventHandler?($0)
    }
  }

  deinit {

  }
}
