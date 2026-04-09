// lib/features/settings/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/children_repository.dart';
import '../../../shared/models/child_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final String childId;
  const SettingsScreen({super.key, required this.childId});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  ChildModel? _child;
  bool _loading = true;
  String? _error;

  // Editable state
  late int _intervalMinutes;
  late List<String> _subjects;
  late int _quietStart;
  late int _quietEnd;

  static const _allSubjects = ['math', 'science', 'english', 'history', 'geography'];
  static const _intervalOptions = [15, 30, 60];

  @override
  void initState() {
    super.initState();
    _loadChild();
  }

  Future<void> _loadChild() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    try {
      final children = await ref.read(childrenRepositoryProvider).getChildren(user.uid);
      final child = children.firstWhere((c) => c.id == widget.childId);
      setState(() {
        _child = child;
        _intervalMinutes = child.quizIntervalMinutes;
        _subjects = List.from(child.subjectsEnabled);
        _quietStart = child.quietHoursStart;
        _quietEnd = child.quietHoursEnd;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _save() async {
    final user = ref.read(authStateProvider).value;
    if (user == null || _child == null) return;
    setState(() => _loading = true);
    try {
      final updated = _child!.copyWith(
        quizIntervalMinutes: _intervalMinutes,
        subjectsEnabled: _subjects,
        quietHoursStart: _quietStart,
        quietHoursEnd: _quietEnd,
      );
      await ref.read(childrenRepositoryProvider).updateChild(user.uid, updated);

      // Settings are persisted to Firestore. The Cloud Function scheduler reads
      // quizIntervalMinutes and quietHoursStart/quietHoursEnd to send FCM
      // quiz reminders at the correct intervals. No local scheduling needed here.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved!')),
        );
        context.go('/child-home/${widget.childId}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!)));
    if (_child == null) return const Scaffold(body: Center(child: Text('Child not found')));

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings – ${_child!.name}'),
        leading: BackButton(onPressed: () => context.go('/child-home/${widget.childId}')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Quiz Interval
            _SectionHeader('Quiz Interval'),
            ...(_intervalOptions.map((mins) => RadioListTile<int>(
                  title: Text(mins == 15
                      ? 'Every 15 minutes'
                      : mins == 30
                          ? 'Every 30 minutes'
                          : 'Every hour'),
                  value: mins,
                  groupValue: _intervalMinutes,
                  onChanged: (v) => setState(() => _intervalMinutes = v!),
                ))),
            const Divider(),

            // Subjects
            _SectionHeader('Enabled Subjects'),
            ...(_allSubjects.map((subject) => CheckboxListTile(
                  title: Text(subject[0].toUpperCase() + subject.substring(1)),
                  value: _subjects.contains(subject),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _subjects.add(subject);
                      } else if (_subjects.length > 1) {
                        _subjects.remove(subject);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('At least one subject must be enabled')),
                        );
                      }
                    });
                  },
                ))),
            const Divider(),

            // Quiet Hours
            _SectionHeader('Quiet Hours (no notifications)'),
            ListTile(
              title: const Text('Quiet Hours Start'),
              trailing: DropdownButton<int>(
                value: _quietStart,
                items: List.generate(24, (i) => DropdownMenuItem(
                  value: i,
                  child: Text('${i.toString().padLeft(2, '0')}:00'),
                )),
                onChanged: (v) => setState(() => _quietStart = v!),
              ),
            ),
            ListTile(
              title: const Text('Quiet Hours End'),
              trailing: DropdownButton<int>(
                value: _quietEnd,
                items: List.generate(24, (i) => DropdownMenuItem(
                  value: i,
                  child: Text('${i.toString().padLeft(2, '0')}:00'),
                )),
                onChanged: (v) => setState(() => _quietEnd = v!),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
