package pine2;

class Scope extends ProxyComponent {
  final buildWithContext:(context:Component)->Component;
  
  public function new(props:{
    build:(context:Component)->Component
  }) {
    this.buildWithContext = props.build;
  }

  function build():Component {
    return buildWithContext(this);
  }
}
