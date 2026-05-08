import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  const BudgetEntity({
    required this.id,
    required this.orderId,
    required this.number,
    required this.userId,
    required this.date,
    required this.customerId,
    required this.customerName,
    required this.paymentTypeId,
    required this.paymentTerms,
    required this.quantityProducts,
    required this.totalProducts,
    required this.freight,
    required this.discountPercent,
    required this.discountValue,
    required this.total,
    required this.contact,
    required this.validity,
    required this.deliveryTime,
    required this.salesmanId,
    required this.institutionId,
    required this.status,
  });

  final int id;
  final int orderId;
  final String number;
  final int userId;
  final String date;
  final int customerId;
  final String customerName;
  final int paymentTypeId;
  final String paymentTerms;
  final double quantityProducts;
  final double totalProducts;
  final double freight;
  final double discountPercent;
  final double discountValue;
  final double total;
  final String contact;
  final String validity;
  final String deliveryTime;
  final int salesmanId;
  final int institutionId;
  final String status;

  static BudgetEntity empty() => const BudgetEntity(
        id: 0,
        orderId: 0,
        number: '',
        userId: 0,
        date: '',
        customerId: 0,
        customerName: '',
        paymentTypeId: 0,
        paymentTerms: '',
        quantityProducts: 0,
        totalProducts: 0,
        freight: 0,
        discountPercent: 0,
        discountValue: 0,
        total: 0,
        contact: '',
        validity: '',
        deliveryTime: '',
        salesmanId: 0,
        institutionId: 0,
        status: 'N',
      );

  BudgetEntity copyWith({
    int? id,
    int? orderId,
    String? number,
    int? userId,
    String? date,
    int? customerId,
    String? customerName,
    int? paymentTypeId,
    String? paymentTerms,
    double? quantityProducts,
    double? totalProducts,
    double? freight,
    double? discountPercent,
    double? discountValue,
    double? total,
    String? contact,
    String? validity,
    String? deliveryTime,
    int? salesmanId,
    int? institutionId,
    String? status,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      number: number ?? this.number,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      quantityProducts: quantityProducts ?? this.quantityProducts,
      totalProducts: totalProducts ?? this.totalProducts,
      freight: freight ?? this.freight,
      discountPercent: discountPercent ?? this.discountPercent,
      discountValue: discountValue ?? this.discountValue,
      total: total ?? this.total,
      contact: contact ?? this.contact,
      validity: validity ?? this.validity,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      salesmanId: salesmanId ?? this.salesmanId,
      institutionId: institutionId ?? this.institutionId,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id, orderId, number, userId, date, customerId, customerName,
        paymentTypeId, paymentTerms, quantityProducts, totalProducts,
        freight, discountPercent, discountValue, total, contact,
        validity, deliveryTime, salesmanId, institutionId, status,
      ];
}
