Coming from React
=================

While Pine does not have hooks like React does, much of the functionality they provide are covered by other features.

Hooks like `useState` and `useReducer` can mostly be replaced with `@:signal`, `@:observable` and `@:computed` properties on AutoComponents and Records.

Taking this example from the React website:

```js
import { useState } from 'react';

export default function Counter() {
  const [count, setCount] = useState(0);

  function handleClick() {
    setCount(count + 1);
  }

  return (
    <button onClick={handleClick}>
      You pressed me {count} times
    </button>
  );
}
```

...a similar component in Pine would look like this:

```haxe
import pine.*;
import pine.html.*;

class Counter extends Component {
  var count:Int = 0;

  function render() {
    return Html.button()
      .on(Click, _ -> count.set(i -> i + 1))
      .children('You pressed me ', count.map(Std.string), ' times');
  }
}
```

Take this (rather long) example from the [React docs](https://beta.reactjs.org/reference/react/useEffect):

```js
import { useState, useEffect } from 'react';

function createConnection(serverUrl, roomId) {
  // A real implementation would actually connect to the server
  return {
    connect() {
      console.log('✅ Connecting to "' + roomId + '" room at ' + serverUrl + '...');
    },
    disconnect() {
      console.log('❌ Disconnected from "' + roomId + '" room at ' + serverUrl);
    }
  };
}

function ChatRoom({ roomId }) {
  const [serverUrl, setServerUrl] = useState('https://localhost:1234');

  useEffect(() => {
    const connection = createConnection(serverUrl, roomId);
    connection.connect();
    return () => {
      connection.disconnect();
    };
  }, [roomId, serverUrl]);

  return (
    <>
      <label>
        Server URL:{' '}
        <input
          value={serverUrl}
          onChange={e => setServerUrl(e.target.value)}
        />
      </label>
      <h1>Welcome to the {roomId} room!</h1>
    </>
  );
}

export default function App() {
  const [roomId, setRoomId] = useState('general');
  const [show, setShow] = useState(false);
  return (
    <>
      <label>
        Choose the chat room:{' '}
        <select
          value={roomId}
          onChange={e => setRoomId(e.target.value)}
        >
          <option value="general">general</option>
          <option value="travel">travel</option>
          <option value="music">music</option>
        </select>
      </label>
      <button onClick={() => setShow(!show)}>
        {show ? 'Close chat' : 'Open chat'}
      </button>
      {show && <hr />}
      {show && <ChatRoom roomId={roomId} />}
    </>
  );
}
```

In Pine, this might look something like:

```haxe
package chat;

import pine.*;
import pine.html.*;
import pine.html.client.Client;

// Implements this example from React:
// https://beta.reactjs.org/reference/react/useEffect

function main() {
  mount(
    js.Browser.document.getElementById('root'),
    () -> ChatApp.build({})
  );
}

typedef Connection = {
  connect:()->Void,
  disconnect:()->Void
} 

function createConnection(serverUrl:String, roomId:String):Connection {
  // A real implementation would actually connect to the server
  return {
    connect: () -> {
      trace('✅ Connecting to "$roomId" room at $serverUrl...');
    },
    disconnect: () -> {
      trace('❌ Disconnected from "$roomId" room at $serverUrl');
    }
  };
}

class ChatRoom extends Component {
  @:signal final roomId:String;
  @:signal final serverUrl:String = 'https://localhost:1234';

  function render() {
    var connection:Null<Connection> = null;

    addDisposable(() -> connection?.disconnect());

    Observer.track(() -> {
      connection?.disconnect();
      connection = createConnection(serverUrl(), roomId());
      connection.connect();
    });

    return Fragment.of(
      Html.label().children(
        'Server URL: ',
        Html.input().attr('value', serverUrl).on(Change, e -> serverUrl.set((cast e.target:js.html.InputElement).value))
      ),
      'Welcome to the ', roomId, ' room'
    );
  }
}

class ChatApp extends Component {
  @:signal final roomId:String = 'general';
  @:signal final show:Bool = false;

  function render() {
    return Fragment.of(
      Html.label().children(
        'Choose the chat room: ',
        Html.select().attr('value', roomId).on(Change, e -> roomId.set((cast e.target:js.html.InputElement).value).children(
          Html.option().attr('value', 'general').children('general'),
          Html.option().attr('value', 'travel').children('travel'),
          Html.option().attr('value', 'music').children('music')
        )
      ),
      Html.button().on(Click, e -> show.update(showing -> !showing)).children(
        Show.when(show, () -> 'Close chat').otherwise(() -> 'Open chat')
      ),
      Show.when(show, Html.hr())
      Show.when(show, ChatRoom.build({ roomId: roomId }))
    );
  }
}
```
