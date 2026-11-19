import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../data/Database.dart';

import 'dart:io';
import 'dart:typed_data';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _selectedIndex = 0; // 0 = Pedidos, 1 = Inventario

  // --- DATOS SIMULADOS DE PEDIDOS ---
  final List<Map<String, dynamic>> incomingOrders = [
    {
      'id': '#1042',
      'student': 'Ignacio Miranda',
      'time': 'Hace 2 min',
      'items': ['2x Sándwich Ave', '1x Jugo'],
      'total': 6500,
      'status': 'Pendiente',
    },
    {
      'id': '#1043',
      'student': 'Valentina Rojas',
      'time': 'Hace 5 min',
      'items': ['1x Café', '1x Empanada'],
      'total': 2200,
      'status': 'Preparando',
    },
  ];

  // --- DATOS SIMULADOS DE INVENTARIO ---
  List<Map<String, dynamic>> get inventory => Database.products.value;

  Color _getStatusColor(String status) {
    if (status == 'Pendiente') return Colors.orange.shade600;
    if (status == 'Preparando') return Colors.blue.shade600;
    return Colors.green.shade600; // Listo
  }

  void _advanceOrderStatus(int index) {
    setState(() {
      if (incomingOrders[index]['status'] == 'Pendiente') {
        incomingOrders[index]['status'] = 'Preparando';
      } else if (incomingOrders[index]['status'] == 'Preparando') {
        incomingOrders[index]['status'] = 'Listo';
      } else {
        incomingOrders.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido entregado.'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    });
  }

  // --- FUNCIÓN DEL POP-UP PARA AGREGAR/EDITAR PRODUCTO ---
  void _showProductForm({int? index}) {
    final isEditing = index != null;
    final product = isEditing ? inventory[index] : null;

    final nameController = TextEditingController(
      text: isEditing ? product!['name'] : '',
    );
    final priceController = TextEditingController(
      text: isEditing ? product!['price'].toString() : '',
    );
    final stockController = TextEditingController(
      text: isEditing ? product!['stock'].toString() : '',
    );

    final categories = [
      'General',
      'Almuerzos',
      'Bebidas',
      'Snacks',
      'Saludable',
    ];

    String selectedCategory = isEditing
        ? (product!['category'] as String? ?? 'General')
        : 'General';

    // Si el producto tiene una categoría antigua que no está en la lista,
    // la agregamos para que el Dropdown pueda mostrarla.
    if (!categories.contains(selectedCategory)) {
      categories.add(selectedCategory);
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isEditing ? 'Editar Producto' : 'Nuevo Producto',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del producto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (category) {
                        if (category != null) {
                          setDialogState(() {
                            selectedCategory = category;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Precio (\$)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stock disponible',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF047857),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final price = int.tryParse(priceController.text);
                    final stock = int.tryParse(stockController.text);

                    if (name.isEmpty ||
                        price == null ||
                        stock == null ||
                        price < 0 ||
                        stock < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Completa los campos con valores válidos.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (isEditing) {
                      final updatedProduct = {
                        ...product!,
                        'name': name,
                        'category': selectedCategory,
                        'price': price,
                        'stock': stock,
                      };

                      Database.updateProduct(index, updatedProduct);
                    } else {
                      Database.addProduct({
                        'name': name,
                        'price': price,
                        'stock': stock,
                        'category': selectedCategory,
                        'imageBytes': null,
                      });
                    }

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Producto actualizado'
                              : 'Producto agregado',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
          },
        );
      },
    );
  }

  // --- FUNCIÓN PARA ELIMINAR PRODUCTO ---
  void _deleteProduct(int index) {
    Database.removeProduct(index);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Producto eliminado'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 252),
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Panel de Pedidos' : 'Inventario',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildOrdersView() : _buildInventoryView(),

      // Menú de navegación inferior del Dueño
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF047857).withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt, color: Color(0xFF047857)),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory, color: Color(0xFF047857)),
            label: 'Inventario',
          ),
        ],
      ),

      // Botón flotante para agregar productos (solo visible en inventario)
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showProductForm(), // Llama a la función sin índice (Agregar)
              backgroundColor: const Color(0xFF047857),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Nuevo Producto',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().scale(duration: 300.ms)
          : null,
    );
  }

  // ==========================================
  // VISTA 1: PEDIDOS (Ya la teníamos)
  // ==========================================
  Widget _buildOrdersView() {
    if (incomingOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green.shade300,
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            const Text(
              '¡Todo al día!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'No hay reservas pendientes.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: incomingOrders.length,
      itemBuilder: (context, index) {
        final order = incomingOrders[index];
        final statusColor = _getStatusColor(order['status']);
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['id'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        order['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order['student'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Divider(height: 24),
                ...List.generate(
                  order['items'].length,
                  (i) => Text(
                    '• ${order['items'][i]}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: \$${order['total']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: statusColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _advanceOrderStatus(index),
                      icon: Icon(
                        order['status'] == 'Listo' ? Icons.check : Icons.update,
                        size: 18,
                      ),
                      label: Text(
                        order['status'] == 'Listo'
                            ? 'Entregar'
                            : 'Avanzar Estado',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (150 * index).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  // ==========================================
  // VISTA 2: INVENTARIO (Tabla Visual)
  // ==========================================
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProductImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (!mounted || image == null) return;
      final Uint8List bytes = await image.readAsBytes();
      setState(() {
        Database.updateProductImage(index, bytes);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar la imagen: $e')),
      );
    }
  }

  Widget _buildInventoryView() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: Database.products,
      builder: (context, inventory, _) {
        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 80,
          ),
          itemCount: inventory.length,
          itemBuilder: (context, index) {
            final item = inventory[index];
            final stock = item['stock'] as int;
            final isLowStock = stock < 5;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen y datos principales
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item['imageBytes'] != null
                              ? Image.memory(
                                  item['imageBytes'] as Uint8List,
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.contain,
                                )
                              : Container(
                                  width: 85,
                                  height: 85,
                                  color: Colors.grey.shade100,
                                  child: const Icon(
                                    Icons.image,
                                    size: 35,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['category'] ?? 'General',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '\$${item['price']}',
                                style: const TextStyle(
                                  color: Color(0xFF047857),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Stock y acciones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Stock: ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isLowStock
                                    ? Colors.red.shade100
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                stock.toString(),
                                style: TextStyle(
                                  color: isLowStock
                                      ? Colors.red.shade700
                                      : Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Cambiar foto',
                              icon: const Icon(
                                Icons.add_a_photo,
                                color: Colors.teal,
                              ),
                              onPressed: () => _pickProductImage(index),
                            ),
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showProductForm(index: index),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0, duration: 300.ms);
          },
        );
      },
    );
  }
}
