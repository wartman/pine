import medic.Runner;
import unit.*;

function main() {
  var runner = new Runner();
  
  runner.add(new TestFragment());

  runner.run();
}