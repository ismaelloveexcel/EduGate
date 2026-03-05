// lib/features/children/screens/pin_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/children_repository.dart';
import '../../../shared/services/pin_service.dart';

class PinEntryScreen extends ConsumerStatefulWidget {
  final String childId;
  const PinEntryScreen({super.key, required this.childId});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  String _pin = '';
  String? _error;
  bool _loading = false;

  void _onDigitTap(String digit) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length >= 4) _tryVerify();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _tryVerify() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      final children =
          await ref.read(childrenRepositoryProvider).getChildren(user.uid);
      final child = children.firstWhere(
        (c) => c.id == widget.childId,
        orElse: () => throw Exception('Child not found'),
      );

      if (PinService.verifyPin(_pin, child.pinHash)) {
        if (mounted) context.go('/child-home/${widget.childId}');
      } else {
        setState(() {
          _error = 'Incorrect PIN. Try again.';
          _pin = '';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _pin = '';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pin, size: 64, color: Color(0xFF4F46E5)),
              const SizedBox(height: 16),
              const Text(
                'Enter your PIN',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // PIN dots display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length
                          ? const Color(0xFF4F46E5)
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 32),
              if (_loading)
                const CircularProgressIndicator()
              else
                _NumPad(onDigit: _onDigitTap, onBackspace: _onBackspace),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _NumPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        _buildRow(['4', '5', '6']),
        _buildRow(['7', '8', '9']),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 80),
            _DigitButton(digit: '0', onTap: onDigit),
            _BackspaceButton(onTap: onBackspace),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((d) => _DigitButton(digit: d, onTap: onDigit)).toList(),
    );
  }
}

class _DigitButton extends StatelessWidget {
  final String digit;
  final ValueChanged<String> onTap;

  const _DigitButton({required this.digit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: 72,
        height: 72,
        child: ElevatedButton(
          onPressed: () => onTap(digit),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
          ),
          child: Text(
            digit,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _BackspaceButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackspaceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: 72,
        height: 72,
        child: IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.backspace_outlined, size: 28),
        ),
      ),
    );
  }
}
