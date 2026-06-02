import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
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
  // ==========================================
  // CONFIGURAÇÕES BROKER MQTT
  // ==========================================
  final String brokerUrl = 'wss://1638f261a5864ed5b1ec3b3c10376baa.s1.eu.hivemq.cloud';
  final int brokerPort = 8884;
  final String mqttUser = 'Cotuca';
  final String mqttPass = 'Cotuca123';
  final String mqttTopic = 'HotWheelsIOT';

  MqttBrowserClient? client;
  bool isConnected = false;
  String mensagemRecebida = 'Nenhuma mensagem ainda...';

  @override
  void initState() {
    super.initState();
    _setupMqtt();
  }

  Future<void> _setupMqtt() async {
    // Configura o cliente para WebSockets
    client = MqttBrowserClient(brokerUrl, 'flutter_web_client_${DateTime.now().millisecondsSinceEpoch}');
    client!.port = brokerPort;
    client!.keepAlivePeriod = 20;
    client!.onConnected = _onConnected;
    client!.onDisconnected = _onDisconnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_web_client')
        .authenticateAs(mqttUser, mqttPass)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    
    client!.connectionMessage = connMess;

    try {
      print('Conectando ao broker MQTT...');
      await client!.connect();
    } catch (e) {
      print('Erro ao conectar: $e');
      client!.disconnect();
    }

    // Se conectou com sucesso, inscreve no tópico
    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      client!.subscribe(mqttTopic, MqttQos.atMostOnce);
      
      // Fica escutando as mensagens do ESP32
      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        print('Mensagem recebida: $payload');
        
        // Atualiza a tela com o valor recebido
        setState(() {
          try {
            var data = jsonDecode(payload);
            if (data.containsKey('msg')) {
              mensagemRecebida = data['msg'];
            }
          } catch (e) {
            mensagemRecebida = payload; // Se não for JSON, mostra o texto puro
          }
        });
      });
    }
  }

  void _onConnected() {
    setState(() {
      isConnected = true;
    });
    print('MQTT Conectado com sucesso!');
  }

  void _onDisconnected() {
    setState(() {
      isConnected = false;
    });
    print('MQTT Desconectado!');
  }

  // Função disparada ao apertar o botão
  void _lancarCarrinho() {
    if (isConnected && client != null) {
      const comandoStr = '{"comando": "LANCAR"}';
      final builder = MqttClientPayloadBuilder();
      builder.addString(comandoStr);
      
      client!.publishMessage(mqttTopic, MqttQos.atLeastOnce, builder.payload!);
      print('Comando de lançamento enviado!');
    } else {
      print('Não é possível lançar: MQTT Desconectado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projeto Hot Wheels'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        actions: [
          IconButton(
            icon: Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: isConnected ? Colors.green : Colors.red,
            ),
            onPressed: () {},
            tooltip: isConnected ? 'Conectado' : 'Desconectado',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.memory, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ESP32 Diz: $mensagemRecebida',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Seção de Controle ---
            _buildSectionTitle('Controle do Lançador'),
            const SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConnected ? Colors.redAccent : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 8,
                  ),
                  onPressed: isConnected ? _lancarCarrinho : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch, size: 50),
                      Text(
                        isConnected ? 'LANÇAR' : 'OFFLINE', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildSectionTitle('Configuração da Pista'),
            Row(
              children: [
                Expanded(child: _buildInputField('Altura (cm)', Icons.height)),
                const SizedBox(width: 10),
                Expanded(child: _buildInputField('Distância (cm) até o sensor', Icons.straighten)),
              ],
            ),
            const SizedBox(height: 20),

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
          ],
        ),
      ),
    );
  }

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