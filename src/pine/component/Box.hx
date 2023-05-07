package pine.component;

import pine.internal.AttributeHost;

class Box extends AutoComponent implements AttributeHost {
  @:observable @:attr('class') final styles:Null<String> = null;
  @:observable @:attr final onFocus:Null<(e:Dynamic)->Void> = null;
  final children:Children = [];

  function build() {
    return new ObjectComponent({
      createObject: (adaptor, attrs) -> adaptor.createContainerObject(attrs),
      attributes: getAttributes(),
      children: children
    });
  }
}
