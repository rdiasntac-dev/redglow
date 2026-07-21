import 'package:flutter/material.dart';

void main() {
  runApp(const RedGlowApp());
}

class RedGlowApp extends StatelessWidget {
  const RedGlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RedGlow - Beleza em Domicílio',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFF2A5F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF2A5F),
          secondary: Color(0xFFFF7597),
          surface: Color(0xFF1E1E24),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// 1. TELA DE APRESENTAÇÃO / SPLASH
// ==========================================
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1E24), Color(0xFF121212)],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_rounded, size: 90, color: Color(0xFFFF2A5F)),
            const SizedBox(height: 20),
            const Text(
              'RedGlow',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              'Beleza a domicílio com proteção total antifraude e sistema Glow',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2A5F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SecurityValidationScreen()),
                  );
                },
                child: const Text('Entrar com Segurança', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. TELA DE VALIDAÇÃO DE IDENTIDADE RIGOROSA (Anti-Fraude)
// ==========================================
class SecurityValidationScreen extends StatefulWidget {
  const SecurityValidationScreen({super.key});

  @override
  State<SecurityValidationScreen> createState() => _SecurityValidationScreenState();
}

class _SecurityValidationScreenState extends State<SecurityValidationScreen> {
  bool _docVerified = false;
  bool _faceVerified = false;

  void _completeValidation() {
    if (!_docVerified || !_faceVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, valide o documento e a foto facial para continuar.')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validação de Identidade', style: TextStyle(fontSize: 16)), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Segurança Rigorosa Anti-Fraude', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Para proteger clientes e prestadoras, exigimos checagem visual e documental.', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            const SizedBox(height: 30),
            ListTile(
              tileColor: const Color(0xFF1E1E24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: Icon(Icons.badge, color: _docVerified ? Colors.green : const Color(0xFFFF2A5F)),
              title: const Text('Documento Oficial (RG/CNH)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(_docVerified ? 'Verificado com Sucesso' : 'Pendente', style: TextStyle(color: _docVerified ? Colors.greenAccent : Colors.grey)),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                onPressed: () => setState(() => _docVerified = true),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              tileColor: const Color(0xFF1E1E24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: Icon(Icons.face, color: _faceVerified ? Colors.green : const Color(0xFFFF2A5F)),
              title: const Text('Reconhecimento Facial', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(_faceVerified ? 'Confirmado com Sucesso' : 'Pendente', style: TextStyle(color: _faceVerified ? Colors.greenAccent : Colors.grey)),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                onPressed: () => setState(() => _faceVerified = true),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2A5F),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _completeValidation,
              child: const Text('Acessar Aplicativo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. ESTRUTURA PRINCIPAL DE ABAS (Bottom Nav)
// ==========================================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const GlowPointsScreen(), // ABA DE PONTOS GLOW
    const ProviderDashboardScreen(), // ABA DA PROFISSIONAL / PRESTADORA
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF18181C),
        selectedItemColor: const Color(0xFFFF2A5F),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.star_rate_rounded), label: 'Pontos Glow'), // Glow Points
          BottomNavigationBarItem(icon: Icon(Icons.work_rounded), label: 'Painel Profissional'), // Aba Prestadora
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ==========================================
// 4. TELA DE EXPLORAR (Home / Estilo Figma)
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  final List<Map<String, dynamic>> _professionals = [
    {
      'name': 'Juliana Silva',
      'category': 'Unhas',
      'specialty': 'Manicure & Pedicure em Domicílio',
      'rating': 4.9,
      'distance': '1.2 km',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    },
    {
      'name': 'Camila Santos',
      'category': 'Sobrancelha',
      'specialty': 'Designer de Sobrancelhas & Lash',
      'rating': 5.0,
      'distance': '2.5 km',
      'image': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
    },
  ];

  final List<String> _categories = ['Todos', 'Unhas', 'Sobrancelha', 'Cabelo', 'Maquiagem'];

  List<Map<String, dynamic>> get _filteredProfessionals {
    return _professionals.where((pro) {
      final matchesSearch = pro['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pro['specialty'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Todos' || pro['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFFF2A5F).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.location_on, color: Color(0xFFFF2A5F), size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sua Localização', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                const Text('Rua das Flores, 123 - SP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar profissional ou serviço...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF2A5F)),
                filled: true,
                fillColor: const Color(0xFF1E1E24),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            // Banner Estilo Figma
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF2A5F), Color(0xFFFF7597)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Beleza em Domicílio Protegida', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Ganhe pontos Glow a cada atendimento!', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(Icons.verified_user_rounded, color: Colors.white, size: 30),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Categorias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFF2A5F),
                      backgroundColor: const Color(0xFF1E1E24),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey[400], fontSize: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                      onSelected: (selected) => setState(() => _selectedCategory = cat),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Profissionais Disponíveis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredProfessionals.length,
              itemBuilder: (context, index) {
                final pro = _filteredProfessionals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E24), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(pro['image'], width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(pro['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                const SizedBox(width: 4),
                                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 13),
                              ],
                            ),
                            Text(pro['specialty'], style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                            const SizedBox(height: 4),
                            Text('⭐ ${pro['rating']} • ${pro['distance']}', style: const TextStyle(fontSize: 11, color: Colors.amber)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2A5F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TrackingAndPinScreen(proName: pro['name'])),
                          );
                        },
                        child: const Text('Chamar', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. TELA DE PONTOS GLOW (Cashback & Fidelidade)
// ==========================================
class GlowPointsScreen extends StatelessWidget {
  const GlowPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pontos Glow'), backgroundColor: const Color(0xFF1E1E24)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF2A5F), Color(0xFFFF7597)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(Icons.star_rounded, size: 50, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Saldo Atual', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('450 Pontos Glow', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Equivale a R$ 45,00 de desconto nos próximos serviços', style: TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Como ganhar pontos Glow:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            const ListTile(
              tileColor: Color(0xFF1E1E24),
              leading: Icon(Icons.check_circle_outline, color: Color(0xFFFF2A5F)),
              title: Text('Realizar atendimentos em casa', style: TextStyle(color: Colors.white, fontSize: 13)),
              trailing: Text('+50 pts', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            const ListTile(
              tileColor: Color(0xFF1E1E24),
              leading: Icon(Icons.share, color: Color(0xFFFF2A5F)),
              title: Text('Indicar amigas para a plataforma', style: TextStyle(color: Colors.white, fontSize: 13)),
              trailing: Text('+100 pts', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),