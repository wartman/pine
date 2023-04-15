package chat;

import pine.*;
import pine.html.*;
import pine.html.client.Client;

// Implements this example from React:
// https://beta.reactjs.org/reference/react/useEffect

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
  @:signal final roomId:String;
  @:signal final serverUrl:String = 'https://localhost:1234';

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
  @:signal final roomId:String = 'general';
  @:signal final show:Bool = false;

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
