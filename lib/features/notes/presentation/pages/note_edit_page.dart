import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/bloc/notes_provider.dart';

class NoteEditPage extends StatefulWidget {
  final bool isEditing;
  final int? noteId;

  const NoteEditPage({super.key, required this.isEditing, this.noteId});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Defer loading note to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && widget.isEditing && widget.noteId != null) {
      _isInitialized = true;
      // Use Future.microtask to avoid calling setState during build
      Future.microtask(() => _loadNote());
    }
  }

  Future<void> _loadNote() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    await notesProvider.loadNoteById(widget.noteId!);

    if (!mounted) return;

    if (notesProvider.selectedNote != null) {
      _titleController.text = notesProvider.selectedNote!.title;
      _contentController.text = notesProvider.selectedNote!.content;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      bool success;

      if (widget.isEditing && widget.noteId != null) {
        success = await notesProvider.editNote(
          widget.noteId!,
          _titleController.text,
          _contentController.text,
        );
      } else {
        success = await notesProvider.addNote(
          _titleController.text,
          _contentController.text,
        );
      }

      if (success && mounted) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Note' : 'New Note',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save note',
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildNoteForm(context),
      ),
      floatingActionButton:
          _isLoading
              ? null
              : FloatingActionButton(
                onPressed: _saveNote,
                tooltip: 'Save note',
                child: const Icon(Icons.save),
              ),
    );
  }

  Widget _buildNoteForm(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title field with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _titleController,
                style: theme.textTheme.titleLarge,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter note title',
                  prefixIcon: const Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            // Content field with animation
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _contentController,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    hintText: 'Write your note here...',
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 250),
                      child: Icon(Icons.notes),
                    ),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some content';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
