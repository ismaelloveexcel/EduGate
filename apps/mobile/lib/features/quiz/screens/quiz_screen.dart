// lib/features/quiz/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/question_model.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String childId;
  const QuizScreen({super.key, required this.childId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizNotifierProvider.notifier).initialize(widget.childId);
    });
  }

  void _onQuizStateChanged(QuizState quiz) {
    if (quiz.isComplete) {
      context.go(
        '/results/${widget.childId}',
        extra: {
          'correctCount': quiz.correctCount,
          'totalCount': quiz.totalCount,
          'xpEarned': quiz.xpEarned,
          'coinsEarned': quiz.coinsEarned,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizNotifierProvider);

    ref.listen<AsyncValue<QuizState>>(quizNotifierProvider, (_, next) {
      next.whenData(_onQuizStateChanged);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Time! 🧠'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/child-home/${widget.childId}'),
            child: const Text('Exit'),
          ),
        ],
      ),
      body: quizAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (quiz) {
          if (quiz.error != null) {
            return Center(child: Text(quiz.error!));
          }
          if (quiz.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (quiz.isComplete) {
            return const Center(child: CircularProgressIndicator());
          }
          if (quiz.currentIndex >= quiz.questions.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final question = quiz.questions[quiz.currentIndex];
          _questionStartTime ??= DateTime.now();

          return _QuestionWidget(
            question: question,
            questionNumber: quiz.currentIndex + 1,
            totalQuestions: quiz.questions.length,
            onAnswer: (answer) {
              final elapsed = DateTime.now()
                  .difference(_questionStartTime ?? DateTime.now())
                  .inMilliseconds;
              _questionStartTime = null;
              ref.read(quizNotifierProvider.notifier).submitAnswer(
                    question: question,
                    userAnswer: answer,
                    timeTakenMs: elapsed,
                  );
            },
          );
        },
      ),
    );
  }
}

class _QuestionWidget extends StatefulWidget {
  final QuestionModel question;
  final int questionNumber;
  final int totalQuestions;
  final ValueChanged<String> onAnswer;

  const _QuestionWidget({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onAnswer,
  });

  @override
  State<_QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<_QuestionWidget> {
  String? _selectedOption;
  final _fillCtrl = TextEditingController();

  @override
  void didUpdateWidget(_QuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _selectedOption = null;
      _fillCtrl.clear();
    }
  }

  @override
  void dispose() {
    _fillCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    String answer = '';
    if (widget.question.type == QuestionType.fillInNumber) {
      answer = _fillCtrl.text.trim();
    } else {
      answer = _selectedOption ?? '';
    }
    if (answer.isEmpty) return;
    widget.onAnswer(answer);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: widget.questionNumber / widget.totalQuestions,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${widget.questionNumber} of ${widget.totalQuestions}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _SubjectChip(subject: widget.question.subject),
                const SizedBox(width: 8),
                _DifficultyChip(difficulty: widget.question.difficulty),
              ],
            ),
            const SizedBox(height: 24),
            // Question prompt
            Text(
              widget.question.prompt,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            // Answer area
            Expanded(
              child: _buildAnswerArea(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSubmit() ? _submit : null,
                child: const Text('Submit Answer',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    if (widget.question.type == QuestionType.fillInNumber) {
      return _fillCtrl.text.trim().isNotEmpty;
    }
    return _selectedOption != null;
  }

  Widget _buildAnswerArea() {
    switch (widget.question.type) {
      case QuestionType.mcq:
        return ListView(
          children: widget.question.options.map((opt) {
            return _OptionTile(
              label: opt,
              selected: _selectedOption == opt,
              onTap: () => setState(() => _selectedOption = opt),
            );
          }).toList(),
        );

      case QuestionType.trueFalse:
        return Row(
          children: ['True', 'False'].map((opt) {
            final selected = _selectedOption == opt;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _TFButton(
                  label: opt,
                  selected: selected,
                  isTrue: opt == 'True',
                  onTap: () => setState(() => _selectedOption = opt),
                ),
              ),
            );
          }).toList(),
        );

      case QuestionType.fillInNumber:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fillCtrl,
              decoration: const InputDecoration(
                labelText: 'Your answer',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
          ],
        );
    }
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(label),
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
    );
  }
}

class _TFButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isTrue;
  final VoidCallback onTap;

  const _TFButton({
    required this.label,
    required this.selected,
    required this.isTrue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isTrue ? Colors.green : Colors.red;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final String subject;
  const _SubjectChip({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(subject.toUpperCase()),
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final Difficulty difficulty;
  const _DifficultyChip({required this.difficulty});

  Color _color() {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(difficulty.name.toUpperCase()),
      visualDensity: VisualDensity.compact,
      backgroundColor: _color().withOpacity(0.15),
      labelStyle: TextStyle(color: _color(), fontWeight: FontWeight.bold),
    );
  }
}
