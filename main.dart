
import 'package:flutter/material.dart';

void main() {
  runApp(const GasDiscountApp());
}

class GasDiscountApp extends StatelessWidget {
  const GasDiscountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '加油折扣計算',
      debugShowCheckedModeBanner: false,
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
  final oilPriceController = TextEditingController(text: '30');
  final literController = TextEditingController(text: '20');
  final discountController = TextEditingController(text: '5');

  double result = 0;

  void calculate() {
    final oil = double.tryParse(oilPriceController.text) ?? 0;
    final liter = double.tryParse(literController.text) ?? 0;
    final discount = double.tryParse(discountController.text) ?? 0;

    setState(() {
      result = (oil * liter) - discount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('加油折扣計算'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: oilPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '油價'),
            ),
            TextField(
              controller: literController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '公升'),
            ),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '折扣'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculate,
              child: const Text('計算'),
            ),
            const SizedBox(height: 20),
            Text(
              '總金額: ${result.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
