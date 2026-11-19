
import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/Database.dart';

class CartScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> catalog;

  const CartScreen({
    super.key,
    required this.cart,
    required this.catalog,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<String> timeSlots = [
    '11:00 - 12:00 hrs',
    '12:00 - 13:00 hrs',
    '13:00 - 14:00 hrs',
    '14:00 - 15:00 hrs',
  ];

  String? selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    selectedTimeSlot = timeSlots.first;
  }

  int _getPrice(Map<String, dynamic> item) {
    final value = item['price'];

    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<Map<String, dynamic>> get cartItems {
    return widget.catalog.where((item) {
      final name = item['name']?.toString();

      return name != null &&
          (widget.cart[name] ?? 0) > 0;
    }).toList();
  }

  int get totalPrice {
    return cartItems.fold(0, (total, item) {
      final name = item['name'].toString();
      final quantity = widget.cart[name] ?? 0;

      return total + (_getPrice(item) * quantity);
    });
  }

  void _changeQuantity(String name, int change) {
    setState(() {
      final newQuantity =
          (widget.cart[name] ?? 0) + change;

      if (newQuantity <= 0) {
        widget.cart.remove(name);
      } else if (newQuantity <= 2) {
        widget.cart[name] = newQuantity;
      }
    });
  }

  void _confirmReservation() {
    if (cartItems.isEmpty) return;

    if (selectedTimeSlot == null) return;

    final orderItems = cartItems.map((item) {
      final name = item['name'].toString();
      final quantity = widget.cart[name] ?? 0;

      return '$quantity x $name';
    }).join(', ');

    for (final item in cartItems) {
  final name = item['name'].toString();
  final quantity = widget.cart[name] ?? 0;

  final index = Database.products.value.indexWhere(
    (product) => product['name'] == name,
  );

  if (index != -1) {
    final currentStock =
        (Database.products.value[index]['stock'] as num?)?.toInt() ?? 0;

    if (quantity > currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock insuficiente para $name.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }
}

    Navigator.pop(context, {
      'total': totalPrice,
      'items': orderItems,
      'time': selectedTimeSlot,
      'date': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = cartItems;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        title: const Text(
          'Resumen de Reserva',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),

      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'El carrito está vacío.',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Tus productos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ...List.generate(items.length, (index) {
                        final item = items[index];
                        final name = item['name'].toString();
                        final quantity =
                            widget.cart[name] ?? 0;

                        final subtotal =
                            _getPrice(item) * quantity;

                        final Color itemColor =
                            item['color'] is Color
                                ? item['color'] as Color
                                : Colors.blue;

                        final IconData itemIcon =
                            item['icon'] is IconData
                                ? item['icon'] as IconData
                                : Icons.restaurant;

                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      itemColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  child: Icon(
                                    itemIcon,
                                    color: itemColor,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        '\$$subtotal',
                                        style: const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  onPressed: () =>
                                      _changeQuantity(name, -1),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),

                                Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                IconButton(
                                  onPressed: quantity < 2
                                      ? () => _changeQuantity(
                                            name,
                                            1,
                                          )
                                      : null,
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(
                              delay: (100 * index).ms,
                            ).slideX(
                              begin: 0.1,
                              end: 0,
                            );
                      }),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      const Text(
                        'Horario de Retiro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: selectedTimeSlot,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            Icons.access_time,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: timeSlots.map((slot) {
                          return DropdownMenuItem<String>(
                            value: slot,
                            child: Text(slot),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTimeSlot = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Si no retiras tu pedido dentro del bloque seleccionado ($selectedTimeSlot), la reserva será cancelada automáticamente.',
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total a pagar:',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),

                            Text(
                              '\$$totalPrice',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: FilledButton.icon(
                            onPressed: items.isEmpty
                                ? null
                                : _confirmReservation,
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context)
                                      .colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(
                              Icons.check_circle_outline,
                            ),
                            label: const Text(
                              'Confirmar Reserva',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(
                      begin: 1,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ),
    );
  }
}
