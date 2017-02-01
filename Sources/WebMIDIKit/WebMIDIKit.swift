//
//  MIDIAccess.swift
//  WebMIDIKit
//
//  Created by Adam Nemecek on 12/7/16.
//
//

import CoreMIDI



public final class MIDIAccess {
//  static let sharedInstance = MIDIAccess()

  private var client: MIDIClient? = nil
  fileprivate let clients: Set<MIDIClient> = []

  let input: MIDIInput
  let inputs: [MIDIInput] = []

  let output: MIDIOutput
  let outputs: [MIDIOutput] = []

  //let clients: [MIDIClient]

  private(set) var sources: [MIDIConnection] = []

  private(set) var destinations: [MIDIEndpoint] = []

  public var onStateChange: ((MIDIPort) -> ())? = nil

  private func notification(ptr: UnsafePointer<MIDINotification>) {
    _ = MIDIObjectAddRemoveNotification(ptr: ptr).map {
      let endpoint = MIDIEndpoint(ref: $0.child)

      switch (ptr.pointee.messageID, $0.childType) {
      case (.msgObjectAdded, .source):
        if let s = (sources.first { $0.source == endpoint }) {
          todo("port.state = .connected")
          clients.forEach {
            _ in
          }
        }
        else {
          let conn = MIDIConnection(port: self.input, source: endpoint)
          self.sources.append(conn)
        }
      case (.msgObjectAdded, .destination):
        if !destinations.appendUnique(newElement: endpoint) {
          //setoutputportstate(port, opened)
        }
      case (.msgObjectRemoved, .source):
        sources = sources.filter {
          let remove = $0.source == endpoint
          if remove {
            //            $0.port.connection = .disconnected
          }
          return remove
        }
        if let _ = (sources.first { $0.source == endpoint }) {

          //setinputportstate, disconnected
        }

      case (.msgObjectRemoved, .destination):
        if destinations.contains(endpoint) {
          //setoutputportstate(d, disconnected)
        }
        else {

        }
      default: break
      }
    }
  }

  private func midi(src: MIDIEndpointRef, lst: UnsafePointer<MIDIPacketList>) {
    _ = sources.first { $0.source.ref == src }.map {
      _ in
      lst.pointee.forEach {
          packet in
      }
    }
  }

  public init() {

    // the callback ReceiveMidiNotify
    let client = MIDIClient { _ in
//            self.notification(ptr: $0)
      fatalError()

//      fatalError("stuff")
    }

    let input = MIDIInput(client: client)

    self.output = MIDIOutput(client: client)

    self.client = client
    self.input = input

    self.sources = MIDISources().map {
      //
      // connect
      //
      MIDIConnection(port: input,
                     source: MIDIEndpoint(ref: $0))
    }
    
    self.destinations = MIDIDestinations().map {
      MIDIEndpoint(ref: $0)
    }


    self.input.onMIDIMessage = {
      self.midi(src: 0, lst: $0)
    }

  }

  deinit {

  }
}


func test() {
  let access = MIDIAccess()
  let p: MIDIPacket = [1,2,3]




}






