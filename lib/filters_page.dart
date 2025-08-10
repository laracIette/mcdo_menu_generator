import 'package:flutter/material.dart';
import 'package:mcdo_menu_generator/filters.dart';
import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/item_type.dart';
import 'package:mcdo_menu_generator/utils.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key, required this.animation, required this.availableItems, required this.onFiltersUpdated, required this.filters});

  final Animation<double> animation;
  final List<Item> availableItems;
  final void Function(Filters) onFiltersUpdated;
  final Filters filters;

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

enum DropdownState {
  closed,
  opened,
}

class _FiltersPageState extends State<FiltersPage> {
  Filters get _filters => widget.filters;
  List<Item> get _availableItems => widget.availableItems;

  final Map<ItemType, DropdownState> dropdownStates = {};

  void _switchDropdownState(ItemType itemType) =>
    setState(() {
      dropdownStates[itemType] = dropdownStates[itemType] == DropdownState.opened
        ? DropdownState.closed
        : DropdownState.opened;
    });

  void _broadcastFiltersUpdated() =>
    widget.onFiltersUpdated(_filters);

  void _switchAllowedItemType(ItemType itemType) {
    setState(() {
      if (!_filters.allowedItemTypes.remove(itemType)) {
        _filters.allowedItemTypes.add(itemType);
      }
    });
    _broadcastFiltersUpdated();
  }

  void _switchRequiredItem(Item item) {
    setState(() {
      if (!_filters.requiredItems.remove(item)) {
        _filters.requiredItems.add(item);
      }
    });
    _broadcastFiltersUpdated();
  }

  Widget _getItemTypeButton(ItemType itemType) {
    return Row(
      children: [
        Text(itemTypeNames[itemType] ?? 'Error'),
        Spacer(),
        ElevatedButton(
          onPressed: () => _switchAllowedItemType(itemType),
          child: Text(_filters.allowedItemTypes.contains(itemType).toString()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.pop(context),
            child: Container(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.85,
              heightFactor: 1.0,
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx > 100.0) {
                      Navigator.pop(context);
                    }
                  },
                  child: Column(
                    children: [
                      AppBar(
                        automaticallyImplyLeading: false,
                        title: Text('Filters'),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              ...ItemType.values.map((itemType) => Column(
                                key: ValueKey('allowedItemType-$itemType'),
                                children: [
                                  _getItemTypeButton(itemType),
                                  const VerticalSizedBox(),
                                ]
                              )),

                              const VerticalSizedBox(),

                              Text('Required Items'),

                              const VerticalSizedBox(),

                              ...ItemType.values.map((itemType) => Column(
                                key: ValueKey('itemTypeDropdown-$itemType'),
                                children: [
                                  Row(
                                    children: [
                                      Text(itemTypeNames[itemType] ?? 'Error'),
                                      Spacer(),
                                      ElevatedButton(
                                        onPressed: () => _switchDropdownState(itemType),
                                        child: Text(dropdownStates[itemType] == DropdownState.opened ? '-' : '+')
                                      ),
                                    ],
                                  ),

                                  const VerticalSizedBox(),

                                  ..._availableItems
                                    .where((item) => item.type == itemType && dropdownStates[itemType] == DropdownState.opened)
                                    .map((item) => InkWell(
                                      key: ValueKey(item),
                                      onTap: () => _switchRequiredItem(item),
                                      child: Container(
                                        color: _filters.requiredItems.contains(item)
                                          ? Colors.blue.withValues(alpha: 0.2)
                                          : Colors.transparent,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              item.imagePath,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                            Spacer(),
                                            Column(
                                              children: [
                                                Text(item.name),
                                                Text('${item.calories} kcal'),
                                              ],
                                            ),
                                            Spacer(),
                                            Text('${item.price} €'),
                                          ],
                                        ),
                                      ),
                                    )),
                                ],
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}