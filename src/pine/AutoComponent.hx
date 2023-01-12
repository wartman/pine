package pine;

@:allow(pine)
@:autoBuild(pine.AutoComponentBuilder.build())
@:autoBuild(pine.core.HasComponentTypeBuilder.build())
abstract class AutoComponent extends Component {
  abstract public function render(context:Context):Component;
}
