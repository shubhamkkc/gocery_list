import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gocery_list/models.dart/catergory.dart';
import 'package:gocery_list/models.dart/grocery_item.dart';
import 'package:http/http.dart' as http;

import '../data/categories.dart';

class AddGroceries extends StatefulWidget {
  const AddGroceries({super.key});

  @override
  State<AddGroceries> createState() => _AddGroceriesState();
}

class _AddGroceriesState extends State<AddGroceries> {
  bool _sendingData = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  String name = "";
  String quantity = "";
  var _selectedCategory = categories[Categories.vegetables]!;
  var url = Uri.https(
      'grocerylist-59ff0-default-rtdb.firebaseio.com', 'shopingList.json');

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _sendingData = true;
      });

      var body = {
        'name': name,
        'quantity': int.parse(quantity),
        'category': _selectedCategory.title
      };
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));

      if (!context.mounted) {
        return;
      }
      final Map<String, dynamic> result = json.decode(response.body);

      Navigator.pop(
          context,
          GroceryItem(
              name: name,
              quantity: int.parse(quantity),
              category: _selectedCategory,
              id: result['name']));

      // Navigator.pop(
      //     context,
      //     GroceryItem(
      //         id: DateTime.now().second.toString(),
      //         name: name,
      //         quantity: int.parse(quantity),
      //         category: _selectedCategory));
      print("$name $quantity $_selectedCategory");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                        maxLength: 20,
                        decoration: const InputDecoration(
                          labelText: "Name",
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().length <= 0 ||
                              value.trim().length >= 50) {
                            return "value must be between 0 and 50";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          name = value!;
                        }),
                    Row(
                      // mainAxisSize: EdgeInsets.all(double.infinity),
                      children: [
                        Expanded(
                          child: TextFormField(
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    int.tryParse(value) == null ||
                                    int.tryParse(value)! < 0) {
                                  return "Must be enter a valid, postive number";
                                }
                                return null;
                              },
                              initialValue: "1",
                              decoration:
                                  const InputDecoration(labelText: "Quantity"),
                              onSaved: (value) {
                                quantity = value!;
                              }),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Expanded(
                          child: DropdownButtonFormField(
                              value: _selectedCategory,
                              items: [
                                for (final category in categories.entries)
                                  DropdownMenuItem(
                                      value: category.value,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.square,
                                            color: category.value.color,
                                          ),
                                          Text(category.value.title)
                                        ],
                                      ))
                              ],
                              onChanged: (value) =>
                                  {_selectedCategory = value!}),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: _sendingData
                                ? null
                                : () {
                                    _formKey.currentState!.reset();
                                  },
                            child: const Text("Reset")),
                        ElevatedButton(
                            onPressed: () {
                              _onSubmit();
                            },
                            child: _sendingData
                                ? const CircularProgressIndicator()
                                : const Text("Add Item"))
                      ],
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
