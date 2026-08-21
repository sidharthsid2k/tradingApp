import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/stock_constants.dart';
import '../../core/extensions/decimal_ext.dart';
import '../../domain/entities/price_tick.dart';
import '../providers/market_viewmodel.dart';
import '../providers/watchlist_viewmodel.dart';

/// Bottom sheet to search and pick stocks to add to a watchlist.
class StockPickerSheet extends StatefulWidget {
  const StockPickerSheet({
    required this.watchlistId,
    required this.alreadyAdded,
    super.key,
  });

  final String watchlistId;
  final List<String> alreadyAdded;

  @override
  State<StockPickerSheet> createState() => _StockPickerSheetState();
}

class _StockPickerSheetState extends State<StockPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _filteredSymbols {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return StockConstants.allSymbols;

    return StockConstants.allSymbols.where((symbol) {
      final matchesSymbol = symbol.toLowerCase().contains(query);
      final matchesName =
          StockConstants.nameFor(symbol).toLowerCase().contains(query);
      return matchesSymbol || matchesName;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final watchlistVm = context.watch<WatchlistViewModel>();
    final currentWatchlist = watchlistVm.watchlistById(widget.watchlistId);
    final currentlyAdded = currentWatchlist?.symbolOrder ?? widget.alreadyAdded;
    final symbols = _filteredSymbols;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Header title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.addStocks, style: AppTextStyles.headingLarge),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: AppColors.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Search Input Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                autofocus: false,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: AppStrings.searchStocksHint,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          color: AppColors.textMuted,
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            // Filtered Stock list
            Expanded(
              child: symbols.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 36,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.noStocksFound,
                              style: AppTextStyles.headingSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.noStocksFoundSubtitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: symbols.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 70),
                      itemBuilder: (context, index) {
                        final symbol = symbols[index];
                        final isAdded = currentlyAdded.contains(symbol);

                        return _StockPickerRow(
                          symbol: symbol,
                          isAdded: isAdded,
                          onAdd: () async {
                            await context
                                .read<WatchlistViewModel>()
                                .addStock(widget.watchlistId, symbol);
                          },
                          onRemove: () async {
                            await context
                                .read<WatchlistViewModel>()
                                .removeStock(widget.watchlistId, symbol);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockPickerRow extends StatelessWidget {
  const _StockPickerRow({
    required this.symbol,
    required this.isAdded,
    required this.onAdd,
    required this.onRemove,
  });

  final String symbol;
  final bool isAdded;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Selector<MarketViewModel, PriceTick?>(
      selector: (_, vm) => vm.tickFor(symbol),
      builder: (context, tick, _) {
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAdded
                    ? [AppColors.border, AppColors.border]
                    : [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                symbol.length >= 2 ? symbol.substring(0, 2) : symbol,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isAdded ? AppColors.textMuted : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          title: Text(
            symbol,
            style: AppTextStyles.ticker.copyWith(
              color: isAdded ? AppColors.textMuted : AppColors.textPrimary,
            ),
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  StockConstants.nameFor(symbol),
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tick != null) ...[
                const SizedBox(width: 8),
                Text(
                  tick.ltp.toINR(),
                  style: AppTextStyles.priceSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tick.isGain ? AppColors.gain : AppColors.loss,
                  ),
                ),
              ],
            ],
          ),
          trailing: isAdded
              ? InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.alreadyAdded,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(
                    AppStrings.addStock,
                    style: AppTextStyles.buttonMedium.copyWith(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
