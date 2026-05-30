import 'dart:convert';

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
/// e redireciona para a tela de login após o usuário selecionar o estabelecimento.
class ServerIpPage extends StatefulWidget {
  const ServerIpPage({super.key});

  @override
  State<ServerIpPage> createState() => _ServerIpPageState();
}

class _Institution {
  const _Institution({required this.id, required this.fantasyName});
  final int id;
  final String fantasyName;
}

class _ServerIpPageState extends State<ServerIpPage> {
  final _form = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  bool _testing = false;
  String? _testResult;
  bool _testSuccess = false;

  List<_Institution> _institutions = [];
  bool _loadingInstitutions = false;
  _Institution? _selectedInstitution;

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
  }

  @override
  void dispose() {
    _ipController.dispose();
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

  Future<void> _testConnection() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    final ip = _ipController.text.trim();
    final healthUrl = 'http://$ip:$apiPort${apiPath}health';

    setState(() {
      _testing = true;
      _testResult = null;
      _testSuccess = false;
      _institutions = [];
      _selectedInstitution = null;
    });

    try {
      final response = await http
          .get(Uri.parse(healthUrl))
          .timeout(const Duration(seconds: 5));

      final success = response.statusCode == 200;
      setState(() {
        _testSuccess = success;
        _testResult = success
            ? 'Servidor funcionando corretamente'
            : 'Servidor retornou erro ${response.statusCode}';
      });

      if (success) {
        await _loadInstitutions(ip);
      }
    } catch (e) {
      setState(() {
        _testSuccess = false;
        _testResult = 'Não foi possível conectar: verifique o IP e a rede.';
      });
    } finally {
      setState(() => _testing = false);
    }
  }

  Future<void> _loadInstitutions(String ip) async {
    setState(() => _loadingInstitutions = true);
    try {
      final url = 'http://$ip:$apiPort${apiPath}institutions';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _institutions = data
              .map((e) => _Institution(
                    id: e['id'] as int,
                    fantasyName: e['fantasyName'] as String,
                  ))
              .toList();
        });
      } else {
        setState(() {
          _testResult = 'Erro ao carregar estabelecimentos: ${response.statusCode}';
          _testSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _testResult = 'Erro ao carregar estabelecimentos. Tente novamente.';
        _testSuccess = false;
      });
    } finally {
      setState(() => _loadingInstitutions = false);
    }
  }

  Future<void> _proceed() async {
    if (_selectedInstitution == null) return;

    final ip = _ipController.text.trim();
    await LocalStorageService.instance
        .saveItem(key: LocalStorageKey.serverIp, value: ip);
    await LocalStorageService.instance.saveItem(
        key: LocalStorageKey.institution,
        value: _selectedInstitution!.fantasyName);
    await LocalStorageService.instance.saveItem(
        key: LocalStorageKey.tbInstitutionId,
        value: _selectedInstitution!.id.toString());

    if (!mounted) return;
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
                        const SizedBox(height: 12),
                        _buildTestButton(),
                        if (_testResult != null) ...[
                          const SizedBox(height: 8),
                          _buildTestResult(),
                        ],
                        if (_loadingInstitutions) ...[
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 8),
                          const Text(
                            'Carregando estabelecimentos...',
                            style: TextStyle(
                                color: Colors.white70, fontFamily: 'OpenSans'),
                          ),
                        ],
                        if (_institutions.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildInstitutionsList(),
                          const SizedBox(height: 16),
                          _buildProceedButton(),
                        ],
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

  Widget _buildInstitutionsList() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selecione o Estabelecimento', style: kLabelStyle),
          const SizedBox(height: 10),
          Container(
            decoration: kBoxDecorationStyle,
            child: Column(
              children: _institutions.map((institution) {
                final selected = _selectedInstitution?.id == institution.id;
                return InkWell(
                  onTap: () =>
                      setState(() => _selectedInstitution = institution),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withAlpha(30)
                          : Colors.transparent,
                      border: _institutions.last.id != institution.id
                          ? Border(
                              bottom: BorderSide(
                                  color: Colors.white.withAlpha(30)))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selected ? Colors.white : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            institution.fantasyName,
                            style: TextStyle(
                              color:
                                  selected ? Colors.white : Colors.white70,
                              fontFamily: 'OpenSans',
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );

  Widget _buildProceedButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 60),
            backgroundColor:
                _selectedInstitution != null ? Colors.black : Colors.black38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: _selectedInstitution != null ? _proceed : null,
          icon: const Icon(Icons.login, color: Colors.white),
          label: const Text(
            'ACESSAR SISTEMA',
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
