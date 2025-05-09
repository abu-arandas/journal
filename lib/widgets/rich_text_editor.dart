import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class RichTextEditor extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  final String? hintText;

  const RichTextEditor({super.key, required this.initialValue, required this.onChanged, this.hintText});

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _textController;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _textController = TextEditingController(text: widget.initialValue);

    _textController.addListener(() {
      widget.onChanged(_textController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _togglePreviewMode() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
  }

  void _insertFormatting(String prefix, String suffix) {
    final text = _textController.text;
    final selection = _textController.selection;

    if (selection.isCollapsed) {
      // No text selected, just insert the formatting
      final newText = text.replaceRange(selection.start, selection.end, '$prefix$suffix');

      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + prefix.length),
      );
    } else {
      // Text selected, wrap it with formatting
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(selection.start, selection.end, '$prefix$selectedText$suffix');

      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end + prefix.length + suffix.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Editor toolbar
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              // Bold
              IconButton(
                icon: Icon(Icons.format_bold),
                tooltip: 'Bold',
                onPressed: () => _insertFormatting('**', '**'),
              ),
              // Italic
              IconButton(
                icon: Icon(Icons.format_italic),
                tooltip: 'Italic',
                onPressed: () => _insertFormatting('_', '_'),
              ),
              // Underline (using HTML since Markdown doesn't have native underline)
              IconButton(
                icon: Icon(Icons.format_underlined),
                tooltip: 'Underline',
                onPressed: () => _insertFormatting('<u>', '</u>'),
              ),
              // Heading
              IconButton(icon: Icon(Icons.title), tooltip: 'Heading', onPressed: () => _insertFormatting('## ', '')),
              // List
              IconButton(
                icon: Icon(Icons.format_list_bulleted),
                tooltip: 'Bullet List',
                onPressed: () => _insertFormatting('- ', ''),
              ),
              // Checkbox
              IconButton(
                icon: Icon(Icons.check_box_outlined),
                tooltip: 'Checkbox',
                onPressed: () => _insertFormatting('- [ ] ', ''),
              ),
              Spacer(),
              // Preview toggle
              TextButton.icon(
                icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
                label: Text(_isPreviewMode ? 'Edit' : 'Preview'),
                onPressed: _togglePreviewMode,
              ),
            ],
          ),
        ),

        // Editor/Preview content
        Expanded(
          child:
              _isPreviewMode
                  ? Markdown(data: _textController.text, selectable: true, padding: const EdgeInsets.all(16.0))
                  : TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? 'Write your journal entry...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16.0),
                    ),
                  ),
        ),
      ],
    );
  }
}
