
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const GasDiscountApp());
}

class GasDiscountApp extends StatelessWidget {
  const GasDiscountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '加油折扣計算',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final amountController = TextEditingController();
  final priceController = TextEditingController();

  String fuelType = '九二';
  String discountType = '一般現金';
  double result = 0;
  List<String> records = [];

  final Map<String, Map<String, double>> discounts = {
    '柴油': {'一般現金': 0, '聯名卡': 0.8, 'VIP現金': 1.0, 'VIP刷卡': 0.9, '降1.5元': 1.5},
    '九二': {'一般現金': 0, '聯名卡平日': 1.2, '聯名卡週三': 1.5, 'VIP現金': 2.0, 'VIP刷卡': 1.8, '降3元': 3.0},
    '九五': {'一般現金': 0, '聯名卡平日': 1.2, '聯名卡週三': 1.5, 'VIP現金': 2.0, 'VIP刷卡': 1.8, '降3元': 3.0},
    '九八': {'一般現金': 0, '聯名卡平日': 1.2, '聯名卡週三': 1.5, 'VIP現金': 2.0, 'VIP刷卡': 1.8, '降3元': 3.0},
  };

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      records = prefs.getStringList('records') ?? [];
    });
  }

  Future<void> saveRecord(String record) async {
    final prefs = await SharedPreferences.getInstance();
    records.insert(0, record);
    if (records.length > 10) {
      records = records.take(10).toList();
    }
    await prefs.setStringList('records', records);
    setState(() {});
  }

  void calculate() {
    double amount = double.tryParse(amountController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0;
    double discount = discounts[fuelType]![discountType] ?? 0;

    if (price > discount) {
      result = amount / (price - discount) * price;
      final record = jsonEncode({
        "time": DateTime.now().toString(),
        "fuel": fuelType,
        "price": price,
        "discount": discountType,
        "amount": amount,
        "result": result.toStringAsFixed(2),
      });
      saveRecord(record);
    } else {
      result = 0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final discountOptions = discounts[fuelType]!.keys.toList();

    if (!discountOptions.contains(discountType)) {
      discountType = discountOptions.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('加油折扣計算')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButton<String>(
                value: fuelType,
                isExpanded: true,
                items: discounts.keys.map((e) =>
                  DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) {
                  setState(() {
                    fuelType = value!;
                  });
                },
              ),
              DropdownButton<String>(
                value: discountType,
                isExpanded: true,
                items: discountOptions.map((e) =>
                  DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) {
                  setState(() {
                    discountType = value!;
                  });
                },
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '輸入油價'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '輸入加油金額'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: calculate,
                child: const Text('開始計算'),
              ),
              const SizedBox(height: 20),
              Text(
                '實際可加油金額：${result.toStringAsFixed(2)} 元',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 30),
              const Text('最近 10 筆紀錄'),
              ...records.map((r) {
                final item = jsonDecode(r);
                return ListTile(
                  title: Text('${item["fuel"]} - ${item["amount"]}元'),
                  subtitle: Text(
                    '${item["time"]}\n油價:${item["price"]} 折扣:${item["discount"]} 結果:${item["result"]}'
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
