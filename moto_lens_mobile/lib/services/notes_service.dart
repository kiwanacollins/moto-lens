import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

/// Local notes service using SharedPreferences
///
/// Stores notes locally on the device for quick note-taking.
/// No backend sync — all data stays on the device.
class NotesService {
  static const String _storageKey = 'gcm_local_notes';

  /// Singleton instance
  static final NotesService _instance = NotesService._();
  factory NotesService() => _instance;
  NotesService._();

  List<Note>? _cachedNotes;

  /// Get all notes sorted by most recent first
  Future<List<Note>> getNotes() async {
    if (_cachedNotes != null) return List.from(_cachedNotes!);
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      _cachedNotes = [];
      return [];
    }
    _cachedNotes = Note.decodeList(jsonString);
    _cachedNotes!.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.from(_cachedNotes!);
  }

  /// Save a new note
  Future<Note> addNote({required String title, required String content}) async {
    final note = Note.create(title: title, content: content);
    final notes = await getNotes();
    notes.insert(0, note);
    await _persist(notes);
    return note;
  }

  /// Update an existing note
  Future<Note> updateNote(String id, {String? title, String? content}) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == id);
    if (index == -1) throw Exception('Note not found');
    final updated = notes[index].copyWith(title: title, content: content);
    notes[index] = updated;
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _persist(notes);
    return updated;
  }

  /// Delete a note
  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == id);
    await _persist(notes);
  }

  /// Delete all notes
  Future<void> deleteAllNotes() async {
    await _persist([]);
  }

  /// Persist notes list to SharedPreferences
  Future<void> _persist(List<Note> notes) async {
    _cachedNotes = notes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Note.encodeList(notes));
  }
}
