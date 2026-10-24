# Macpardy! Buzzer WebSocket Protocol — v1

All WebSocket messages are JSON objects with a required top-level `type` string field
and an optional `payload` object. Unknown `type` values should be silently ignored by
both sides to allow forward compatibility.

---

## Wire format

```json
{ "type": "<type>", "payload": { ... } }
```

Messages with no payload omit the `payload` key entirely.

---

## Client → Server messages

These messages are sent by the phone browser to the Macpardy app.

### `join`

Sent immediately after the WebSocket connection opens.
The server validates the `code`; if invalid it responds with `joinRejected`
and closes the connection.

```json
{
  "type": "join",
  "version": 1,
  "code": "AB3XYZ"
}
```

| Field     | Type   | Description                                              |
|-----------|--------|----------------------------------------------------------|
| `version` | int    | Required. Protocol version the client speaks. Currently always `1`. A missing version is not decodable and the message is ignored. |
| `code`    | string | The 6-character join code shown on the host's screen.    |

---

### `pong`

Sent in response to a `ping` from the server. Resets the 5-second heartbeat TTL.

```json
{ "type": "pong" }
```

---

## Server → Client messages

These messages are sent by the Macpardy app to one or all phone browsers.

### `joinAccepted`

Sent to the joining phone after a valid join code is received.

```json
{
  "type": "joinAccepted",
  "payload": {
    "version": 1,
    "teams": ["Team 1", "Team 2", "Team 3"]
  }
}
```

| Payload field | Type     | Description                                                     |
|---------------|----------|-----------------------------------------------------------------|
| `version`     | int      | Protocol version the server is speaking. Currently always `1`.  |
| `teams`       | string[] | Ordered list of team names (empty list until sub-issue 2 lands).|

---

### `joinRejected`

Sent when the join code in the `join` message does not match or the client
protocol version is unsupported.
The connection is closed by the server after sending this.
The client should display an error and **not** attempt to reconnect.

```json
{
  "type": "joinRejected",
  "payload": {
    "reason": "Invalid join code"
  }
}
```

| Payload field | Type   | Description                          |
|---------------|--------|--------------------------------------|
| `reason`      | string | Human-readable rejection reason.     |

---

### `ping`

Heartbeat request sent by the server every 2 seconds to each connected client.
The client must respond with a `pong` within 5 seconds or it is disconnected.

```json
{ "type": "ping" }
```

---

### `state`

> **Reserved.** Defined for a later sub-issue; the server does not send it yet
> (`BuzzerState.broadcastPhase` has no caller).

Broadcast to all authenticated clients when the game phase changes.
Future sub-issues extend the payload to carry additional game context.

```json
{
  "type": "state",
  "payload": {
    "phase": "board"
  }
}
```

| Payload field | Type   | Values                                                                                       |
|---------------|--------|----------------------------------------------------------------------------------------------|
| `phase`       | string | `setup`, `board`, `question`, `answer`, `dailyDouble`, `finalMacpardyCategory`, `finalMacpardyQuestion`, `finalMacpardyAnswer` |

---

## Heartbeat sequence

```
Server                          Phone
  |                               |
  |─── ping ─────────────────────>|
  |                               |
  |<── pong ──────────────────────|   (within 5 s)
  |                               |
  | (repeat every 2 s)            |
```

If no `pong` is received within `heartbeatTTL` (5 s), the server closes the connection.
A socket that connects but never sends a valid `join` within the same TTL is also closed.

The phone runs its own watchdog: if it hears nothing from the server for 5 s (for
example Wi-Fi dropped without a TCP close), it closes the socket, shows
**"Unable to find client"**, then retries.

---

## Connection-lost behaviour

The phone page preloads an **"Unable to find client"** message and displays it
whenever the WebSocket connection closes or errors, including:

- A failed first connection (server not yet ready)
- A mid-game network drop
- The app being quit or the Mac going to sleep

The page automatically attempts to reconnect with exponential back-off
(1 s → 2 s → 4 s … max 10 s). Once reconnected it re-sends a `join` message.

---

## Version history

| Version | Changes                          |
|---------|----------------------------------|
| 1       | Initial release (issue #28). Introduces `join`, `joinRejected`, `joinAccepted`, `ping`, `pong`, `state`. |
