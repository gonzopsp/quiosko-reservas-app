import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

class Database {
  Database._();

  static final ValueNotifier<List<Map<String, dynamic>>> products =
      ValueNotifier([
    {
      'name': 'Sándwich Ave Palta',
      'price': 2500,
      'stock': 15,
      'category': 'Almuerzos',
      'imageBytes': null,
    },
    {
      'name': 'Jugo Natural',
      'price': 1500,
      'stock': 20,
      'category': 'Bebidas',
      'imageBytes': null,
    },
    {
      'name': 'Empanada Queso',
      'price': 1200,
      'stock': 4,
      'category': 'Snacks',
      'imageBytes': null,
    },
    {
      'name': 'Café Americano',
      'price': 1000,
      'stock': 50,
      'category': 'Bebidas',
      'imageBytes': null,
    },
  ]);

static Future<void> initializeImages() async {
  try {
    final images = [
      'assets/images/sandwich.jpg',
      'assets/images/jugo.png',
      'assets/images/empanada.jpg',
      'assets/images/cafe.webp',
    ];

    final updated = [...products.value];

    for (int i = 0; i < images.length; i++) {
      final data = await rootBundle.load(images[i]);

      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      updated[i] = {
        ...updated[i],
        'imageBytes': bytes,
      };

      debugPrint(
        '${updated[i]['name']}: ${bytes.length} bytes',
      );
    }

    products.value = updated;

  } catch (e, stackTrace) {
    debugPrint('ERROR: $e');
    debugPrint('$stackTrace');
  }
}

  static void addProduct(Map<String, dynamic> product) {
    products.value = [...products.value, product];
  }

  static void updateStock(int index, int newStock) {
    final updated = [...products.value];

    updated[index] = {
      ...updated[index],
      'stock': newStock,
    };

    products.value = updated;
  }

  static void updateProduct(
    int index,
    Map<String, dynamic> product,
  ) {
    final updated = [...products.value];
    updated[index] = product;
    products.value = updated;
  }

  static void removeProduct(int index) {
    final updated = [...products.value];
    updated.removeAt(index);
    products.value = updated;
  }

  static void updateProductImage(int index, Uint8List bytes) {
    final updated = [...products.value];

    updated[index] = {
      ...updated[index],
      'imageBytes': bytes,
    };

    products.value = updated;
  }
}