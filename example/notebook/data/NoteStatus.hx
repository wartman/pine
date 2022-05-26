package notebook.data;

enum abstract NoteStatus(String) to String {
  final Completed;
  final Draft;
  final Deleted;
}