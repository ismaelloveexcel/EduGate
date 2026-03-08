// lib/features/rewards/screens/cosmetics_shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/cosmetic_item_model.dart';
import '../../../shared/models/progress_key.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/progress_repository.dart';
import '../../../shared/models/progress_model.dart';

final _shopProgressStreamProvider =
    StreamProvider.family<ProgressModel, ProgressKey>((ref, key) {
  return ref
      .read(progressRepositoryProvider)
      .watchProgress(key.parentId, key.childId);
});

final _ownedCosmeticsStreamProvider =
    StreamProvider.family<Set<String>, ProgressKey>((ref, key) {
  return ref
      .read(progressRepositoryProvider)
      .watchOwnedCosmetics(key.parentId, key.childId);
});

class CosmeticsShopScreen extends ConsumerWidget {
  final String childId;
  const CosmeticsShopScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final key = user == null ? null : (parentId: user.uid, childId: childId);

    final progressAsync = key == null
        ? const AsyncValue<ProgressModel>.loading()
        : ref.watch(_shopProgressStreamProvider(key));

    final ownedAsync = key == null
        ? const AsyncValue<Set<String>>.loading()
        : ref.watch(_ownedCosmeticsStreamProvider(key));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Shop 🛒'),
        leading: BackButton(onPressed: () => context.go('/child-home/$childId')),
        actions: [
          progressAsync.maybeWhen(
            data: (p) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Chip(
                label: Text('${p.coins} 🪙'),
                backgroundColor: Colors.amber.shade100,
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (progress) => _ShopGrid(
          progress: progress,
          owned: ownedAsync.asData?.value ?? {},
          onPurchase: (item) async {
            if (progress.coins < item.coinCost) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not enough coins!')),
              );
              return;
            }
            try {
              await ref.read(progressRepositoryProvider).purchaseCosmetic(
                    parentId: user!.uid,
                    childId: childId,
                    itemId: item.id,
                    coinCost: item.coinCost,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} purchased! 🎉')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Purchase failed: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class _ShopGrid extends StatelessWidget {
  final ProgressModel progress;
  final Set<String> owned;
  final ValueChanged<CosmeticItemModel> onPurchase;

  const _ShopGrid({
    required this.progress,
    required this.owned,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: kCosmeticsShop.length,
      itemBuilder: (context, index) {
        final item = kCosmeticsShop[index];
        final isOwned = owned.contains(item.id);
        final canAfford = progress.coins >= item.coinCost;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.redeem, size: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (isOwned)
                  const Chip(
                    label: Text('Owned ✓'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  )
                else
                  FilledButton(
                    onPressed: canAfford ? () => onPurchase(item) : null,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          canAfford ? Colors.amber : Colors.grey,
                    ),
                    child: Text('${item.coinCost} 🪙'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
