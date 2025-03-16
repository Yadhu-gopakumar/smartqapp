import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';
import 'dart:convert';
import '../models/order.dart';

final orderProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) => OrderNotifier());

class OrderState {
  final List<Order> orders;
  final bool isLoading;

  OrderState({required this.orders, required this.isLoading});
}

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(OrderState(orders: [], isLoading: false));

  Future<void> fetchOrders(BuildContext context) async {
    state = OrderState(orders: [], isLoading: true);

    try {
      final String? token = await getToken();

      if (token == null) {
        state = OrderState(orders: [], isLoading: false);

        if (context.mounted) {
          _showError(context, "Not logged in. Please log in again.");
        }

        return;
      }

      final response = await http.get(
        Uri.parse('${baseUrl}user/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        final orders = jsonData
            .map((order) {
              try {
                return Order.fromJson(order);
              } catch (e) {
                return null;
              }
            })
            .whereType<Order>()
            .toList();

        state = OrderState(orders: orders, isLoading: false);
      } else {
        state = OrderState(orders: [], isLoading: false);
        if (context.mounted) {
          _showError(context, "Failed to load orders (${response.statusCode})");
        }
      }
    } catch (e) {
      state = OrderState(orders: [], isLoading: false);
      _showError(context, "Error fetching orders: $e");
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return; // Ensure context is valid before proceeding

    // Avoid multiple dialogs by checking if one is already open
    if (ModalRoute.of(context)?.isCurrent != true) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    });
  }
}
