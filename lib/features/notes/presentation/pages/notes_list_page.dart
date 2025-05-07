import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../../../auth/presentation/pages/pin_login_page.dart';
import '../../presentation/bloc/notes_provider.dart';
import 'note_edit_page.dart';
import '../widgets/note_item.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Defer loading notes to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      // Use Future.microtask to avoid calling setState during build
      Future.microtask(() {
        if (mounted) {
          Provider.of<NotesProvider>(context, listen: false).loadNotes();
        }
      });
    }
  }

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const PinLoginPage()));
  }

  void _toggleTheme() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.toggleTheme();
  }

  void _createNote() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => const NoteEditPage(isEditing: false),
          ),
        )
        .then((_) {
          if (mounted) {
            Provider.of<NotesProvider>(context, listen: false).loadNotes();
          }
        });
  }

  void _editNote(int id) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => NoteEditPage(isEditing: true, noteId: id),
          ),
        )
        .then((_) {
          if (mounted) {
            Provider.of<NotesProvider>(context, listen: false).loadNotes();
          }
        });
  }

  void _deleteNote(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      if (mounted) {
        final notesProvider = Provider.of<NotesProvider>(
          context,
          listen: false,
        );
        final success = await notesProvider.removeNote(id);

        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notesProvider.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Notes'),
        actions: [
          IconButton(
            icon: Icon(
              authProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: _toggleTheme,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body:
          notesProvider.status == NotesStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : notesProvider.notes.isEmpty
              ? const Center(
                child: Text(
                  'No notes yet. Tap the + button to create one.',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: notesProvider.notes.length,
                itemBuilder: (context, index) {
                  final note = notesProvider.notes[index];
                  return NoteItem(
                    note: note,
                    onTap: () => _editNote(note.id!),
                    onDelete: () => _deleteNote(note.id!),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
