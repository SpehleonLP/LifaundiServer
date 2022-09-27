# LifaundiServer
Example Webserver for lifaundi.  This repo contains documentation for how to create a webserver for lifaundi and some examples will be added later.

# Basics

Lifaundi uses the [IXWebSocket](https://github.com/machinezone/IXWebSocket) library to manage it's networking; but any kind of websocket library should work so long as it supports subprotocols. The engine supports two kinds of protocols: Hash protocols and custom protocols. The hash protocols are built ins such as `#GENETICS_KIT`, `#MOUSE_DEBUG` and `#PARTICLE`.  While custom protocols are script defined.

## Connecting as a client:

When the game starts it will try to start listening to incoming websocket connections on port 34013, this requires that no other programs have this port in use, then to connect from javascript for example use: `WebSocket("ws://localhost:34013/", [protocol])`. Then engine will automatically reject any incoming connections that are not from localhost--it checks for localhost on both ipv4 and ipv6 standards.

## Custom protocol example:

Here's a basic example of an echo protocol:

```
class Echo
{
	Network::WebSocket me;

	[190]
	void OnOpened()	{ Println("Open Socket"); }

	[191]
	void OnClosed(Network::Closed )	{ Println("Closed Socket"); me.kill();	}

	[192]
	void OnError(Network::Error) { Println("Connetion Error"); }

	[193]
	void OnMessageRecieved(dictionary@ message, uint8[]@ buffer) { me.send(@message); }
}
```

If this class is in a Package `Package` by author `Author` then it would use the websocket subprotocol: `Package@Author$Echo`. Connecting to this subprotocol as a client will spawn an object of this class to handle the protocol; conversely to connect from the engine to the server `my.url.com` at port `34013` then: *from inside the package where the protocol was declared* use `Network::Connect("wss://my.url.com:34013", "Echo")`

# Message formatting

Websockets send both binary and text mode messages, and both incoming and outgoing messages use identical formats; for text mode messages the format must be a properly formatted JSON file.  For binary messages the format is of a header followed by two chunks; the offset of the second chunk being immediately after the first chunk finishes.  If the binary message is improperly formatted the socket will be closed.

### Header 

| Type | Name | Description |
| ---------- | ---------- | ---------- |
| char[4] | Magic | Should equal "LFNT" |
| uint32 | Sanity | Should equal 2, ensures that the data is little endian |
| uint32 | Byte Length | Should equal the length in the websocket message header, as well as the length of the start of the second chunk's data + it's byte length |

### Chunk 

| Type | Name | Description |
| ---------- | ---------- | ---------- |
| char[4] | Type | Should equal "JSON", "CBOR", or "BIN\0" |
| uint32 | Byte Length | The size of this chunk in bytes |
| uint8[] | Data | JSON CBOR or a binary blob depending on the chunk header |

The first chunk must be either `JSON` or `CBOR`, and the second chunk must be `BIN\0`


