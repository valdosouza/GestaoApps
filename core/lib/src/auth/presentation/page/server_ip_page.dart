import 'package:core/src/core/shared/constants.dart';
import 'package:core/src/core/shared/helpers/local_storage.dart';
import 'package:core/src/core/shared/local_storage_key.dart';
import 'package:core/src/core/shared/theme.dart';
import 'package:core/src/core/shared/widgets/degrade_area.dart';
import 'package:core/src/core/shared/widgets/logo_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:http/http.dart' as http;

/// Tela exibida quando o IP do servidor ainda não foi configurado,
/// ou quando o usuário acessa "Configurar servidor" na tela de login.
///
/// Salva o IP via SharedPreferences usando [LocalStorageKey.serverIp]
/// e redireciona para a tela de login após validação bem-sucedida.
class ServerIpPage extends StatefulWidget {
  const ServerIpPage({super.key});

  @override
  State<ServerIpPage> createState() => _ServerIpPageState();
}

class _ServerIpPageState extends State<ServerIpPage> {
  final _form = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _institutionController = TextEditingController();
  bool _testing = false;
  String? _testResult;
  bool _testSuccess = false;

  // Regex para IPv4 simples: 0-255.0-255.0-255.0-255
  static final _ipRegex = RegExp(
    r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
  );

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final savedIp = await LocalStorageService.instance
        .get(key: LocalStorageKey.serverIp, defaultValue: '');
    if (savedIp != null && savedIp.toString().isNotEmpty) {
      _ipController.text = savedIp.toString();
    }

    final savedInstitution = await LocalStorageService.instance
        .get(key: 'institution', defaultValue: '');
    if (savedInstitution != null && savedInstitution.toString().isNotEmpty) {
      _institutionController.text = savedInstitution.toString();
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  String? _validateIp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o endereço IP do servidor';
    }
    if (!_ipRegex.hasMatch(value.trim())) {
      return 'IP inválido. Ex: 192.168.0.10';
    }
    return null;
  }

  String? _validateInstitution(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o estabelecimento';
    }
    return null;
  }

  Future<void> _testConnection() async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }

    final ip = _ipController.text.trim();
    final testUrl = buildBaseApiUrl(ip);

    setState(() {
      _testing = true;
      _testResult = null;
      _testSuccess = false;
    });

    try {
      final response = await http
          .get(Uri.parse(testUrl))
          .timeout(const Duration(seconds: 5));

      // Qualquer resposta do servidor (mesmo 404) confirma conectividade.
      setState(() {
        _testSuccess = response.statusCode < 500;
        _testResult = _testSuccess
            ? 'Servidor acessível (HTTP ${response.statusCode})'
            : 'Servidor retornou erro ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        _testSuccess = false;
        _testResult = 'Não foi possível conectar: verifique o IP e a rede.';
      });
    } finally {
      setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }

    final ip = _ipController.text.trim();
    final institution = _institutionController.text.trim();
    await LocalStorageService.instance
        .saveItem(key: LocalStorageKey.serverIp, value: ip);
    await LocalStorageService.instance
        .saveItem(key: 'institution', value: institution);

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Servidor e estabelecimento configurados com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    Modular.to.navigate('/auth/');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            degradeArea(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        logoArea(),
                        const SizedBox(height: 24),
                        const Text(
                          'Configuração do Servidor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Informe o endereço IP do servidor na rede local.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white70, fontFamily: 'OpenSans'),
                        ),
                        const SizedBox(height: 24),
                        _buildIpField(),
                        const SizedBox(height: 16),
                        _buildInstitutionField(),
                        const SizedBox(height: 12),
                        _buildTestButton(),
                        if (_testResult != null) ...[
                          const SizedBox(height: 8),
                          _buildTestResult(),
                        ],
                        const SizedBox(height: 20),
                        _buildSaveButton(),
                        const SizedBox(height: 12),
                        if (Navigator.canPop(context))
                          TextButton(
                            onPressed: () => Modular.to.pop(),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'OpenSans'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildIpField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('IP do Servidor', style: kLabelStyle),
          const SizedBox(height: 10),
          Container(
            decoration: kBoxDecorationStyle,
            child: TextFormField(
              controller: _ipController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              validator: _validateIp,
              style:
                  const TextStyle(color: Colors.white, fontFamily: 'OpenSans'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.dns_outlined, color: Colors.white),
                hintText: 'Ex: 192.168.0.10',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'URL: http://${_ipController.text.isEmpty ? '<IP>' : _ipController.text}:$apiPort$apiPath',
              style: const TextStyle(
                  color: Colors.white54, fontSize: 11, fontFamily: 'OpenSans'),
            ),
          ),
        ],
      );

  Widget _buildInstitutionField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estabelecimento', style: kLabelStyle),
          const SizedBox(height: 10),
          Container(
            decoration: kBoxDecorationStyle,
            child: TextFormField(
              controller: _institutionController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              validator: _validateInstitution,
              style:
                  const TextStyle(color: Colors.white, fontFamily: 'OpenSans'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon:
                    Icon(Icons.business_outlined, color: Colors.white),
                hintText: 'Ex: Código da Minha Empresa',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      );

  Widget _buildTestButton() => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white54),
            minimumSize: const Size(100, 48),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _testing ? null : _testConnection,
          icon: _testing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.network_check),
          label: Text(_testing ? 'Testando...' : 'Testar conexão'),
        ),
      );

  Widget _buildTestResult() => Row(
        children: [
          Icon(
            _testSuccess ? Icons.check_circle : Icons.error,
            color: _testSuccess ? Colors.greenAccent : Colors.redAccent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _testResult ?? '',
              style: TextStyle(
                color: _testSuccess ? Colors.greenAccent : Colors.redAccent,
                fontFamily: 'OpenSans',
                fontSize: 13,
              ),
            ),
          ),
        ],
      );

  Widget _buildSaveButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 60),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: _save,
          child: const Text(
            'SALVAR',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.5,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
      );
}
