package pine.element;

import pine.hydration.Cursor;

enum ElementInitMode {
  Normal;
  Hydrating(cursor:Cursor);
}
