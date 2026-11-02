// Dados demonstrativos. Este módulo não importa repositórios, HTTP ou Firebird.
enum InspectionState {
  normal('N', 'Normal'),
  scratched('R', 'Riscado'),
  broken('Q', 'Quebrado'),
  dented('A', 'Amassado');

  const InspectionState(this.code, this.label);
  final String code;
  final String label;
}

class VehicleInspection {
  final List<InspectionState?> regions = List.filled(22, null);
  int get completed => regions.whereType<InspectionState>().length;
  int get damages =>
      regions.where((s) => s != null && s != InspectionState.normal).length;
  void confirmRemainingNormal() {
    for (var i = 0; i < regions.length; i++) {
      regions[i] ??= InspectionState.normal;
    }
  }

  String? serialize() =>
      completed == 22 ? regions.map((s) => s!.code).join() : null;
  void load(String value) {
    if (!RegExp(r'^[NRQA]{22}$').hasMatch(value)) {
      throw const FormatException('Checklist deve conter 22 códigos N/R/Q/A.');
    }
    // Validação ocorre antes de alterar o estado existente.
    for (var i = 0; i < 22; i++) {
      regions[i] = InspectionState.values.firstWhere((s) => s.code == value[i]);
    }
  }
}

class AutoCenterBudgetItem {
  AutoCenterBudgetItem(
    this.name,
    this.cents, {
    this.service = false,
    this.quantity = 1,
  });
  final String name;
  final bool service;
  int cents;
  int quantity;
  int get total => cents * quantity;
  AutoCenterBudgetItem copy() =>
      AutoCenterBudgetItem(name, cents, service: service, quantity: quantity);
}

class AutoCenterBudget {
  AutoCenterBudget({
    this.customer = '',
    this.vehicle = '',
    this.plate = '',
    DateTime? date,
  }) : date = date ?? DateTime.now();
  final DateTime date;
  String customer, vehicle, plate;
  String contact = '', salesman = 'Atendente demonstração';
  String payment = 'A combinar', term = 'À vista', notes = '';
  String year = '', color = '', chassis = '', fleet = '', km = '';
  String vehicleNotes = '', departure = '';
  int freight = 0, discount = 0;
  final List<AutoCenterBudgetItem> items = [];
  final VehicleInspection inspection = VehicleInspection();
  final Map<String, String> tyres = {};
  final Set<String> accessories = {};
  String fuel = '', valves = '', inspectionNotes = '', prism = '';
  String entryDate = '', entryTime = '';
  bool accessoriesConfirmed = false;
  String? localNumber;
  AutoCenterBudget copy() {
    final result =
        AutoCenterBudget(
            customer: customer,
            vehicle: vehicle,
            plate: plate,
            date: date,
          )
          ..contact = contact
          ..salesman = salesman
          ..payment = payment
          ..term = term
          ..notes = notes
          ..year = year
          ..color = color
          ..chassis = chassis
          ..fleet = fleet
          ..km = km
          ..vehicleNotes = vehicleNotes
          ..departure = departure
          ..freight = freight
          ..discount = discount
          ..fuel = fuel
          ..valves = valves
          ..inspectionNotes = inspectionNotes
          ..prism = prism
          ..entryDate = entryDate
          ..entryTime = entryTime
          ..accessoriesConfirmed = accessoriesConfirmed
          ..localNumber = localNumber;
    result.items.addAll(items.map((i) => i.copy()));
    result.inspection.regions.setAll(0, inspection.regions);
    result.tyres.addAll(tyres);
    result.accessories.addAll(accessories);
    return result;
  }

  int subtotal(bool service) => items
      .where((i) => i.service == service)
      .fold(0, (sum, i) => sum + i.total);
  int get total => subtotal(false) + subtotal(true) + freight - discount;
  List<String> get pending => [
    if (customer.trim().isEmpty) 'Informar o cliente',
    if (items.isEmpty) 'Adicionar ao menos uma peça ou serviço',
    if (!RegExp(r'^[A-Z0-9]{7}$').hasMatch(plate.trim().toUpperCase()))
      'Informar a placa com 7 letras/números, sem hífen',
    if (vehicle.trim().isEmpty) 'Informar marca e modelo',
    if (total < 0) 'Desconto não pode superar o valor do orçamento',
    if (freight < 0 || discount < 0)
      'Frete e desconto devem ser positivos ou zero',
    if (inspection.completed < 22)
      'Conferir as ${22 - inspection.completed} regiões pendentes',
    if (tyres.length != 3) 'Conferir pneus dianteiros, traseiros e estepe',
    if (fuel.isEmpty) 'Selecionar o combustível',
    if (valves.isEmpty) 'Selecionar as válvulas',
    if (!accessoriesConfirmed) 'Confirmar a conferência dos acessórios',
  ];
}

int parseMoney(String value) {
  final cleaned = value.trim().replaceAll('R\$', '').replaceAll(' ', '');
  final normalized = cleaned.contains(',')
      ? cleaned.replaceAll('.', '').replaceAll(',', '.')
      : cleaned;
  return ((double.tryParse(normalized) ?? 0) * 100).round();
}

String money(int cents) {
  final amount = (cents.abs() / 100).toStringAsFixed(2).split('.');
  final whole = amount[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '${cents < 0 ? '-' : ''}R\$ $whole,${amount[1]}';
}

const accessoryNames = <String, String>{
  'HOIST': 'Macaco',
  'MANUAL': 'Manual',
  'EXTINGUISHER': 'Extintor',
  'RADIO': 'Rádio',
  'ABS': 'ABS',
  'HYDRAULIC_STEERING': 'Direção hidráulica',
  'HUB_CAPS': 'Calotas',
  'HOT_AIR': 'Ar quente',
  'TRIANGLE': 'Triângulo',
  'WRENCH': 'Chave de roda',
  'AERIAL': 'Antena',
  'CIGARETTE_LIGHTER': 'Acendedor',
  'CONDITIONED_AIR': 'Ar-condicionado',
  'OTHER': 'Outros',
  'DOCTS': 'Documentos',
  'CARPET': 'Tapetes',
};
