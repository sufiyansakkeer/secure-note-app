import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
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

class _NotesListPageState extends State<NotesListPage>
    with SingleTickerProviderStateMixin {
  bool _isInitialized = false;
  late ScrollController _scrollController;
  bool _isFabVisible = true;
  double _fabScale = 1.0;
  double _fabOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    // Initialize scroll controller
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    // Defer loading notes to didChangeDependencies
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Show/hide FAB based on scroll direction
    final ScrollDirection direction =
        _scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.reverse) {
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;
          _fabScale = 0.0;
          _fabOpacity = 0.0;
        });
      }
    } else if (direction == ScrollDirection.forward) {
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;
          _fabScale = 1.0;
          _fabOpacity = 1.0;
        });
      }
    }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 24),
            SizedBox(width: 8),
            Text(
              'Secure Notes',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              authProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: 'Toggle theme',
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            notesProvider.status == NotesStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : notesProvider.notes.isEmpty
                ? _buildEmptyState(context)
                : _buildNotesList(notesProvider),
      ),
      floatingActionButton: AnimatedScale(
        scale: _fabScale,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _fabOpacity,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: FloatingActionButton(
            onPressed: _createNote,

            elevation: 4,
            heroTag: 'createNoteButton',
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: theme.colorScheme.primary.withAlpha(150),
          ),
          const SizedBox(height: 16),
          Text('No notes yet', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first note',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNote,
            icon: const Icon(Icons.add),
            label: const Text('Create Note'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(NotesProvider notesProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
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
    );
  }
}
