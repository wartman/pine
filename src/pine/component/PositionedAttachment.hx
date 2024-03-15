package pine.component;

typedef PositionedAttachment = {
  public final h:PositionedAttachmentHorizontal;
  public final v:PositionedAttachmentVertical;
}

enum PositionedAttachmentVertical {
  Top;
  Bottom;
  Middle;
}

enum PositionedAttachmentHorizontal {
  Left;
  Right;
  Middle;
  MatchLeft;
  MatchRight;
}
