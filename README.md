# WebMIDIKit: Simplest Swift MIDI library

###__[Want to learn audio synthesis, sound design and making cool sounds in an afternoon? Check out Syntorial!](http://www.syntorial.com/#a_aid=AudioKit)__

## About

### What's MIDI 

[MIDI](https://en.wikipedia.org/wiki/MIDI) is a standard governing music software and music device interconnectivity. It lets you make music by sending and receiving between applications and devices.

### What's WebMIDI

[WebMIDI](https://webaudio.github.io/web-midi-api/) is a browser API standard that brings the MIDI technology to the web. WebMIDI is minimal, it only describes MIDI port selection, receiving data from input ports and sending data to output ports. [WebMIDI is currently implemented in Chrome & Opera](http://caniuse.com/#feat=midi). Note that WebMIDI is relatively low level as messages are still represented as sequences of UInt8s (bytes/octets).

### What's WebMIDIKit
WebMIDIKit is an implementation of the WebMIDI API for macOS/iOS. On these OS, the native framework for working with MIDI is [CoreMIDI](https://developer.apple.com/reference/coremidi).
CoreMIDI is old and the API is entirely in C (💩). Using it involves a lot of void pointer casting (💩^9.329 ), and other unspeakable things. Furthermore, some of the APIs didn't quite survive the transition to Swift and are essentially unusable in Swift (`MIDIPacketList` APIs, I'm looking at you).

CoreMIDI is also extremely verbose and error prone. Selecting an input port and receiving data from it is __~80 lines__ of [convoluted Swift code](http://mattg411.com/coremidi-swift-programming/). __WebMIDIKit let's you do it in 1.__ 

WebMIDIKit is a part of the [AudioKit](https://githib.com/audiokit/audiokit) project and will eventually replace [AudioKit's MIDI implementation](https://github.com/audiokit/AudioKit/tree/master/AudioKit/Common/MIDI).

Also note that WebMIDIKit adds some APIs which aren't a part of the standard. These are marked as non-standard in the code base.

##Usage

###Check out the [sample project](https://github.com/adamnemecek/WebMIDIKitDemo).

###Selecting an input port and receiving MIDI messages

```swift
import WebMIDIKit

/// represents the MIDI session
let midi: MIDIAccess = MIDIAccess()

/// prints all MIDI inputs available to the console and asks the user which port they want to select
let inputPort: MIDIInput? = midi.inputs.prompt()

/// Receiving MIDI events 
/// set the input port's onMIDIMessage callback which gets called when the port receives MIDI packets
inputPort?.onMIDIMessage = { packet: MIDIPacket) in 
	print("received \(packet)")
}

```


###Selecting an output port and sending MIDI packets to it
```swift
/// select an output port
let outputPort: MIDIOutput? = midi.outputs.prompt()

/// send messages to it
outputPort.map {

	/// send note on message
	/// the bytes are  MIDI message format (https://www.midi.org/specifications/item/table-1-summary-of-midi-message)
	/// i.e. you have to send two events, a note on event and a note off event to play a single note
	/// the format is as follows:
	/// byte0 = message type (0x90 = note on, 0x80 = note off)
	/// byte1 = the note played (0x60 = C8, see http://www.midimountain.com/midi/midi_note_numbers.html)
	/// byte2 = velocity (how loud the note should be 127 (=0x7f) is max, 0 is min)
	$0.send([0x90, 0x60, 0x7f])

	/// send note off message 1000 ms (1 second) later
	$0.send([0x80, 0x60, 0x7f], offset: 1000)

	/// in WebMIDIKit, you can also chain these
	$0.send([0x90, 0x60, 0x7f])
	  .send([0x80, 0x60, 0x7f], offset: 1000)
}
```

If the port you want to select has a corresponding input port you can also do

```swift
let outputPort: MIDIOutput? = midi.output(for: inputPort)
```


```swift
let inputPort2?: MIDIOutput? = midi.input(for: outputPort)
```

###Looping over ports

Port maps are dictionary like collections of MIDIInputs or MIDIOutputs that are indexed with the port's id. As a result, you cannot index into them like you would into an array (the reason for this being that the endpoints can be added and removed so you cannot reference them by their index).
```swift
for (id, port) in midi.inputs {
	print(id, port)
}
```



## Installation

Use Swift Package Manager. The corresponding .Package into your dependencies.
```swift
import PackageDescription

let packet = Package(
	name: "...",
	target: [],
	dependencies: [
		// ...
		.Package(url:"https://github.com/adamnemecek/webmidikit", version: 1)
	]
)
```

## Documentation

###MIDIAccess
Represents the MIDI session. See [spec](https://www.w3.org/TR/webmidi/#midiaccess-interface).

```swift
class MIDIAccess {

	var inputs: MIDIInputMap { get }
	var outputs: MIDIOutputMap { get }

	// will be called if a port changes either connection state or 
	var onStateChange: ((MIDIPort) -> ())? = nil { get set }

	init()
	
	/// given an output, tries to find the corresponding input port
	func input(for port: MIDIOutput) -> MIDIInput?
	
	/// given an input, tries to find the corresponding output port
	func output(for port: MIDIInput) -> MIDIOutput?
}
```

### MIDIPort

See [spec](https://www.w3.org/TR/webmidi/#midiport-interface). Represents the base class of MIDIInput and MIDIOutput.

Note that you don't construct MIDIPorts and it's subclasses yourself, you only get them from the MIDIAccess object. Also note that you are only ever dealt with subclasses (MIDIInput or MIDIOutput) never MIDIPort itself directly.

```
class MIDIPort {

    var id: Int { get }
    var manufacturer: String { get }

    var name: String { get }

	/// .input (for MIDIInput) or .output (for MIDIOutput)
    var type: MIDIPortType { get }

	var version: Int { get }

	/// .connected or .disconnected,
	/// indicates if the port's endpoint is connected or not
	var state: MIDIPortDeviceState { get }

	/// .open, .closed (or pending but that's not used in WebMIDIKit)
    var connection: MIDIPortConnectionState { get }

	/// open the port, is called implicitly when MIDIInput's onMIDIMessage is set or MIDIOutputs' send is called
	func open()

	/// closes the port
	func close()
}
```

### MIDIInput

See [spec](https://www.w3.org/TR/webmidi/#midiinput-interface).

```swift
class MIDIInput: MIDIPort {
	///  will get called when the port receives any messages.
	var onMIDIMessage: ((MIDIPacket) -> ())? = nil
}
```


### MIDIOutput


See [spec](https://www.w3.org/TR/webmidi/#midioutput-interface).
```swift
class MIDIOutput: MIDIPort {

	/// send data to port, note that unline the WebMIDI API, the last parameter specifies offset from now, when the event should be scheduled
	/// the unit remains milliseconds though.
	func send<S: Sequence>(_ data: S, offset: Timestamp = 0) -> MIDIOutput where S.Iterator.Element == UInt8
	
	// clear all scheduled but yet undelivered midi events
	func clear()
}
```




