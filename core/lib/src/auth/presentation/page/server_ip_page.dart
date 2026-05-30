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

/// Tela de configuração inicial com fluxo em acordeão de 3 etapas.
/// Cada etapa colapsa ao ser concluída; o usuário pode reabri-la tocando no header.
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

enum _StepState { pending, active, completed }

// Paleta
const _colorSuccess = Color(0xFF4CAF50);
const _colorContainerBg = Color(0xFF6CA8F1);
const _colorButtonEnabled = Color(0xFF1A3C6E);
const _colorButtonDisabled = Color(0x33FFFFFF);
const _animDuration = Duration(milliseconds: 280);

class _ServerIpPageState extends State<ServerIpPage> {
  final _form = GlobalKey<FormState>();
  final _ipController = TextEditingController();

  // Conexão
  bool _testing = false;
  String? _testResult;
  bool _testSuccess = false;

  // Estabelecimentos
  List<_Institution> _institutions = [];
  bool _loadingInstitutions = false;
  _Institution? _selectedInstitution;

  // Acordeão: qual etapa está expandida (1, 2 ou 3)
  int _expandedStep = 1;

  static final _ipRegex = RegExp(
    r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
  );

  // ─── Estados das etapas ───────────────────────────────────────────────────

  _StepState get _step1State =>
      _testSuccess ? _StepState.completed : _StepState.active;

  _StepState get _step2State {
    if (!_testSuccess) return _StepState.pending;
    if (_selectedInstitution != null) return _StepState.completed;
    return _StepState.active;
  }

  _StepState get _step3State =>
      _selectedInstitution != null ? _StepState.active : _StepState.pending;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedIp() async {
    final saved = await LocalStorageService.instance
        .get(key: LocalStorageKey.serverIp, defaultValue: '');
    if (saved != null && saved.toString().isNotEmpty) {
      setState(() => _ipController.text = saved.toString());
    }
  }

  // ─── Validação ────────────────────────────────────────────────────────────

  String? _validateIp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o endereço IP do servidor';
    }
    if (!_ipRegex.hasMatch(value.trim())) return 'IP inválido. Ex: 192.168.0.10';
    return null;
  }

  // ─── Ações das etapas ────────────────────────────────────────────────────

  void _onStep1HeaderTap() {
    if (_step1State == _StepState.completed) {
      setState(() {
        _expandedStep = 1;
        _testSuccess = false;
        _testResult = null;
        _institutions = [];
        _selectedInstitution = null;
      });
    }
  }

  void _onStep2HeaderTap() {
    if (_step2State != _StepState.pending) {
      setState(() {
        _expandedStep = 2;
        _selectedInstitution = null;
      });
    }
  }

  Future<void> _testConnection() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    final ip = _ipController.text.trim();
    setState(() {
      _testing = true;
      _testResult = null;
      _testSuccess = false;
      _institutions = [];
      _selectedInstitution = null;
    });

    try {
      final response = await http
          .get(Uri.parse('http://$ip:$apiPort${apiPath}health'))
          .timeout(const Duration(seconds: 5));

      final ok = response.statusCode == 200;
      setState(() {
        _testSuccess = ok;
        _testResult = ok
            ? 'Servidor conectado com sucesso'
            : 'Servidor retornou erro ${response.statusCode}';
      });

      if (ok) await _loadInstitutions(ip);
    } catch (_) {
      setState(() {
        _testSuccess = false;
        _testResult = 'Não foi possível conectar. Verifique o IP e a rede.';
      });
    } finally {
      setState(() => _testing = false);
    }
  }

  Future<void> _loadInstitutions(String ip) async {
    setState(() => _loadingInstitutions = true);
    try {
      final response = await http
          .get(Uri.parse('http://$ip:$apiPort${apiPath}institutions'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _institutions = data
              .map((e) => _Institution(
                    id: e['id'] as int,
                    fantasyName: e['fantasyName'] as String,
                  ))
              .toList();
          // Avança automaticamente para a etapa 2
          _expandedStep = 2;
        });
      } else {
        setState(() {
          _testResult =
              'Erro ao carregar estabelecimentos (${response.statusCode})';
          _testSuccess = false;
        });
      }
    } catch (_) {
      setState(() {
        _testResult = 'Erro ao carregar estabelecimentos. Tente novamente.';
        _testSuccess = false;
      });
    } finally {
      setState(() => _loadingInstitutions = false);
    }
  }

  void _selectInstitution(_Institution institution) {
    setState(() {
      _selectedInstitution = institution;
      // Avança automaticamente para a etapa 3
      _expandedStep = 3;
    });
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

  // ─── Build principal ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            degradeArea(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      logoArea(),
                      const SizedBox(height: 16),
                      _buildPageTitle(),
                      const SizedBox(height: 20),
                      // As etapas ocupam o espaço restante
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── Etapa 1 ──────────────────────────────────
                              _buildAccordionStep(
                                stepNumber: 1,
                                label: 'Configurar Servidor',
                                subtitle: _step1State == _StepState.completed
                                    ? '${_ipController.text} — Conectado'
                                    : 'Informe o IP do servidor na rede local',
                                state: _step1State,
                                onHeaderTap: _onStep1HeaderTap,
                                content: _buildStep1Content(),
                              ),
                              _buildConnector(
                                  active: _step1State == _StepState.completed),

                              // ── Etapa 2 ──────────────────────────────────
                              _buildAccordionStep(
                                stepNumber: 2,
                                label: 'Escolher Estabelecimento',
                                subtitle:
                                    _step2State == _StepState.completed
                                        ? _selectedInstitution!.fantasyName
                                        : _step2State == _StepState.active
                                            ? 'Selecione onde deseja trabalhar'
                                            : 'Disponível após conectar o servidor',
                                state: _step2State,
                                onHeaderTap: _onStep2HeaderTap,
                                content: _buildStep2Content(),
                              ),
                              _buildConnector(
                                  active:
                                      _step2State == _StepState.completed),

                              // ── Etapa 3 ──────────────────────────────────
                              _buildAccordionStep(
                                stepNumber: 3,
                                label: 'Acessar o Sistema',
                                subtitle: 'Confirme e entre no sistema',
                                state: _step3State,
                                onHeaderTap: null,
                                content: _buildStep3Content(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Cancelar (somente ao navegar de volta)
                      if (Navigator.canPop(context))
                        TextButton(
                          onPressed: () => Modular.to.pop(),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                                color: Colors.white60,
                                fontFamily: 'OpenSans'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildPageTitle() => Column(
        children: [
          const Text(
            'Configuração Inicial',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Siga as etapas para acessar o sistema',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withAlpha(179),
                fontFamily: 'OpenSans',
                fontSize: 12),
          ),
        ],
      );

  // ─── Acordeão ─────────────────────────────────────────────────────────────

  Widget _buildAccordionStep({
    required int stepNumber,
    required String label,
    required String subtitle,
    required _StepState state,
    required VoidCallback? onHeaderTap,
    required Widget content,
  }) {
    final isExpanded = _expandedStep == stepNumber;
    final canTap = onHeaderTap != null && state == _StepState.completed;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: state == _StepState.active
              ? Colors.white.withAlpha(100)
              : state == _StepState.completed
                  ? _colorSuccess.withAlpha(160)
                  : Colors.white.withAlpha(40),
          width: state == _StepState.active ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (sempre visível)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canTap ? onHeaderTap : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  _buildBadge(stepNumber, state),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.black, // solicitado pelo usuário
                            fontWeight: state == _StepState.active
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontFamily: 'OpenSans',
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: state == _StepState.pending
                                ? Colors.white38
                                : Colors.white70,
                            fontFamily: 'OpenSans',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron de edição
                  if (canTap)
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white54,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          // Conteúdo colapsável com animação
          AnimatedSize(
            duration: _animDuration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded && state != _StepState.pending
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: content,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(int number, _StepState state) {
    final isCompleted = state == _StepState.completed;
    final isActive = state == _StepState.active;

    return AnimatedContainer(
      duration: _animDuration,
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isCompleted
            ? _colorSuccess
            : isActive
                ? Colors.white
                : Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : Text(
                '$number',
                style: TextStyle(
                  color: isActive ? kPrimaryColor : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildConnector({required bool active}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 34),
        child: AnimatedContainer(
          duration: _animDuration,
          height: 14,
          width: 2,
          decoration: BoxDecoration(
            color: active ? Colors.white54 : Colors.white24,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      );

  // ─── Etapa 1: IP + Teste ──────────────────────────────────────────────────

  Widget _buildStep1Content() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildIpField(),
          const SizedBox(height: 10),
          _buildTestButton(),
          if (_testResult != null) ...[
            const SizedBox(height: 8),
            _buildTestResultBadge(),
          ],
        ],
      );

  Widget _buildIpField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('IP do Servidor', style: kLabelStyle),
          const SizedBox(height: 8),
          Container(
            decoration: kBoxDecorationStyle.copyWith(
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: _ipController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              validator: _validateIp,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                  color: Colors.white, fontFamily: 'OpenSans'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.dns_outlined, color: Colors.white),
                hintText: 'Ex: 192.168.0.10',
                hintStyle: TextStyle(
                    color: Colors.white60, fontFamily: 'OpenSans'),
              ),
            ),
          ),
          if (_ipController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'http://${_ipController.text}:$apiPort$apiPath',
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontFamily: 'OpenSans'),
              ),
            ),
        ],
      );

  Widget _buildTestButton() => OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
              color: _testSuccess ? _colorSuccess : Colors.white54),
          minimumSize: const Size(double.infinity, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: _testing ? null : _testConnection,
        icon: _testing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(_testSuccess ? Icons.wifi_tethering : Icons.network_check),
        label: Text(_testing ? 'Testando...' : 'Testar Conexão'),
      );

  Widget _buildTestResultBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (_testSuccess ? _colorSuccess : Colors.redAccent).withAlpha(30),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (_testSuccess ? _colorSuccess : Colors.redAccent).withAlpha(100),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _testSuccess ? Icons.check_circle : Icons.error_outline,
              color: _testSuccess ? _colorSuccess : Colors.redAccent,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _testResult ?? '',
                style: TextStyle(
                  color: _testSuccess ? _colorSuccess : Colors.redAccent,
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );

  // ─── Etapa 2: Lista de estabelecimentos ───────────────────────────────────

  Widget _buildStep2Content() {
    if (_loadingInstitutions) return _buildLoadingRow();
    if (_institutions.isEmpty) return const SizedBox.shrink();
    return _buildInstitutionsList();
  }

  Widget _buildLoadingRow() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white70),
            ),
            const SizedBox(width: 12),
            Text(
              'Carregando estabelecimentos...',
              style: TextStyle(
                  color: Colors.white.withAlpha(179),
                  fontFamily: 'OpenSans',
                  fontSize: 13),
            ),
          ],
        ),
      );

  Widget _buildInstitutionsList() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _institutions.map(_buildInstitutionTile).toList(),
      );

  Widget _buildInstitutionTile(_Institution institution) {
    final selected = _selectedInstitution?.id == institution.id;
    final isLast = _institutions.last.id == institution.id;

    return Semantics(
      label: institution.fantasyName,
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: _animDuration,
        margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withAlpha(40)
              : _colorContainerBg.withAlpha(80),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                selected ? Colors.white : Colors.white.withAlpha(50),
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _selectInstitution(institution),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: _animDuration,
                    child: Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      key: ValueKey(selected),
                      color: selected ? Colors.white : Colors.white38,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      institution.fantasyName,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontFamily: 'OpenSans',
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Etapa 3: Resumo + Botão ──────────────────────────────────────────────

  Widget _buildStep3Content() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildReadySummary(),
          const SizedBox(height: 12),
          _buildProceedButton(),
        ],
      );

  Widget _buildReadySummary() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(40)),
        ),
        child: Column(
          children: [
            _buildSummaryRow(
                icon: Icons.check_circle,
                color: _colorSuccess,
                label: 'Servidor conectado'),
            const SizedBox(height: 8),
            _buildSummaryRow(
                icon: Icons.check_circle,
                color: _colorSuccess,
                label: _selectedInstitution?.fantasyName ?? ''),
            const SizedBox(height: 8),
            _buildSummaryRow(
                icon: Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                label: 'Pronto para acessar o sistema'),
          ],
        ),
      );

  Widget _buildSummaryRow({
    required IconData icon,
    required Color color,
    required String label,
  }) =>
      Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontFamily: 'OpenSans', fontSize: 13),
            ),
          ),
        ],
      );

  Widget _buildProceedButton() {
    final enabled = _selectedInstitution != null;
    return AnimatedContainer(
      duration: _animDuration,
      height: 56,
      decoration: BoxDecoration(
        color: enabled ? _colorButtonEnabled : _colorButtonDisabled,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? _proceed : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login_rounded,
                  color: enabled ? Colors.white : Colors.white38, size: 22),
              const SizedBox(width: 10),
              Text(
                'ACESSAR SISTEMA',
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.white38,
                  letterSpacing: 1.5,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
