import 'package:flutter/material.dart';

void main() {
  runApp(const HotWheelsLabApp());
}

class HotWheelsLabApp extends StatelessWidget {
  const HotWheelsLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TI328 - Automação Hot Wheels',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hot Wheels Physics Lab'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_connected, color: Colors.blue),
            onPressed: () {}, // Futura conexão com ESP32
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Seção de Controle ---
            _buildSectionTitle('Controle do Lançador'),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 8,
                  ),
                  onPressed: () {
                    // TODO: Implementar trigger para o ESP32
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch, size: 50),
                      Text('LANÇAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Seção de Dados de Entrada (Setup) ---
            _buildSectionTitle('Configuração da Pista'),
            Row(
              children: [
                Expanded(
                  child: _buildInputField('Altura (cm)', Icons.height),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInputField('Distância (cm)', Icons.straighten),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Seção de Resultados (Telemetria) ---
            _buildSectionTitle('Telemetria do Último Lançamento'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _buildDataCard('Velocidade', '0.00 m/s', Icons.speed, Colors.greenAccent),
                _buildDataCard('Tempo Total', '0.000 s', Icons.timer, Colors.blueAccent),
                _buildDataCard('Aceleração', '0.0 m/s²', Icons.trending_up, Colors.orangeAccent),
                _buildDataCard('E. Cinética', '0.00 J', Icons.bolt, Colors.purpleAccent),
              ],
            ),
            const SizedBox(height: 30),

            // --- Seção de Histórico ---
            _buildSectionTitle('Histórico de Lançamentos'),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.separated(
                itemCount: 3, // Exemplo
                separatorBuilder: (context, index) => const Divider(color: Colors.white24),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('Lançamento #${index + 1} - Reta'),
                    subtitle: const Text('Vel: 1.45 m/s | Tempo: 0.85s'),
                    trailing: const Icon(Icons.chevron_right),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets Auxiliares de Estilização
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }

  Widget _buildDataCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 5),
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}