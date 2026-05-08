import 'package:budget_autocenter/src/features/budget/presentation/bloc/payment_type_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// Shows a searchable list of payment types and returns the selected one.
class PaymentTypeDialog extends StatefulWidget {
  const PaymentTypeDialog({super.key, this.bloc});

  final PaymentTypeBloc? bloc;

  @override
  State<PaymentTypeDialog> createState() => _PaymentTypeDialogState();
}

class _PaymentTypeDialogState extends State<PaymentTypeDialog> {
  late PaymentTypeBloc _bloc;
  final _filterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? Modular.get<PaymentTypeBloc>();
    _bloc.add(const PaymentTypeLoad());
  }

  @override
  void dispose() {
    _filterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Forma de Pagamento')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _filterCtrl,
                decoration: const InputDecoration(
                  labelText: 'Filtrar',
                  isDense: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) =>
                    _bloc.add(PaymentTypeLoad(description: v.trim().isEmpty ? null : v.trim())),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<PaymentTypeBloc, PaymentTypeState>(
                builder: (context, state) {
                  if (state is PaymentTypeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is PaymentTypeError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is PaymentTypeLoaded) {
                    if (state.paymentTypes.isEmpty) {
                      return const Center(
                          child: Text('Nenhuma forma de pagamento.'));
                    }
                    return ListView.separated(
                      itemCount: state.paymentTypes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final p = state.paymentTypes[i];
                        return ListTile(
                          title: Text(p.description),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).pop(p),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
