// lib/features/rewards/screens/cosmetics_shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/cosmetic_item_model.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/progress_repository.dart';
import '../../../shared/models/progress_model.dart';

/// Top-level provider so Riverpod can cache and share the stream subscription.
typedef _ShopProgressKey = ({String parentId, String childId});

final _shopProgressStreamProvider =
    StreamProvider.family<ProgressModel, _ShopProgressKey>((ref, key) {
  return ref
      .read(progressRepositoryProvider)
      .watchProgress(key.parentId, key.childId);
});

class CosmeticsShopScreen extends ConsumerStatefulWidget {
  final String childId;
  const CosmeticsShopScreen({super.key, required this.childId});

  @override
  ConsumerState<CosmeticsShopScreen> createState() =>
      _CosmeticsShopScreenState();
}

class _CosmeticsShopScreenState extends ConsumerState<CosmeticsShopScreen> {
  // TODO (post-MVP): Replace in-memory ownership set with Firestore-backed
  // persistence.  Suggested schema:
  //   children/{childId}/ownedCosmetics/{itemId}  { purchasedAt: timestamp }
  // Steps:
  //   1. Add `ownedCosmeticsCol` to ProgressRepository (or a new CosmeticsRepository).
  //   2. On purchase, run a Firestore transaction that:
  //        a. Deducts coins from children/{childId}/progress/current.
  //        b. Writes the item doc to ownedCosmetics/.
  //   3. Load owned items via a StreamProvider so the UI reacts reactively.
  //   4. Without this, purchased items are lost on app restart.
  Set<String> _owned = {};

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final progressAsync = user == null
        ? const AsyncValue<ProgressModel>.loading()
        : ref.watch(
            _shopProgressStreamProvider(
                (parentId: user.uid, childId: widget.childId)),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Shop 🛒'),
        leading: BackButton(onPressed: () => context.go('/child-home/${widget.childId}')),
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
          owned: _owned,
          onPurchase: (item) async {
            if (progress.coins < item.coinCost) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not enough coins!')),
              );
              return;
            }
            // TODO: Persist owned items to Firestore
            setState(() => _owned.add(item.id));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.name} purchased! 🎉')),
            );
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
