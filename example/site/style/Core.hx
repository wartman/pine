package site.style;

final centered = Breeze.compose(
  Spacing.margin('x', 'auto'),
  Spacing.pad('y', 3),
  Breakpoint.viewport('900px',
    Sizing.width('max', '900px')
  )
);
