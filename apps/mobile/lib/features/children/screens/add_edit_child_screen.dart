// lib/features/children/screens/add_edit_child_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/children_repository.dart';
import '../../../shared/services/pin_service.dart';

class AddEditChildScreen extends ConsumerStatefulWidget {
  final String? childId;
  const AddEditChildScreen({super.key, this.childId});

  @override
  ConsumerState<AddEditChildScreen> createState() =>
      _AddEditChildScreenState();
}

class _AddEditChildScreenState extends ConsumerState<AddEditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _gradeCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  String _avatarId = 'avatar_1';
  bool _loading = false;
  String? _error;

  bool get _isEditing => widget.childId != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _gradeCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final pin = _pinCtrl.text;
    if (pin.length < 4 || pin.length > 6) {
      setState(() => _error = 'PIN must be 4–6 digits');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Not signed in');

      final repo = ref.read(childrenRepositoryProvider);
      if (_isEditing) {
        // TODO: Implement edit child
      } else {
        await repo.addChild(
          parentId: user.uid,
          name: _nameCtrl.text.trim(),
          age: int.parse(_ageCtrl.text.trim()),
          grade: _gradeCtrl.text.trim(),
          pinHash: PinService.hashPin(pin),
          avatarId: _avatarId,
        );
      }
      if (mounted) context.go('/children');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Child' : 'Add Child'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avatar', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                _AvatarPicker(
                  selected: _avatarId,
                  onChanged: (id) => setState(() => _avatarId = id),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Child's Name",
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter age'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _gradeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Grade',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter grade'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinCtrl,
                  decoration: const InputDecoration(
                    labelText: 'PIN (4–6 digits)',
                    prefixIcon: Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter PIN';
                    if (v.length < 4) return 'PIN must be at least 4 digits';
                    if (!RegExp(r'^\d+$').hasMatch(v)) {
                      return 'PIN must be digits only';
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Save Changes' : 'Add Child'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  static const _avatars = [
    'avatar_1',
    'avatar_2',
    'avatar_3',
    'avatar_4',
    'avatar_rocket',
    'avatar_owl',
  ];

  const _AvatarPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _avatars.map((id) {
        final isSelected = id == selected;
        return GestureDetector(
          onTap: () => onChanged(id),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceVariant,
            child: Text(
              id.split('_').last.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
