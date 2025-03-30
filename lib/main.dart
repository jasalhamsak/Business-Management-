import 'package:flutter/material.dart';

void main() {
  runApp(const StockManagementApp());
}

class StockManagementApp extends StatelessWidget {
  const StockManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LaunchScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🔹 Launch Screen
// ─────────────────────────────────────────────────────────────
class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  List<Map<String, dynamic>> stock = [];
  String currencySymbol = "₹";
  List<String> categories = ["Electronics", "Groceries", "Clothing", "Others"];

  void updateCurrency(String newCurrency) {
    setState(() {
      currencySymbol = newCurrency;
    });
  }

  void addCategory(String category) {
    setState(() {
      if (!categories.contains(category)) {
        categories.add(category);
      }
    });
  }

  void removeCategory(String category) {
    setState(() {
      categories.remove(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Management"), actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  currencySymbol: currencySymbol,
                  categories: categories,
                  updateCurrency: updateCurrency,
                  addCategory: addCategory,
                  removeCategory: removeCategory,
                ),
              ),
            );
          },
        ),
      ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockManagementScreen(
                      stock: stock,
                      currencySymbol: currencySymbol,
                      categories: categories,
                    ),
                  ),
                );
              },
              child: const Text("Add Item"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockViewScreen(
                      stock: stock,
                      currencySymbol: currencySymbol,
                    ),
                  ),
                );
              },
              child: const Text("View Stock"),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🔹 Stock Management Screen (Add/Edit/Delete Items)
// ─────────────────────────────────────────────────────────────
class StockManagementScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stock;
  final String currencySymbol;
  final List<String> categories;

  const StockManagementScreen({super.key, required this.stock, required this.currencySymbol, required this.categories});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String selectedUnit = "kg";
  String selectedCategory = "Electronics";
  int? editingIndex; // Track which item is being edited

  void addItem() {
    if (itemNameController.text.isNotEmpty && quantityController.text.isNotEmpty && priceController.text.isNotEmpty) {
      setState(() {
        Map<String, dynamic> newItem = {
          'name': itemNameController.text,
          'unit': selectedUnit,
          'quantity': int.parse(quantityController.text),
          'price': double.parse(priceController.text),
          'category': selectedCategory,
        };

        if (editingIndex == null) {
          // Adding new item
          widget.stock.add(newItem);
        } else {
          // Editing existing item
          widget.stock[editingIndex!] = newItem;
          editingIndex = null; // Reset editing mode
        }
      });

      // Clear input fields
      itemNameController.clear();
      quantityController.clear();
      priceController.clear();
    }
  }

  void editItem(int index) {
    setState(() {
      itemNameController.text = widget.stock[index]['name'];
      selectedUnit = widget.stock[index]['unit'];
      quantityController.text = widget.stock[index]['quantity'].toString();
      priceController.text = widget.stock[index]['price'].toString();
      selectedCategory = widget.stock[index]['category'];
      editingIndex = index;
    });
  }

  void deleteItem(int index) {
    setState(() {
      widget.stock.removeAt(index);
      editingIndex = null; // Reset editing mode
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Stock")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(controller: itemNameController, decoration: const InputDecoration(labelText: 'Item Name')),
            DropdownButtonFormField(
              value: selectedUnit,
              items: ["kg", "liters", "pcs", "meters"].map((unit) {
                return DropdownMenuItem(value: unit, child: Text(unit));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedUnit = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Unit'),
            ),
            TextField(controller: quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
            DropdownButtonFormField(
              value: selectedCategory,
              items: widget.categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            ElevatedButton(
              onPressed: addItem,
              child: Text(editingIndex == null ? "Add Item" : "Update Item"),
            ),
            const SizedBox(height: 20),

            // 🔹 Recent Items List with Edit & Delete Options
            Expanded(
              child: ListView.builder(
                itemCount: widget.stock.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.stock[index]['name']),
                    subtitle: Text(
                        "${widget.stock[index]['quantity']} ${widget.stock[index]['unit']} - ${widget.currencySymbol}${widget.stock[index]['price']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editItem(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🔹 Stock View Screen (Display Stock Table)
// ─────────────────────────────────────────────────────────────
class StockViewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> stock;
  final String currencySymbol;

  const StockViewScreen({super.key, required this.stock, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Details")),
      body: ListView(
        children: [
          DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Unit')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Category')),
            ],
            rows: stock.map((item) {
              return DataRow(cells: [
                DataCell(Text(item['name'])),
                DataCell(Text(item['unit'])),
                DataCell(Text(item['quantity'].toString())),
                DataCell(Text("$currencySymbol ${item['price']}")),
                DataCell(Text(item['category'])),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🔹 Settings Screen (Manage Currency & Categories)
// ─────────────────────────────────────────────────────────────


class SettingsScreen extends StatefulWidget {
  final String currencySymbol;
  final List<String> categories;
  final Function(String) updateCurrency;
  final Function(String) addCategory;
  final Function(String) removeCategory;

  const SettingsScreen({
    super.key,
    required this.currencySymbol,
    required this.categories,
    required this.updateCurrency,
    required this.addCategory,
    required this.removeCategory,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController categoryController = TextEditingController();

  // 🔹 Currency List (Symbols Only)
  final List<String> currencyList = [
    "SAR", // Saudi Riyal
    "AED", // UAE Dirham
    "KWD", // Kuwaiti Dinar
    "BHD", // Bahraini Dinar
    "OMR", // Omani Rial
    "QAR", // Qatari Riyal
    "USD", // US Dollar
    "EUR", // Euro
    "INR", // Indian Rupee
  ];

  late String selectedCurrency;

  @override
  void initState() {
    super.initState();

    // If the passed currencySymbol is not in the list, default to SAR
    selectedCurrency = currencyList.contains(widget.currencySymbol)
        ? widget.currencySymbol
        : "SAR";
  }

  void addNewCategory() {
    String newCategory = categoryController.text.trim();
    if (newCategory.isNotEmpty && !widget.categories.contains(newCategory)) {
      widget.addCategory(newCategory);
      categoryController.clear();
      setState(() {}); // Refresh UI
    }
  }

  void deleteCategory(String category) {
    widget.removeCategory(category);
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Currency Selection
            const Text("Select Currency:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedCurrency,
              items: currencyList.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCurrency = value!;
                });
                widget.updateCurrency(selectedCurrency);
              },
            ),
            const SizedBox(height: 20),

            // 🔹 Manage Categories
            const Text("Manage Categories:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: "Add New Category",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addNewCategory,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.categories[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteCategory(widget.categories[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
