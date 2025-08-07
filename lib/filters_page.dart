import 'package:flutter/material.dart';
import 'package:mcdo_menu_generator/filters.dart';
import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/item_type.dart';
import 'package:mcdo_menu_generator/items.dart';

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
      if (_filters.allowedItemTypes.contains(itemType)) {
        _filters.allowedItemTypes.remove(itemType);
      }
      else {
        _filters.allowedItemTypes.add(itemType);
      }
    });
    _broadcastFiltersUpdated();
  }

  void _switchRequiredItem(Item item) {
    setState(() {
      if (_filters.requiredItems.contains(item)) {
        _filters.requiredItems.remove(item);
      }
      else {
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
        Text('${names[itemType]}'),
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
                              Text("This is a side modal that covers full height."),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Close"),
                              ),
                              _getItemTypeButton(ItemType.burger),
                              _getItemTypeButton(ItemType.nuggets),
                              _getItemTypeButton(ItemType.salad),
                              ...items.map((item) => InkWell(
                                key: ValueKey(item.name),
                                onTap: () => _switchRequiredItem(item),
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