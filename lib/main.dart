import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:viacep_dio/cep_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const keyApplicationId = '2oeVUBGsLbiC4t6vCFx4hJHTyN0YfPwHzoah8ISF';
  const keyClientKey = '6qrUTLZ2TbygUqSskUdRjHsuQ7jT4AkHLsyypdAu';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CEPProvider(),
      child: const MaterialApp(
        title: 'CEP App',
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CEP App'),
      ),
      body: CEPList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddCEPScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CEPList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cepProvider = Provider.of<CEPProvider>(context);
    return FutureBuilder(
      future: cepProvider.listarCEPs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Erro ao carregar os CEPs');
        } else {
          final ceps = snapshot.data as List<ParseObject>;
          return ListView.builder(
            itemCount: ceps.length,
            itemBuilder: (context, index) {
              final cep = ceps[index];
              return ListTile(
                title: Text(cep.get('cep')),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCEPScreen(cep: cep),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class AddCEPScreen extends StatelessWidget {
  final TextEditingController cepController = TextEditingController();

  AddCEPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar CEP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: cepController,
              decoration: const InputDecoration(labelText: 'CEP'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final cepService = CEPService();
                final cepData =
                    await cepService.consultarCEP(cepController.text);
                await cepService.cadastrarCEP(cepData);
                Navigator.pop(context);
              },
              child: const Text('Adicionar CEP'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditCEPScreen extends StatelessWidget {
  final ParseObject cep;

  EditCEPScreen({super.key, required this.cep});

  final TextEditingController newCEPController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar CEP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: newCEPController,
              decoration: const InputDecoration(labelText: 'Novo CEP'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final cepService = CEPService();
                await cepService.atualizarCEP(cep.objectId!, {
                  'cep': newCEPController.text,
                  // adicione outros campos conforme necessário
                });
                Navigator.pop(context);
              },
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}

class CEPProvider extends ChangeNotifier {
  final CEPService cepService = CEPService();

  Future<List<ParseObject>> listarCEPs() async {
    return cepService.listarCEPs();
  }
}
