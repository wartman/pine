package pine.component;

class Popover extends Component {
  @:attribute final attachment:PositionedAttachment;
  @:attribute final gap:Int = 0;
  @:attribute final getTarget:Null<()->Dynamic> = null;
  @:children @:attribute final child:Child;

  function render():Child {
    var target = PortalContext.from(this).target;
    return Portal.into(target, () -> Positioned.build({
      getTarget: getTarget ?? () -> this.findNearestPrimitive(),
      gap: gap,
      attachment: attachment,
      child: child
    }));
  }
}
