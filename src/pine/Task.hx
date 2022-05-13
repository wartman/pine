package pine;

enum Task<Data, Error> {
  Suspended;
  Ready(data:Data);
  Failed(error:Error);
}
