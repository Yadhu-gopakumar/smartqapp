import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:smartq/constants/constants.dart';
import '../models/menu_item.dart';
import '../provider/bottom_bar_provider.dart';
import '../provider/cartprovider.dart';
import '../provider/order_provider.dart';
import '../services/booking_services.dart';

class CartPage extends ConsumerStatefulWidget {
  final List<MenuItem> menuItems;

  const CartPage({super.key, required this.menuItems});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  late Razorpay _razorpay;
  double totalAmount = 0.0;
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout(double amount) {
    var options = {
      'key': apiKey,
      'amount': (amount * 100).toInt(),
      'name': 'SmartQ Booking',
      'description': 'Food Order',
      'theme': {'color': '#3399cc'},
      'prefill': {'contact': '859066859295', 'email': 'flutter@developer.com'},
      'method': {
        'upi': true,
        'netbanking': true,
        'wallet': true,
      },
    };

    try {
      totalAmount = amount;
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    String paymentId = response.paymentId ?? "Unknown";
    await placeOrder(paymentId, totalAmount);
  }

  Future<void> placeOrder(String paymentId, double totalAmount) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final cartState = ref.read(cartProvider);
    final cartItems = cartState.keys.map((id) {
      final item = widget.menuItems
          .firstWhere((item) => item.id == id, orElse: () => MenuItem.empty());
      return {
        "itemId": item.id,
        "quantity": cartState[id],
        "price": item.price
      };
    }).toList();

    bool bookingSuccess =
        await _bookingService.addBooking(paymentId, cartItems, totalAmount);
    if (bookingSuccess) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Order placed successfully!")));

      ref.read(cartProvider.notifier).clearCart();
      navigator.pop(); // Go back

      ref.read(bottomBarIndexProvider.notifier).state = 1; // Move to Orders tab

      Future.delayed(Duration.zero, () {
        ref.read(orderProvider.notifier).fetchOrders(navigator.context);
      });

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          dismissDirection: DismissDirection.horizontal,
          padding: EdgeInsets.only(top: 20, bottom: 20),
          content: Center(
            child: Text(
              'Order Placed',
              style: TextStyle(color: Colors.lightGreenAccent),
            ),
          ),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text("Order failed! Please contact support.")));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed: ${response.message}")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("External Wallet: ${response.walletName}")));
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartItems = cartState.keys
        .map((id) {
          final item = widget.menuItems.firstWhere((item) => item.id == id,
              orElse: () => MenuItem.empty());
          return item;
        })
        .whereType<MenuItem>()
        .toList();

    final double totalAmount = cartItems.fold(0, (sum, item) {
      final num quantity = cartState[item.id] ?? 0;
      return sum + (double.tryParse(item.price) ?? 0.0) * quantity;
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final num quantity = cartState[item.id] ?? 0;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 6),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 6),
                                width: MediaQuery.of(context).size.width * 0.95,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    // Image Section
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.imageUrl,
                                        width: 100,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.fastfood,
                                                    size: 50,
                                                    color: Colors.grey),
                                      ),
                                    ),
                                    // Item Details
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '₹${item.price} x $quantity',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Add to Cart Button
                                    Column(
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.red[100],
                                              child: IconButton(
                                                icon: const Icon(Icons.remove,
                                                    color: Colors.black),
                                                onPressed: () => cartNotifier
                                                    .decreaseQuantity(item.id),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                              child: Text(
                                                quantity.toString(),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                            CircleAvatar(
                                              backgroundColor:
                                                  Colors.green[100],
                                              child: IconButton(
                                                icon: const Icon(Icons.add,
                                                    color: Colors.black),
                                                onPressed: () => cartNotifier
                                                    .increaseQuantity(item.id),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        ElevatedButton(
                                          onPressed: () => cartNotifier
                                              .removeFromCart(item.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.yellow[100],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 2),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 1),
                                            child: Icon(Icons.delete,
                                                color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Total: ₹${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => openCheckout(totalAmount),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[800],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child: const Text('Proceed to Payment',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
