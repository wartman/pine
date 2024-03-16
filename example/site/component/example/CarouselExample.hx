package site.component.example;

import ex.*;
import pine.component.*;

class CarouselExample extends Component {
  function render() {
    return Carousel.build({
      className: Breeze.compose(
        Sizing.width('full'),
        Sizing.height(50),
      ),
      onlyShowActiveSlides: true,
      slides: [ 'foo', 'bar', 'bin', 'bax', 'bif', 'barf' ].map(item -> CarouselSlide.wrap(carousel -> Panel.build({
        styles: Breeze.compose(
          Sizing.height(50),
          Layout.position('relative'),
          Layout.attach('top', 0),
          Layout.layer(1),
          Sizing.width('full'),
          Typography.fontSize('6xl'),
          Typography.fontWeight('bold'),
          Flex.display(),
          Flex.alignItems('center'),
          Flex.justify('center'),
          Interactive.cursor('grab')
        ),
        children: item
      }))).concat([
        // No need to use `Slide.wrap` unless you want to:
        carousel -> Panel.build({ 
          styles: Breeze.compose(
            Sizing.height(50),
            Layout.position('relative'),
            Layout.attach('top', 0),
            Layout.layer(1),
            Sizing.width('full'),
            Typography.fontSize('6xl'),
            Typography.fontWeight('bold'),
            Typography.textColor('white', 0),
            Background.color('black', 0),
            Flex.display(),
            Flex.alignItems('center'),
            Flex.justify('center')
          ),
          children: 'End'
        })
      ]),
      controls: carousel -> Html.div()
        .style(Breeze.compose(
          Flex.display(),
          Flex.gap(3)
        ))
        .children(
          Button.build({
            action: () -> carousel.previous(),
            child: 'Previous'
          }),
          Button.build({
            action: () -> carousel.next(),
            child: 'Next'
          })
        )
    });
  }
}