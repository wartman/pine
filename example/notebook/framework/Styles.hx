package notebook.framework;

using Nuke;

class Styles {
  public static final rounded = Css.atoms({
    borderRadius: 1.rem(),
    padding: 1.rem()
  });
  public static final roundedSm = Css.atoms({
    borderRadius: .5.rem(),
    padding: .5.rem()
  });
  public static final gapBottom = Css.atoms({
    marginBottom: 1.rem()
  });
  public static final flex = Css.atoms({ 
    display: 'flex' 
  });
  public static final bgWhite = Css.atoms({
    backgroundColor: '#e2e2e2',
    color: '#1f1f1f'
  });
  public static final bgDark = Css.atoms({
    backgroundColor: '#1f1f1f',
    color: '#e2e2e2'
  });
}
