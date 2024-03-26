package pine.component;

class Carousel extends Component {
  @:attribute final className:String = null;
  @:attribute final duration:Int = 200;
  @:attribute final dragClamp:Int = 50;
  @:attribute final initialIndex:Int = 0;
  @:attribute final onlyShowActiveSlides:Bool = false;
  @:attribute final controls:(carousel:CarouselContext)->Child = null;
  @:children @:attribute final slides:Array<CarouselSlide>;

  function render():Child {
    var slides = [ for (index => child in slides) child.build(index) ];
    var context = new CarouselContext(slides, initialIndex, {
      onlyShowActiveSlides: onlyShowActiveSlides
    });

    return Provider
      .provide(context)
      .children([
        CarouselViewport.build({
          className: className,
          duration: duration,
          dragClamp: dragClamp,
          // @todo: This is a weird hack to cast slides into Children
          children: [ for (slide in slides) (slide:View) ]
        }),
        controls != null ? controls(context) : null
      ]);
  }
}
