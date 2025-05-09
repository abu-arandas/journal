import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal/data/models/journal_entry.dart';
import 'package:journal/modules/journal/controllers/journal_controller.dart';
import 'package:journal/modules/settings/controllers/settings_controller.dart';
import 'package:journal/widgets/rich_text_editor.dart';

class JournalEntryView extends StatefulWidget {
  const JournalEntryView({super.key});

  @override
  State<JournalEntryView> createState() => _JournalEntryViewState();
}

class _JournalEntryViewState extends State<JournalEntryView> {
  final JournalController _journalController = Get.find<JournalController>();
  final SettingsController _settingsController = Get.put(SettingsController());

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final RxString _selectedMood = ''.obs;
  final RxList<String> _selectedTags = <String>[].obs;
  final Rx<File?> _selectedImage = Rx<File?>(null);

  bool _isEditing = false;
  JournalEntry? _entryBeingEdited;

  @override
  void initState() {
    super.initState();

    // Check if we're editing an existing entry
    if (Get.arguments != null && Get.arguments is JournalEntry) {
      _entryBeingEdited = Get.arguments as JournalEntry;
      _isEditing = true;

      _titleController.text = _entryBeingEdited!.title;
      _contentController.text = _entryBeingEdited!.content;

      if (_entryBeingEdited!.mood != null) {
        _selectedMood.value = _entryBeingEdited!.mood!;
      }

      if (_entryBeingEdited!.tags != null) {
        _selectedTags.value = _entryBeingEdited!.tags!;
      }

      if (_entryBeingEdited!.imageUrl != null) {
        _selectedImage.value = File(_entryBeingEdited!.imageUrl!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final mood = _selectedMood.value.isEmpty ? null : _selectedMood.value;
    final tags = _selectedTags.isEmpty ? null : _selectedTags.toList();
    final imageUrl = _selectedImage.value?.path; // For now, we just store the local path
    if (_isEditing && _entryBeingEdited != null) {
      _journalController
          .updateEntry(
            id: _entryBeingEdited!.id!,
            title: title,
            content: content,
            mood: mood,
            tags: tags,
            imageUrl: imageUrl,
          )
          .then((success) {
            if (success) {
              Get.back();
              Get.snackbar('Success', 'Journal entry updated successfully', snackPosition: SnackPosition.BOTTOM);
            } else {
              Get.snackbar(
                'Error',
                _journalController.errorMessage.value,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Theme.of(context).colorScheme.error,
                colorText: Theme.of(context).colorScheme.onError,
              );
            }
          });
    } else {
      _journalController.createEntry(title: title, content: content, mood: mood, tags: tags, imageUrl: imageUrl).then((
        success,
      ) {
        if (success) {
          Get.back();
          Get.snackbar('Success', 'Journal entry created successfully', snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar(
            'Error',
            _journalController.errorMessage.value,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Theme.of(context).colorScheme.error,
            colorText: Theme.of(context).colorScheme.onError,
          );
        }
      });
    }
  }

  // Function to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);

      if (pickedFile != null) {
        _selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Function to show image source dialog
  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Add Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Take a Photo'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: Text('Cancel'))],
      ),
    );
  }

  void _showMoodPicker() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Mood', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Obx(
              () => Wrap(
                spacing: 16,
                runSpacing: 16,
                children:
                    _settingsController.moodOptions.map((mood) {
                      return InkWell(
                        onTap: () {
                          _selectedMood.value = mood;
                          Get.back();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:
                                _selectedMood.value == mood
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Colors.transparent,
                          ),
                          child: Text(mood, style: TextStyle(fontSize: 28)),
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 16),
            if (_selectedMood.value.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  _selectedMood.value = '';
                  Get.back();
                },
                child: Text('Clear Selection'),
              ),
          ],
        ),
      ),
    );
  }

  void _showTagsPicker() {
    final availableTags = _settingsController.defaultTags.toList();
    final selectedTags = _selectedTags.toList();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    // Add custom tag
                    Get.dialog(
                      AlertDialog(
                        title: Text('Add Custom Tag'),
                        content: TextField(
                          autofocus: true,
                          decoration: InputDecoration(labelText: 'Tag Name', hintText: 'Enter custom tag'),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              if (!selectedTags.contains(value)) {
                                selectedTags.add(value);
                              }
                              Get.back();
                            }
                          },
                        ),
                        actions: [
                          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              final TextEditingController ctrl = TextEditingController();

                              if (ctrl.text.isNotEmpty) {
                                if (!selectedTags.contains(ctrl.text)) {
                                  selectedTags.add(ctrl.text);
                                }
                                Get.back();
                              }
                            },
                            child: Text('Add'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Add Custom'),
                ),
              ],
            ),
            SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      availableTags.map((tag) {
                        final isSelected = selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                selectedTags.add(tag);
                              } else {
                                selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                );
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _selectedTags.value = selectedTags;
                    Get.back();
                  },
                  child: Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Journal Entry' : 'New Journal Entry'),
        actions: [IconButton(onPressed: _submitForm, icon: Icon(Icons.check), tooltip: 'Save')],
      ),
      body: Obx(() => _journalController.isLoading.value ? Center(child: CircularProgressIndicator()) : _buildForm()),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Content field - Rich Text Editor
            Card(
              margin: EdgeInsets.zero,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: SizedBox(
                height: 300,
                child: RichTextEditor(
                  initialValue: _contentController.text,
                  onChanged: (value) {
                    _contentController.text = value;
                  },
                  hintText: 'What\'s on your mind?',
                ),
              ),
            ),
            SizedBox(height: 16),

            // Mood selector
            Row(
              children: [
                Text('How are you feeling?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                Obx(
                  () =>
                      _selectedMood.value.isEmpty
                          ? OutlinedButton(onPressed: _showMoodPicker, child: Text('Select Mood'))
                          : Row(
                            children: [
                              Text(_selectedMood.value, style: TextStyle(fontSize: 28)),
                              SizedBox(width: 8),
                              IconButton(icon: Icon(Icons.edit), onPressed: _showMoodPicker),
                            ],
                          ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Tags selector
            Row(
              children: [
                Text('Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                OutlinedButton(onPressed: _showTagsPicker, child: Text('Select Tags')),
              ],
            ),
            SizedBox(height: 8),
            Obx(
              () =>
                  _selectedTags.isEmpty
                      ? Text('No tags selected', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                      : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _selectedTags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                onDeleted: () {
                                  _selectedTags.remove(tag);
                                },
                              );
                            }).toList(),
                      ),
            ),
            SizedBox(height: 16),

            // Image attachment section
            Text('Add Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Obx(
              () =>
                  _selectedImage.value == null
                      ? OutlinedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: Icon(Icons.add_a_photo),
                        label: Text('Attach Image'),
                      )
                      : Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 200,
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(image: FileImage(_selectedImage.value!), fit: BoxFit.cover),
                            ),
                          ),
                          IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                              child: Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                            onPressed: () {
                              _selectedImage.value = null;
                            },
                          ),
                        ],
                      ),
            ),
            SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                child: Text(_isEditing ? 'Update Entry' : 'Save Entry', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
