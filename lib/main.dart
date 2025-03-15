import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/loginpage.dart';
import 'pages/homepage.dart';
import 'pages/acountpage.dart';
import 'pages/orderpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'provider/bottom_bar_provider.dart';
// import 'provider/car';
// import 'package:permission_handler/permission_handler.dart';

// Future<void> requestPermissions() async {
//   PermissionStatus status = await Permission.manageExternalStorage.request();

//   if (status.isGranted) {
//     print("Permission Granted!");
//   } else {
//     print("Permission Denied!");
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final prefs = await SharedPreferences.getInstance();
//   bool isAuthenticated = prefs.getString('token') != null;

//   runApp(ProviderScope(child: MyApp(isAuthenticated: isAuthenticated)));
// }
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AppInitializer()));
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  Future<bool> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        } else {
          return MyApp(isAuthenticated: snapshot.data ?? false);
        }
      },
    );
  }
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;
  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          titleTextStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1),
          color: Colors.yellow[800],
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        ),
       
      ),
      debugShowCheckedModeBanner: false,
      home: isAuthenticated ? const BottomBar() : LoginPage(),
    );
  }
}

class BottomBar extends ConsumerWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomBarIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const [HomePage(), OrderPage(), AccountPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) =>
            ref.read(bottomBarIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: Colors.yellow[900],
        unselectedItemColor: Colors.grey[800],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
