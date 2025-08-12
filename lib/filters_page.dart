import 'package:flutter/material.dart';
import 'package:mcdo_menu_generator/filters.dart';
import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/item_type.dart';
import 'package:mcdo_menu_generator/utils.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key, required this.animation, required this.availableItemsFuture, required this.onFiltersUpdated, required this.filters});

  final Animation<double> animation;
  final Future<List<Item>> availableItemsFuture;
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
  Future<List<Item>> get _availableItemsFuture => widget.availableItemsFuture;

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

  Iterable<Widget> _getItemWidgets(Iterable<Item> items) =>
    items
      .where((item) => _input.isEmpty
        || item.id == int.tryParse(_input)
        || item.name.toLowerCase().contains(_input.toLowerCase())
      )
      .map((item) => InkWell(
        key: ValueKey(item.id),
        onTap: () => _switchRequiredItem(item),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: 16.0,
            children: [
              Image.network(
                item.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (_showIds) TextSpan(
                            text: '  ${item.id}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    Text('${item.calories} kcal'),
                  ],
                ),
              ),

              Text('${item.price.toStringAsFixed(2)} €'),
            ],
          ),
        ),
      ));

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
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
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

                        ElevatedButton(
                          onPressed: () => setState(() => _showIds = !_showIds),
                          child: Text(_showIds ? 'Hide IDs' : 'Show IDs')
                        ),

                        Expanded(
                          child: FutureBuilder(
                            future: _availableItemsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }
                              else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('No items found'));
                              }
                              else {
                                final availableItems = snapshot.data!;
                                return ListView(
                                  children: [
                                    if (_filters.requiredItems.isNotEmpty) const Text('Selected Items'),
                                    ..._getItemWidgets(availableItems.where((item) => _filters.requiredItems.contains(item))),
                                    VerticalSizedBox(),
                                    if (_filters.requiredItems.length != availableItems.length) const Text('Available Items'),
                                    ..._getItemWidgets(availableItems.where((item) => !_filters.requiredItems.contains(item))),
                                  ],
                                );
                              }
                            },
                          )
                        ),

                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search Item',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (input) => setState(() => _input = input),
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