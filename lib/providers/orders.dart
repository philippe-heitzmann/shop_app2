import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    print('orders authToken $authToken');
    final url = Uri.https('shop-app-24bba-default-rtdb.firebaseio.com',
        '/orders/$userId.json', {'auth': '$authToken'});
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    // print('orders extracted: $extractedData');
    // print(extractedData.runtimeType);
    print('orders extractedData $extractedData');
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      // print('orderId : $orderId');
      // print('orderData : $orderData');
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          datetime: DateTime.parse(orderData['datetime']),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    print('orders $_orders');
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https('shop-app-24bba-default-rtdb.firebaseio.com',
        '/orders/$userId.json', {'auth': '$authToken'});
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'datetime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        datetime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
