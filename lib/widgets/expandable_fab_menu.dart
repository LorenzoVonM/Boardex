import 'dart:math';
import 'package:flutter/material.dart';

/// A single menu item for the expandable FAB menu.
class FabMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String heroTag;

  const FabMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.heroTag,
  });
}

/// A reusable expandable FAB menu with search button, expandable action items,
/// and a main toggle button. Used in Library and Matches screens.
class ExpandableFabMenu extends StatefulWidget {
  final List<FabMenuItem> menuItems;
  final FabMenuItem? searchItem;
  final double bottomOffset;

  const ExpandableFabMenu({
    super.key,
    required this.menuItems,
    this.searchItem,
    this.bottomOffset = 135.0,
  });

  @override
  State<ExpandableFabMenu> createState() => _ExpandableFabMenuState();
}

class _ExpandableFabMenuState extends State<ExpandableFabMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (_isOpen) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final systemBottomPadding = max(
      mediaQuery.padding.bottom,
      mediaQuery.viewPadding.bottom,
    );
    final bottomPadding = systemBottomPadding + widget.bottomOffset;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Optional Search FAB
          if (widget.searchItem != null) ...[
            FloatingActionButton.small(
              heroTag: widget.searchItem!.heroTag,
              elevation: 0,
              highlightElevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              disabledElevation: 0,
              onPressed: () {
                _close();
                widget.searchItem!.onTap();
              },
              tooltip: widget.searchItem!.label,
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
              child: Icon(widget.searchItem!.icon),
            ),
            const SizedBox(height: 8),
          ],

          // Expandable menu items
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < widget.menuItems.length; i++)
                    _buildMenuItem(context, widget.menuItems[i], i),
                ],
              );
            },
          ),

          // Main FAB - Small material size (40x40) with zero elevation (no box shadow)
          FloatingActionButton.small(
            heroTag: 'mainFab',
            elevation: 0,
            highlightElevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            disabledElevation: 0,
            onPressed: _toggle,
            child: AnimatedRotation(
              turns: _isOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 100),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, FabMenuItem item, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    // Stagger offset so items closer to main FAB animate faster
    final offsetFactor = 20.0 + (widget.menuItems.length - 1 - index) * 10.0;

    return Transform.translate(
      offset: Offset(0, offsetFactor * (1 - _animation.value)),
      child: Opacity(
        opacity: _animation.value,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _isOpen
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _close();
                      item.onTap();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
