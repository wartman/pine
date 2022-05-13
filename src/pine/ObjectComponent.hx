package pine;

abstract class ObjectComponent extends Component {
  abstract public function getChildren():Array<Component>;

  abstract public function createObject(root:Root):Dynamic;

  abstract public function updateObject(root:Root, object:Dynamic, ?previousComponent:Component):Dynamic;
}
