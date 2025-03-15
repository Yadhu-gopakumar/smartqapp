import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/order_provider.dart';
import '../reusable/ordercard.dart';

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(orderProvider.notifier).fetchOrders(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return ref.read(orderProvider.notifier).fetchOrders(context);
        },
        child: orderState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : orderState.orders.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text('No orders yet!'),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: orderState.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderState.orders[index];
                      return OrderCard(
                        order: order,
                        onOrderCanceled: () {
                          ref.read(orderProvider.notifier).fetchOrders(context);
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
