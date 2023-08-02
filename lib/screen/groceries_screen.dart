import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gocery_list/data/categories.dart';
import 'package:gocery_list/screen/add_groceries.dart';
import 'package:http/http.dart' as http;
import '../models.dart/grocery_item.dart';

class Groceries extends StatefulWidget {
  const Groceries({super.key});

  @override
  State<Groceries> createState() => _GroceriesState();
}

class _GroceriesState extends State<Groceries> {
  bool _isLoading = true;
  List<GroceryItem> groceryList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadGroceryList();
  }

  var url = Uri.https(
      'grocerylist-59ff0-default-rtdb.firebaseio.com', 'shopingList.json');

  Future<void> loadGroceryList() async {
    var response = await http.get(url);
    Map<String, dynamic> listData = jsonDecode(response.body);
    final List<GroceryItem> itemList = [];

    for (var item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value['category'])
          .value;
      itemList.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));

      setState(() {
        groceryList = itemList;
        _isLoading = false;
      });
    }
  }

  void _addItem(BuildContext context) async {
    final item = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (context) => const AddGroceries()));

    if (item == null) {
      return;
    }

    setState(() {
      groceryList.add(item);
    });
  }

  void _deleteItem(GroceryItem item) {
    var url = Uri.https('grocerylist-59ff0-default-rtdb.firebaseio.com',
        'shopingList/${item.id}.json');
    http.delete(url);
    setState(() {
      groceryList.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text("Ooh Uhh! No item present"));

    if (_isLoading == true) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (groceryList.isNotEmpty) {
      content = Padding(
        padding: const EdgeInsets.all(4),
        child: ListView.builder(
            itemCount: groceryList.length,
            itemBuilder: (BuildContext context, int index) {
              var groceryItem = groceryList[index];
              return Dismissible(
                key: Key(UniqueKey().toString()),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  // Remove the item from the data source.
                  setState(() {
                    _deleteItem(groceryItem);
                  });

                  // Then show a snackbar.
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('item delete')));
                },
                child: ListTile(
                    leading: Icon(
                      Icons.square,
                      color: groceryItem.category.color,
                    ),
                    trailing: Text(
                      "${groceryItem.quantity}",
                      style: const TextStyle(fontSize: 15),
                    ),
                    title: Text(groceryItem.name)),
              );
            }),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Groceries"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _addItem(context);
              },
            )
          ],
        ),
        body: content);
  }
}
