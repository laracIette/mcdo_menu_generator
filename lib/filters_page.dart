import 'package:flutter/material.dart';
import 'package:mcdo_menu_generator/filters.dart';
import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/item_type.dart';

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

  String _input = '';

  bool _showIds = false;

  void _broadcastFiltersUpdated() =>
    widget.onFiltersUpdated(_filters);

  void _switchRequiredItem(Item item) {
    setState(() {
      if (!_filters.requiredItems.remove(item)) {
        _filters.requiredItems.add(item);
      }
    });
    _broadcastFiltersUpdated();
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                ),
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx > 50.0) {
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      spacing: 16.0,
                      children: [
                        AppBar(
                          automaticallyImplyLeading: false,
                          title: const Text('Required Items'),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),

                        Row(
                          spacing: 16.0,
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Search Item',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (input) => setState(() => _input = input),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => setState(() => _showIds = !_showIds),
                              child: Text(_showIds ? 'Hide IDs' : 'Show IDs')
                            ),
                          ],
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              spacing: 16.0,
                              children: [
                                ..._availableItems
                                  .where((item) => _input.isEmpty
                                    || item.id == int.tryParse(_input)
                                    || item.name.toLowerCase().contains(_input.toLowerCase())
                                  )
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
                                              Row(
                                                spacing: 16.0,
                                                children: [
                                                  Text(item.name),
                                                  if (_showIds) Text(
                                                    item.id.toString(),
                                                    style: TextStyle(color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              Text('${item.calories} kcal'),
                                            ],
                                          ),
                                          Spacer(),
                                          Text('${item.price.toStringAsFixed(2)} €'),
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
            ),
          ),
        ],
      ),
    );
  }
}