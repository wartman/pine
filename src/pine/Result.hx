package pine;

enum Result<Data, Error> {
  Suspended;
  Ready(data:Data);
  Failed(error:Error);
}
