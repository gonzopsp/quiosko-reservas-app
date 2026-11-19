import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'dart:typed_data';

import 'cart_screen.dart';
import '../data/Database.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;

  // CATÁLOGO
  Map<String, int> cart = {};

  String selectedCategory = 'Todos';
  String searchQuery = '';

  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'Todos',
    'Bebidas',
    'Snacks',
    'Almuerzos',
    'Saludable',
    'General',
  ];

  // PEDIDOS SIMULADOS
  final List<Map<String, dynamic>> activeOrders = [
    {
      'id': '#1045',
      'date': 'Hoy, 16:35',
      'total': 4000,
      'status': 'Preparando',
      'items': '1x Sándwich, 1x Jugo',
      'color': Colors.blue,
    },
  ];

  final List<Map<String, dynamic>> pastOrders = [
    {
      'id': '#0982',
      'date': 'Ayer',
      'total': 2500,
      'status': 'Entregado',
      'items': '1x Sándwich Ave Palta',
      'color': Colors.grey,
    },
    {
      'id': '#0850',
      'date': '05 Nov 2026',
      'total': 1200,
      'status': 'Entregado',
      'items': '1x Empanada Queso',
      'color': Colors.grey,
    },
  ];

  int get totalItemsInCart => cart.values.fold(0, (sum, qty) => sum + qty);

  // FILTRAR PRODUCTOS
  List<Map<String, dynamic>> filterProducts(
    List<Map<String, dynamic>> products,
  ) {
    return products.where((product) {
      final category = product['category']?.toString() ?? '';
      final name = product['name']?.toString().toLowerCase() ?? '';

      final matchesCategory =
          selectedCategory == 'Todos' ||
          category.toLowerCase() == selectedCategory.toLowerCase();

      final matchesSearch = name.contains(searchQuery.toLowerCase().trim());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? '¿Qué comeremos hoy?' : 'Mis Pedidos',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Cerrar sesión',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),

      body: _selectedIndex == 0 ? _buildCatalogView() : _buildMyOrdersView(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: Theme.of(context).colorScheme.primary
            .withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu, color: Colors.blue),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Colors.blue),
            label: 'Mis Pedidos',
          ),
        ],
      ),

      floatingActionButton: (_selectedIndex == 0 && totalItemsInCart > 0)
          ? FloatingActionButton.extended(
              onPressed: () async {
                final reservation = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(
                      cart: cart,
                      catalog: Database.products.value,
                    ),
                  ),
                );

                if (!mounted) return;

                if (reservation != null) {
                  final DateTime date = reservation['date'];

                  setState(() {
                    activeOrders.insert(0, {
                      'id': '#${DateTime.now().millisecondsSinceEpoch % 10000}',
                      'date':
                          'Hoy, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                      'total': reservation['total'],
                      'status': 'Preparando',
                      'items':
                          '${reservation['items']} | Retiro: ${reservation['time']}',
                      'color': Colors.blue,
                    });

                    cart.clear();
                    _selectedIndex = 1;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '¡Reserva confirmada! Retiro: ${reservation['time']}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },

              backgroundColor: Theme.of(context).colorScheme.secondary,
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                'Reservar ($totalItemsInCart)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack)
          : null,
    );
  }

  // ==========================================
  // CATÁLOGO
  // ==========================================

  Widget _buildCatalogView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BUSCADOR
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
        ),

        // FILTROS DE CATEGORÍA
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selectedCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        // PRODUCTOS FILTRADOS
        Expanded(
          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: Database.products,
            builder: (context, products, _) {
              final filteredProducts = filterProducts(products);

              if (filteredProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 65,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No se encontraron productos',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Prueba otra categoría o búsqueda.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                            selectedCategory = 'Todos';
                          });
                        },
                        child: const Text('Limpiar filtros'),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];

                  return _buildProductCard(product, index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TARJETA DE PRODUCTO
  // ==========================================

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    final String name = product['name'];
    final int currentQty = cart[name] ?? 0;
    final int stock = (product['stock'] as num?)?.toInt() ?? 0;

    final bool hasStock = currentQty < stock;

    final imageBytes = product['imageBytes'];

    return Card(
      key: ValueKey('${product['name']}_${imageBytes?.length ?? 0}'),
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          imageBytes as Uint8List,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.red,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Colors.green,
                      ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product['price']}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                InkWell(
                  onTap: () {
                    if (currentQty >= 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Límite: Máximo 2 "$name".'),
                          backgroundColor: Colors.orange.shade700,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      cart[name] = currentQty + 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: currentQty >= 2
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: currentQty > 0
                        ? Text(
                            '$currentQty',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.2, end: 0);
  }

  // ==========================================
  // MIS PEDIDOS
  // ==========================================

  Widget _buildMyOrdersView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'En curso',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ).animate().fadeIn(),

        const SizedBox(height: 12),

        ...activeOrders.map((order) => _buildOrderTile(order)),

        const SizedBox(height: 24),

        const Text(
          'Historial de pedidos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 12),

        ...pastOrders.map((order) => _buildOrderTile(order)),
      ],
    );
  }

  Widget _buildOrderTile(Map<String, dynamic> order) {
    final Color statusColor = order['color'];
    final bool isActive = order['status'] != 'Entregado';

    return Card(
      elevation: isActive ? 4 : 1,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['id'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
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

            const Divider(height: 24),

            Text(
              order['items'],
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order['date'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

                Text(
                  '\$${order['total']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
