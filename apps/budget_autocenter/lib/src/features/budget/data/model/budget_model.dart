import 'package:budget_autocenter/src/features/budget/domain/entity/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.orderId,
    required super.number,
    required super.userId,
    required super.date,
    required super.customerId,
    required super.customerName,
    required super.paymentTypeId,
    required super.paymentTerms,
    required super.quantityProducts,
    required super.totalProducts,
    required super.freight,
    required super.discountPercent,
    required super.discountValue,
    required super.total,
    required super.contact,
    required super.validity,
    required super.deliveryTime,
    required super.salesmanId,
    required super.institutionId,
    required super.status,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        id: _toInt(json['id']),
        orderId: _toInt(json['orderId']),
        number: json['number']?.toString() ?? '',
        userId: _toInt(json['userId']),
        date: json['date']?.toString() ?? '',
        customerId: _toInt(json['customerId']),
        customerName: json['customerName']?.toString() ?? '',
        paymentTypeId: _toInt(json['paymentTypeId']),
        paymentTerms: json['paymentTerms']?.toString() ?? '',
        quantityProducts: _toDouble(json['quantityProducts']),
        totalProducts: _toDouble(json['totalProducts']),
        freight: _toDouble(json['freight']),
        discountPercent: _toDouble(json['discountPercent']),
        discountValue: _toDouble(json['discountValue']),
        total: _toDouble(json['total']),
        contact: json['contact']?.toString() ?? '',
        validity: json['validity']?.toString() ?? '',
        deliveryTime: json['deliveryTime']?.toString() ?? '',
        salesmanId: _toInt(json['salesmanId']),
        institutionId: _toInt(json['institutionId']),
        status: json['status']?.toString() ?? 'N',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'number': number,
        'userId': userId,
        'date': date,
        'customerId': customerId,
        'customerName': customerName,
        'paymentTypeId': paymentTypeId,
        'paymentTerms': paymentTerms,
        'quantityProducts': quantityProducts,
        'totalProducts': totalProducts,
        'freight': freight,
        'discountPercent': discountPercent,
        'discountValue': discountValue,
        'total': total,
        'contact': contact.isEmpty ? null : contact,
        'validity': validity.isEmpty ? null : validity,
        'deliveryTime': deliveryTime.isEmpty ? null : deliveryTime,
        'salesmanId': salesmanId,
        'institutionId': institutionId,
        'status': status,
      };

  static BudgetModel empty() {
    final e = BudgetEntity.empty();
    return BudgetModel(
      id: e.id, orderId: e.orderId, number: e.number, userId: e.userId,
      date: e.date, customerId: e.customerId, customerName: e.customerName,
      paymentTypeId: e.paymentTypeId, paymentTerms: e.paymentTerms,
      quantityProducts: e.quantityProducts, totalProducts: e.totalProducts,
      freight: e.freight, discountPercent: e.discountPercent,
      discountValue: e.discountValue, total: e.total, contact: e.contact,
      validity: e.validity, deliveryTime: e.deliveryTime,
      salesmanId: e.salesmanId, institutionId: e.institutionId, status: e.status,
    );
  }

  static BudgetModel fromEntity(BudgetEntity e) => BudgetModel(
        id: e.id, orderId: e.orderId, number: e.number, userId: e.userId,
        date: e.date, customerId: e.customerId, customerName: e.customerName,
        paymentTypeId: e.paymentTypeId, paymentTerms: e.paymentTerms,
        quantityProducts: e.quantityProducts, totalProducts: e.totalProducts,
        freight: e.freight, discountPercent: e.discountPercent,
        discountValue: e.discountValue, total: e.total, contact: e.contact,
        validity: e.validity, deliveryTime: e.deliveryTime,
        salesmanId: e.salesmanId, institutionId: e.institutionId, status: e.status,
      );
}
