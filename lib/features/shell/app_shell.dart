import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../theme/tchip_theme.dart';
import '../../widgets/tchip_logo.dart';

/// Main navigation: bottom bar on phones, NavigationRail-style side bar on
/// tablets. Branch order: Home, Operations, Report, Plans. The central "+"
/// opens the cash expense screen.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _go(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      _NavItem(Icons.home_outlined, Icons.home, l.navHome),
      _NavItem(
        Icons.format_list_bulleted,
        Icons.format_list_bulleted,
        l.navOperations,
      ),
      _NavItem(Icons.pie_chart_outline, Icons.pie_chart, l.navReport),
      _NavItem(Icons.calendar_today_outlined, Icons.calendar_today, l.navPlans),
    ];
    void addCash() => context.push('/add');

    if (context.isTablet) {
      return Scaffold(
        body: Row(
          children: [
            _SideRail(
              items: items,
              current: navigationShell.currentIndex,
              onSelect: _go,
              onAdd: addCash,
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomBar(
        items: items,
        current: navigationShell.currentIndex,
        onSelect: _go,
        onAdd: addCash,
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.items,
    required this.current,
    required this.onSelect,
    required this.onAdd,
  });

  final List<_NavItem> items;
  final int current;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget tab(int i) => Expanded(
      child: _NavButton(
        item: items[i],
        selected: current == i,
        onTap: () => onSelect(i),
      ),
    );

    return Semantics(
      container: true,
      label: l.navMainLabel,
      child: Container(
        decoration: const BoxDecoration(
          color: TchipColors.navBar,
          border: Border(top: BorderSide(color: TchipColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                tab(0),
                tab(1),
                // heightFactor keeps Center from filling the Scaffold height.
                Expanded(
                  child: Center(
                    heightFactor: 1,
                    child: _AddButton(onTap: onAdd),
                  ),
                ),
                tab(2),
                tab(3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.items,
    required this.current,
    required this.onSelect,
    required this.onAdd,
  });

  final List<_NavItem> items;
  final int current;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: l.navMainLabel,
      child: Container(
        width: TchipSpacing.railWidth,
        decoration: const BoxDecoration(
          color: TchipColors.navBar,
          border: Border(right: BorderSide(color: TchipColors.border)),
        ),
        child: SafeArea(
          right: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        const TchipLogo(size: 18, compact: true),
                        const SizedBox(height: 30),
                        for (var i = 0; i < items.length; i++) ...[
                          _NavButton(
                            item: items[i],
                            selected: current == i,
                            onTap: () => onSelect(i),
                          ),
                          const SizedBox(height: 22),
                        ],
                        _AddButton(onTap: onAdd),
                        const Spacer(),
                        _NavButton(
                          item: _NavItem(
                            Icons.settings_outlined,
                            Icons.settings,
                            l.navSettings,
                          ),
                          selected: false,
                          onTap: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? TchipColors.yellow : TchipColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: TchipRadii.all(TchipRadii.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: TchipSpacing.touch,
            minWidth: TchipSpacing.touch,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 22,
                  color: color,
                ),
                const SizedBox(height: 4),
                // Shrinks instead of cutting the label on narrow screens or
                // with a large system font.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TchipText.navLabel.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
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

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Tooltip(
      message: l.navAddCash,
      child: Material(
        color: TchipColors.yellow,
        borderRadius: TchipRadii.all(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: TchipRadii.all(18),
          splashColor: TchipColors.yellowDark,
          child: const SizedBox(
            width: TchipSpacing.fab,
            height: TchipSpacing.fab,
            child: Icon(Icons.add, size: 26, color: TchipColors.onYellow),
          ),
        ),
      ),
    );
  }
}
