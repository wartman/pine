package pine.component;

import pine.internal.AttributeHost;

enum abstract InputType(String) {
  final Text = 'text';
  final Button = 'button';
  final Checkbox = 'checkbox';
  final Color = 'color';
  final Date = 'date';
  final DateTimeLocal = 'datetime-local';
  final Email = 'email';
  final File = 'file';
  final Hidden = 'hidden';
  final Image = 'image';
  final Month = 'month';
  final Number = 'number';
  final Password = 'password';
  final Radio = 'radio';
  final Range = 'range';
  final Reset = 'reset';
  final Search = 'search';
  final Tel = 'tel';
  final Submit = 'submit';
  final Time = 'time';
  final Url = 'url';
  final Week = 'week';
}

class Input extends AutoComponent implements AttributeHost {
  @:observable @:attr final type:InputType = Text;
  @:observable @:attr final value:Null<String> = null;
  @:observable @:attr final checked:Null<Bool> = null;
  @:observable @:attr('autofocus') final autoFocus:Null<Bool> = null; 
	final children:Children;
  
  function build():Component {
    return new ObjectComponent({
      createObject: (adaptor, attrs) -> adaptor.createInputObject(attrs),
      attributes: getAttributes(),
      children: children
    });
  }
}
