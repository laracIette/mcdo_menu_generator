import 'package:flutter/material.dart';
import 'package:mcdo_menu_generator/filters.dart';
import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/item_type.dart';
import 'package:mcdo_menu_generator/items.dart';
import 'package:mcdo_menu_generator/utils.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key, required this.animation, required this.onFiltersUpdated, required this.filters});

  final Animation<double> animation;
  final void Function(Filters) onFiltersUpdated;
  final Filters filters;

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  Filters get _filters => widget.filters;

  void _broadcastFiltersUpdated() {
    widget.onFiltersUpdated(_filters);
  }

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
    const Map<ItemType, String> names = {
      ItemType.burger: 'Burgers',
      ItemType.nuggets: 'Nuggets',
      ItemType.salad: 'Salads',
    };

    return Row(
      children: [
        Text(names[itemType] ?? ''),
        ElevatedButton(
          onPressed: () => _switchAllowedItemType(itemType),
          child: Text(_filters.allowedItemTypes.contains(itemType).toString()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context), // Tap outside to dismiss
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
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
                  child: Column(
                    children: [
                      AppBar(
                        automaticallyImplyLeading: false,
                        title: Text('Side Sheet'),
                        actions: [
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _getItemTypeButton(ItemType.burger),
                              const VerticalSizedBox(),
                              _getItemTypeButton(ItemType.nuggets),
                              const VerticalSizedBox(),
                              _getItemTypeButton(ItemType.salad),
                              const VerticalSizedBox(),
                              ...items.map((item) => InkWell(
                                key: ValueKey(item.name),
                                onTap: () => _switchRequiredItem(item),
                                child: Container(
                                  color: _filters.requiredItems.contains(item)
                                      ? Colors.blue.withValues(alpha: 0.2) // selected background
                                      : Colors.transparent,                // unselected background
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}