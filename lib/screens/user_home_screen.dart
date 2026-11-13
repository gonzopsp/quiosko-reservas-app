import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'cart_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // --- ESTADOS DE LA NAVEGACIÓN ---
  int _selectedIndex = 0; // 0 = Catálogo, 1 = Mis Pedidos

  // --- ESTADOS DEL CATÁLOGO ---
  Map<String, int> cart = {};
  String selectedCategory = 'Todos';
  final List<String> categories = ['Todos', 'Bebidas', 'Snacks', 'Almuerzos', 'Saludable'];

  final List<Map<String, dynamic>> products = [
    {'name': 'Sándwich Ave Palta', 'price': 2500, 'icon': Icons.lunch_dining, 'color': Colors.orange},
    {'name': 'Jugo Natural', 'price': 1500, 'icon': Icons.local_drink, 'color': Colors.green},
    {'name': 'Empanada Queso', 'price': 1200, 'icon': Icons.bakery_dining, 'color': Colors.amber},
    {'name': 'Café Americano', 'price': 1000, 'icon': Icons.coffee, 'color': Colors.brown},
    {'name': 'Barra de Proteína', 'price': 1800, 'icon': Icons.fitness_center, 'color': Colors.purple},
    {'name': 'Ensalada César', 'price': 3500, 'icon': Icons.eco, 'color': Colors.lightGreen},
  ];

  // --- DATOS SIMULADOS DE MIS PEDIDOS ---
  final List<Map<String, dynamic>> activeOrders = [
    {'id': '#1045', 'date': 'Hoy, 16:35', 'total': 4000, 'status': 'Preparando', 'items': '1x Sándwich, 1x Jugo', 'color': Colors.blue},
  ];

  final List<Map<String, dynamic>> pastOrders = [
    {'id': '#0982', 'date': 'Ayer', 'total': 2500, 'status': 'Entregado', 'items': '1x Sándwich Ave Palta', 'color': Colors.grey},
    {'id': '#0850', 'date': '05 Nov 2026', 'total': 1200, 'status': 'Entregado', 'items': '1x Empanada Queso', 'color': Colors.grey},
  ];

  int get totalItemsInCart => cart.values.fold(0, (sum, qty) => sum + qty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        // El título cambia según la pestaña
        title: Text(
          _selectedIndex == 0 ? '¿Qué comeremos hoy?' : 'Mis Pedidos', 
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)
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
      
      // El cuerpo cambia dependiendo del índice seleccionado
      body: _selectedIndex == 0 ? _buildCatalogView() : _buildMyOrdersView(),

      // Menú de navegación inferior
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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

      // El botón flotante solo se muestra en la pestaña Catálogo (0) y si hay productos
      floatingActionButton: (_selectedIndex == 0 && totalItemsInCart > 0)
          ? FloatingActionButton.extended(
              onPressed: () async {
                final orderConfirmed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(cart: cart, catalog: products),
                  ),
                );
                if (orderConfirmed == true) {
                  setState(() {
                    cart.clear();
                    // Opcional: Podrías cambiar _selectedIndex a 1 para llevarlo a sus pedidos al instante
                    _selectedIndex = 1; 
                  });
                }
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                'Reservar ($totalItemsInCart)',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack)
          : null,
    );
  }

  // ==========================================
  // VISTA 1: EL CATÁLOGO (Lo que ya teníamos)
  // ==========================================
  Widget _buildCatalogView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

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
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (bool selected) => setState(() => selectedCategory = category),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              );
            },
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductCard(products[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    final String name = product['name'];
    final int currentQty = cart[name] ?? 0;

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: product['color'].withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(product['icon'], size: 40, color: product['color']),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${product['price']}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                InkWell(
                  onTap: () {
                    if (currentQty >= 2) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Límite: Máximo 2 "$name".'), backgroundColor: Colors.orange.shade700, duration: const Duration(seconds: 2)));
                      return;
                    }
                    setState(() => cart[name] = currentQty + 1);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: currentQty >= 2 ? Colors.grey : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: currentQty > 0 ? Text('$currentQty', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : const Icon(Icons.add, color: Colors.white, size: 20),
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
  // VISTA 2: MIS PEDIDOS (Nueva pestaña)
  // ==========================================
  Widget _buildMyOrdersView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Título de la sección en curso
        const Text(
          'En curso',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ).animate().fadeIn(),
        const SizedBox(height: 12),
        
        // Generar lista de pedidos activos
        ...activeOrders.map((order) => _buildOrderTile(order)).toList(),

        const SizedBox(height: 24),
        
        // Título de la sección historial
        const Text(
          'Historial de pedidos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),

        // Generar lista de pedidos pasados
        ...pastOrders.map((order) => _buildOrderTile(order)).toList(),
      ],
    );
  }

  Widget _buildOrderTile(Map<String, dynamic> order) {
    Color statusColor = order['color'];
    bool isActive = order['status'] != 'Entregado';

    return Card(
      elevation: isActive ? 4 : 1, // Más sombra si está activo
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
                Text(order['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(order['items'], style: const TextStyle(color: Colors.black87, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(order['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Text('\$${order['total']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}