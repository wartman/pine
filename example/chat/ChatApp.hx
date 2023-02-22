package chat;

import pine.*;
import pine.html.*;
import pine.html.client.*;

function main() {
  ClientRoot.mount(
    js.Browser.document.getElementById('root'),
    new ChatApp({})
  );
}

function createConnection(serverUrl:String, roomId:String) {
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

  function render(context:Context) {
    var child = new Fragment({
      children: [
        new Html<'label'>({
          children: [
            new Text('Server URL: '),
            new Html<'input'>({
              value: serverUrl,
              onchange: (e) -> serverUrl = (cast e.target:js.html.InputElement).value
            })
          ]
        }),
        new Text('Welcome to the $roomId room')
      ]
    });

    return new Effect({
      effect: () -> {
        var connection = createConnection(serverUrl, roomId);
        connection.connect();
        return () -> connection.disconnect();
      },
      child: child
    });
  }
}

class ChatApp extends AutoComponent {
  var roomId:String = 'general';
  var show:Bool = false;

  function render(context:Context) {
    return new Fragment({
      children: [
        new Html<'label'>({
          children: [
            new Text('Choose the chat room: '),
            new Html<'select'>({
              value: roomId,
              onchange: e -> roomId = (cast e.target:js.html.InputElement).value,
              children: [
                new Html<'option'>({ value: 'general', children: 'general' }),
                new Html<'option'>({ value: 'travel', children: 'travel' }),
                new Html<'option'>({ value: 'music', children: 'music' })
              ]
            })
          ]
        }),
        new Html<'button'>({
          onclick: e -> show = !show,
          children: if (show) 'Close chat' else 'Open chat'
        }),
        if (show) new Html<'hr'>({}) else null,
        if (show) new ChatRoom({ roomId: roomId }) else null
      ]
    });
  }
}
