import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CartScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> catalog;

  const CartScreen({super.key, required this.cart, required this.catalog});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Lista de bloques horarios disponibles
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
    // Seleccionamos el primer bloque por defecto
    selectedTimeSlot = timeSlots.first;
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.catalog.where((p) => widget.cart.containsKey(p['name']) && widget.cart[p['name']]! > 0).toList();
    
    int totalPrice = 0;
    for (var item in cartItems) {
      totalPrice += (item['price'] as int) * widget.cart[item['name']]!;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Resumen de Reserva', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('El carrito está vacío.'))
          : Column(
              children: [
                // Lista de productos scrolleable
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Tus productos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      
                      // Generar las tarjetas de los productos
                      ...List.generate(cartItems.length, (index) {
                        final item = cartItems[index];
                        final qty = widget.cart[item['name']]!;
                        final subtotal = (item['price'] as int) * qty;

                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item['color'].withOpacity(0.2),
                              child: Icon(item['icon'], color: item['color']),
                            ),
                            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Cantidad: $qty'),
                            trailing: Text('\$$subtotal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
                      }),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // SECCIÓN: Bloque de Retiro
                      const Text(
                        'Horario de Retiro',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      
                      DropdownButtonFormField<String>(
                        value: selectedTimeSlot,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.access_time, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: timeSlots.map((String slot) {
                          return DropdownMenuItem(
                            value: slot,
                            child: Text(slot, style: const TextStyle(fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedTimeSlot = newValue;
                          });
                        },
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 16),

                      // Alerta de política de cancelación
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Si no retiras tu pedido dentro del bloque seleccionado ($selectedTimeSlot), la reserva será cancelada automáticamente.',
                                style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
                
                // Panel inferior con el total
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total a pagar:', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            Text(
                              '\$$totalPrice',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Reserva confirmada para retiro: $selectedTimeSlot'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context, true);
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Confirmar Reserva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
              ],
            ),
    );
  }
}