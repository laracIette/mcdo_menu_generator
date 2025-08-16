import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mcdo_menu_generator/circle_icon_button.dart';
import 'package:mcdo_menu_generator/filters.dart';
import 'package:mcdo_menu_generator/item.dart';
import 'package:mcdo_menu_generator/material_text_field.dart';
import 'package:mcdo_menu_generator/shared_data.dart';
import 'package:mcdo_menu_generator/utils.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key, required this.animation, required this.onPop});

  final Animation<double> animation;
  final void Function() onPop;

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

enum DropdownState {
  closed,
  opened,
}

class _FiltersPageState extends State<FiltersPage> {
  Filters get _filters => sharedData.filters;

  String _input = '';

  bool _showIds = false;

  void _switchRequiredItem(Item item) =>
    setState(() {
      if (!_filters.requiredItems.remove(item)) {
        _filters.requiredItems.add(item);
        _filters.excludedItems.remove(item);
      }
    });

  void _switchExcludedItem(Item item) =>
    setState(() {
      if (!_filters.excludedItems.remove(item)) {
        _filters.excludedItems.add(item);
        _filters.requiredItems.remove(item);
      }
    });

  Iterable<Widget> _getItemWidgets(BuildContext context, Iterable<Item> items) =>
    items
      .where((item) => _input.isEmpty
        || item.id == int.tryParse(_input)
        || item.name.toLowerCase().contains(_input.toLowerCase())
      )
      .map((item) => Padding(
        padding: const EdgeInsetsGeometry.all(4.0),
        child: Material(
          color: _filters.requiredItems.contains(item)
            ? Colors.green.withValues(alpha: 0.2)
            : _filters.excludedItems.contains(item)
              ? Colors.red.withValues(alpha: 0.2)
              : Theme.of(context).hoverColor,
          borderRadius: BorderRadius.circular(8.0),
          elevation: 1.5,
          shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.3),
          child: InkWell(
            key: ValueKey(item.id),
            onTap: () => _switchRequiredItem(item),
            onLongPress: () => _switchExcludedItem(item),
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0.0, 8.0, 0.0),
              child: Row(
                spacing: 16.0,
                children: [
                   CachedNetworkImage(
                    imageUrl: item.imagePath,
                    progressIndicatorBuilder: (context, url, downloadProgress) => 
                    Padding(
                      padding: EdgeInsetsGeometry.all(15.0), 
                      child: CircularProgressIndicator(value: downloadProgress.progress),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    width: 80.0,
                    height: 80.0,
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
            onTap: () {
              Navigator.pop(context);
              widget.onPop();
            },
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.onPrimaryFixedVariant,
                        Theme.of(context).colorScheme.onSecondaryFixedVariant,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dx > 50.0) {
                        Navigator.pop(context);
                        widget.onPop();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsetsGeometry.fromLTRB(16.0, 48.0, 16.0, 32.0),
                      child: Column(
                        spacing: 16.0,
                        children: [
                          const Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          Padding(
                            padding: EdgeInsetsGeometry.fromLTRB(4.0, 0.0, 4.0, 0.0),
                            child: Row(
                              children: [
                                CircleIconButton(
                                  iconData: Icons.numbers_rounded,
                                  onTap: () => setState(() => _showIds = !_showIds),
                                ),

                                Spacer(),

                                CircleIconButton(
                                  iconData: Icons.clear_all_rounded,
                                  onTap: sharedData.filters.excludedItems.isNotEmpty || sharedData.filters.requiredItems.isNotEmpty
                                    ? () => setState(() {
                                      sharedData.filters.excludedItems.clear();
                                      sharedData.filters.requiredItems.clear();
                                    })
                                    : null,
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: FutureBuilder(
                              future: sharedData.currentLocation?.availableItems,
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
                                  final availableItems = List<Item>.from(snapshot.data!);
                                  availableItems.sort((a, b) => b.value.compareTo(a.value));
                                  return ListView(
                                    padding: EdgeInsets.zero, // todo: why?
                                    children: [
                                      if (_filters.requiredItems.isNotEmpty)
                                        ...[
                                          const Text('Selected Items'),
                                          const VerticalSizedBox(height: 4.0),
                                          ..._getItemWidgets(
                                            context,
                                            availableItems.where((item) => _filters.requiredItems.contains(item))
                                          ),
                                          const VerticalSizedBox(),
                                        ],
                                      if (_filters.excludedItems.isNotEmpty)
                                        ...[
                                          const Text('Excluded Items'),
                                          const VerticalSizedBox(height: 4.0),
                                          ..._getItemWidgets(
                                            context,
                                            availableItems.where((item) => _filters.excludedItems.contains(item))
                                          ),
                                          const VerticalSizedBox(),
                                        ],
                                      if (_filters.requiredItems.length + _filters.excludedItems.length != availableItems.length)
                                        ...[
                                          const Text('Available Items'),
                                          const VerticalSizedBox(height: 4.0),
                                          ..._getItemWidgets(
                                            context,
                                            availableItems.where((item) => !(_filters.requiredItems.contains(item) || _filters.excludedItems.contains(item)))
                                          ),
                                        ],
                                    ],
                                  );
                                }
                              },
                            )
                          ),

                          MaterialTextField(
                            labelText: 'Search Item',
                            onChanged: (input) => setState(() => _input = input),
                          ),
                        ],
                      ),
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
