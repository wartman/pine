Coming from React
=================

While Pine does not have hooks like React does, much of the functionality they provide are covered by other features.

Hooks like `useState` and `useReducer` can mostly be replaced with `var` properties on AutoComponents and Records.

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

class Counter extends AutoComponent {
  var count:Int = 0;

  function render(context:Context) {
    return new Html<'button'>({
      onclick: _ -> count.set(i -> i + 1),
      children: [ 'You pressed me ', new Text(count), ' times' ]
    });
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
import pine.*;
import pine.html.*;
import pine.html.client.Client;

function main() {
  mount(
    js.Browser.document.getElementById('root'),
    () -> new ChatApp({})
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

class ChatRoom extends AutoComponent {
  var roomId:String;
  var serverUrl:String = 'https://localhost:1234';

  function build() {
    effect(() -> {
      var connection = createConnection(serverUrl(), roomId());
      connection.connect();
      return () -> connection.disconnect();
    });

    return new Fragment([
      new Html<'label'>({
        children: [
          new Text('Server URL: '),
          new Html<'input'>({
            value: serverUrl,
            onchange: (e) -> serverUrl.set((cast e.target:js.html.InputElement).value)
          })
        ]
      }),
      new Text('Welcome to the '),
      new Text(roomId),
      new Text(' room')
    ]);
  }
}

class ChatApp extends AutoComponent {
  var roomId:String = 'general';
  var show:Bool = false;

  function build() {
    return new Fragment([
      new Html<'label'>({
        children: [
          new Text('Choose the chat room: '),
          new Html<'select'>({
            value: roomId,
            onchange: e -> roomId.set((cast e.target:js.html.InputElement).value),
            children: [
              new Html<'option'>({ value: 'general', children: 'general' }),
              new Html<'option'>({ value: 'travel', children: 'travel' }),
              new Html<'option'>({ value: 'music', children: 'music' })
            ]
          })
        ]
      }),
      new Html<'button'>({
        onclick: e -> show.update(showing -> !showing),
        children: [
          new Text(compute(() -> if (show()) 'Close chat' else 'Open chat'))
        ]
      }),
      new Show(show, () -> new Html<'hr'>({})),
      new Show(show, () -> new ChatRoom({ roomId: roomId }))
    ]);
  }
}

```

Pine also doesn't have a `useRef`, but because `build` methods only run once it simply doesn't need it! For example, this:

```js
import { useRef } from 'react';

export default function Counter() {
  let ref = useRef(0);

  function handleClick() {
    ref.current = ref.current + 1;
    alert('You clicked ' + ref.current + ' times!');
  }

  return (
    <button onClick={handleClick}>
      Click me!
    </button>
  );
}
```

...will just look like this in Pine:

```haxe
import pine.*;
import pine.html.*;

class Counter extends AutoComponent {
  function build() {
    var ref = { current: 0 };
    return new Html<'button'>({
      onclick: e -> {
        ref.current += 1;
        js.Browser.window.alert('You clicked ${ref.current} times!');
      },
      children: 'Click me!'
    });
  }
}
```
