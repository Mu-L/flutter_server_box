import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:toolbox/core/extension/navigator.dart';
import 'package:toolbox/view/widget/input_field.dart';

import '../../../core/utils/ui.dart';
import '../../../data/model/server/snippet.dart';
import '../../../data/provider/snippet.dart';
import '../../../data/res/ui.dart';
import '../../../locator.dart';
import '../../widget/tag/editor.dart';

class SnippetEditPage extends StatefulWidget {
  const SnippetEditPage({Key? key, this.snippet}) : super(key: key);

  final Snippet? snippet;

  @override
  _SnippetEditPageState createState() => _SnippetEditPageState();
}

class _SnippetEditPageState extends State<SnippetEditPage>
    with AfterLayoutMixin {
  final _nameController = TextEditingController();
  final _scriptController = TextEditingController();
  final _scriptNode = FocusNode();

  late SnippetProvider _provider;
  late S _s;

  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _provider = locator<SnippetProvider>();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _scriptController.dispose();
    _scriptNode.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _s = S.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_s.edit, style: textSize18),
        actions: _buildAppBarActions(),
      ),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  List<Widget>? _buildAppBarActions() {
    if (widget.snippet == null) {
      return null;
    }
    return [
      IconButton(
        onPressed: () {
          _provider.del(widget.snippet!);
          context.pop();
        },
        tooltip: _s.delete,
        icon: const Icon(Icons.delete),
      )
    ];
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      heroTag: 'snippet',
      child: const Icon(Icons.save),
      onPressed: () {
        final name = _nameController.text;
        final script = _scriptController.text;
        if (name.isEmpty || script.isEmpty) {
          showSnackBar(context, Text(_s.fieldMustNotEmpty));
          return;
        }
        final snippet = Snippet(name, script, _tags);
        if (widget.snippet != null) {
          _provider.update(widget.snippet!, snippet);
        } else {
          _provider.add(snippet);
        }
        context.pop();
      },
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(13),
      children: [
        Input(
          controller: _nameController,
          type: TextInputType.text,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_scriptNode),
          label: _s.name,
          icon: Icons.info,
        ),
        Input(
          controller: _scriptController,
          node: _scriptNode,
          minLines: 3,
          maxLines: 10,
          type: TextInputType.multiline,
          label: _s.snippet,
          icon: Icons.code,
        ),
        TagEditor(
          tags: _tags,
          onChanged: (p0) => setState(() {
            _tags = p0;
          }),
          s: _s,
          tagSuggestions: [..._provider.tags],
          onRenameTag: (old, n) => setState(() {
            _provider.renameTag(old, n);
          }),
        )
      ],
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (widget.snippet != null) {
      _nameController.text = widget.snippet!.name;
      _scriptController.text = widget.snippet!.script;
      if (widget.snippet!.tags != null) {
        _tags = widget.snippet!.tags!;
        setState(() {});
      }
    }
  }
}
