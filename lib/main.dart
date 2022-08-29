import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// App code
import 'package:shop_app/providers/auth.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import 'screens/auth_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products('', '', []),
            update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts!.items,
            ),
          ),
          ChangeNotifierProxyProvider<Auth, Cart>(
            create: (_) => Cart('', {}),
            update: (ctx, auth, previousCarts) => Cart(
              auth.token,
              previousCarts!.items,
            ),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders('', []),
            update: (ctx, auth, previousOrders) => Orders(
              auth.token,
              previousOrders!.orders,
            ),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
              title: 'MyShop',
              theme: ThemeData(
                colorScheme: ThemeData().colorScheme.copyWith(
                      primary: Colors.deepOrange,
                      secondary: Colors.blue,
                      tertiary: Colors.white,
                    ),
                fontFamily: 'Lato',
                textTheme: ThemeData.light().textTheme.copyWith(
                      bodyLarge: const TextStyle(
                          color: Color.fromRGBO(20, 51, 51, 1),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lato'),
                      bodyMedium: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lato'),
                      bodySmall: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lato'),
                    ),
              ),
              home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
              routes: {
                ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => CartScreen(),
                OrdersScreen.routeName: (ctx) => OrdersScreen(),
                UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                EditProductScreen.routeName: (ctx) => EditProductScreen(),
              }),
        ));
  }
}
