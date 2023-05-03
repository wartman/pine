import async.Suspense.suspense;
import chat.ChatApp.chatApp;
import counter.Counter.counter;
import counter.GlobalCounter.globalCounter;
import hydrate.Hydrate.hydrate;
import todo.Todo.todo;

function main() {
  todo();
  hydrate();
  chatApp();
  counter();
  globalCounter();
  suspense();
}