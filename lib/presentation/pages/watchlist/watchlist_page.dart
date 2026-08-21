import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/watchlist.dart';
import '../../../domain/entities/price_tick.dart';
import '../../providers/watchlist_viewmodel.dart';
import '../../providers/market_viewmodel.dart';
import '../../widgets/stock_ticker_row.dart';
import '../../widgets/empty_state_widget.dart';
import '../../dialogs/watchlist_name_dialog.dart';
import '../../dialogs/stock_picker_sheet.dart';

/// Feature 1: Watchlist — multiple watchlists as tabs with searchable stock picker & draggable rows.
class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage>
    with TickerProviderStateMixin {
  TabController? _tabCtrl;
  int _tabCount = 0;

  @override
  void dispose() {
    _tabCtrl?.dispose();
    super.dispose();
  }

  void _syncTabController(int count) {
    if (count != _tabCount) {
      _tabCtrl?.dispose();
      _tabCtrl = TabController(length: count, vsync: this);
      _tabCount = count;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final watchlists = vm.watchlists;
        _syncTabController(watchlists.length);

        if (watchlists.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(context, vm, null),
            body: EmptyStateWidget(
              icon: Icons.bookmark_add_outlined,
              title: AppStrings.emptyWatchlistsTitle,
              subtitle: AppStrings.emptyWatchlistsSubtitle,
              actionLabel: AppStrings.newWatchlist,
              action: () => _showCreateDialog(context, vm),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, vm, watchlists),
          body: TabBarView(
            controller: _tabCtrl,
            children: watchlists
                .map((w) => _WatchlistTab(watchlist: w))
                .toList(),
          ),
          floatingActionButton: _tabCtrl != null
              ? _WatchlistFab(
                  tabCtrl: _tabCtrl!,
                  watchlists: watchlists,
                )
              : null,
        );
      },
    );
  }

  AppBar _buildAppBar(
      BuildContext context, WatchlistViewModel vm, List<Watchlist>? watchlists) {
    return AppBar(
      title: Text(AppStrings.watchlistsTitle, style: AppTextStyles.headingLarge),
      actions: [
        if (watchlists != null && watchlists.isNotEmpty)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'rename',
                child: Row(children: [
                  const Icon(Icons.edit_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(AppStrings.renameWatchlist,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimary)),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.loss),
                  const SizedBox(width: 8),
                  Text(AppStrings.deleteWatchlist,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.loss)),
                ]),
              ),
            ],
            onSelected: (val) {
              final idx = _tabCtrl?.index ?? 0;
              if (idx >= watchlists.length) return;
              final watchlist = watchlists[idx];
              if (val == 'rename') {
                _showRenameDialog(context, vm, watchlist);
              } else if (val == 'delete') {
                _showDeleteConfirm(context, vm, watchlist);
              }
            },
          ),
        IconButton(
          icon: const Icon(Icons.add_rounded),
          tooltip: AppStrings.newWatchlist,
          onPressed: () => _showCreateDialog(context, vm),
        ),
      ],
      bottom: watchlists != null && watchlists.isNotEmpty && _tabCtrl != null
          ? TabBar(
              controller: _tabCtrl!,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: AppTextStyles.headingSmall,
              unselectedLabelStyle: AppTextStyles.bodyMedium,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: AppColors.border,
              tabs: watchlists
                  .map((w) => Tab(text: w.name))
                  .toList(),
            )
          : null,
    );
  }

  Future<void> _showCreateDialog(
      BuildContext context, WatchlistViewModel vm) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const WatchlistNameDialog(
        title: AppStrings.addWatchlist,
        confirmLabel: AppStrings.create,
      ),
    );
    if (name != null && context.mounted) {
      await vm.createWatchlist(name);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_tabCtrl != null && _tabCtrl!.length > 0) {
          _tabCtrl!.animateTo(_tabCtrl!.length - 1);
        }
      });
    }
  }

  Future<void> _showRenameDialog(
      BuildContext context, WatchlistViewModel vm, Watchlist w) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => WatchlistNameDialog(
        title: AppStrings.renameWatchlist,
        confirmLabel: AppStrings.rename,
        initialValue: w.name,
      ),
    );
    if (name != null && context.mounted) {
      await vm.renameWatchlist(w.id, name);
    }
  }

  Future<void> _showDeleteConfirm(
      BuildContext context, WatchlistViewModel vm, Watchlist w) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.deleteWatchlist,
            style: AppTextStyles.headingMedium),
        content: Text(AppStrings.deleteWatchlistConfirm,
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppStrings.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.loss),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.delete,
                style: AppTextStyles.buttonMedium
                    .copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await vm.deleteWatchlist(w.id);
    }
  }
}

/// The content of a single watchlist tab.
class _WatchlistTab extends StatelessWidget {
  const _WatchlistTab({required this.watchlist});
  final Watchlist watchlist;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WatchlistViewModel>();
    final current = vm.watchlistById(watchlist.id);
    final symbols = current?.symbolOrder ?? watchlist.symbolOrder;

    if (symbols.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.add_chart_outlined,
        title: AppStrings.emptyWatchlistTitle,
        subtitle: AppStrings.emptyWatchlistSubtitle,
        action: () => _openPicker(context, watchlist.id, symbols),
        actionLabel: AppStrings.addStocks,
      );
    }

    return Column(
      children: [
        // Quick Search & Add bar on top of the list
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: InkWell(
            onTap: () => _openPicker(context, watchlist.id, symbols),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.searchStocksHint,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+ Add',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Reorderable Stock List
        Expanded(
          child: ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              context
                  .read<WatchlistViewModel>()
                  .reorderStock(watchlist.id, oldIndex, newIndex);
            },
            itemCount: symbols.length,
            itemBuilder: (context, index) {
              final symbol = symbols[index];
              return _WatchlistStockRow(
                key: ValueKey('${watchlist.id}_$symbol'),
                watchlistId: watchlist.id,
                symbol: symbol,
              );
            },
          ),
        ),
      ],
    );
  }

  void _openPicker(
      BuildContext context, String watchlistId, List<String> alreadyAdded) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StockPickerSheet(
        watchlistId: watchlistId,
        alreadyAdded: alreadyAdded,
      ),
    );
  }
}

/// A single reorderable stock row in a watchlist.
class _WatchlistStockRow extends StatelessWidget {
  const _WatchlistStockRow({
    required this.watchlistId,
    required this.symbol,
    super.key,
  });

  final String watchlistId;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Selector<MarketViewModel, PriceTick?>(
      selector: (_, vm) => vm.tickFor(symbol),
      builder: (context, tick, _) {
        return Material(
          color: AppColors.background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StockTickerRow(
                key: ValueKey(symbol),
                symbol: symbol,
                tick: tick,
                onTap: () => context.push(
                  '${AppRoutes.order}?symbol=$symbol&side=buy',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded,
                          size: 20, color: AppColors.loss),
                      onPressed: () {
                        context
                            .read<WatchlistViewModel>()
                            .removeStock(watchlistId, symbol);
                      },
                    ),
                    const Icon(Icons.drag_handle_rounded,
                        size: 20, color: AppColors.textMuted),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 70),
            ],
          ),
        );
      },
    );
  }
}

/// FAB to open the stock picker for the currently active tab.
class _WatchlistFab extends StatelessWidget {
  const _WatchlistFab(
      {required this.tabCtrl, required this.watchlists});
  final TabController tabCtrl;
  final List<Watchlist> watchlists;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        final idx = tabCtrl.index;
        if (idx >= watchlists.length) return;
        final w = watchlists[idx];
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => StockPickerSheet(
            watchlistId: w.id,
            alreadyAdded: w.symbolOrder,
          ),
        );
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add Stocks'),
    );
  }
}
