import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartq/constants/constants.dart';

import '../auth/auth_provider.dart';
import '../reusable/acountcard.dart';
import '../reusable/launchemail.dart';


class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  // Method to retrieve the stored email from SharedPreferences
  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');
    return email ?? 'No email found'; // Default value if email is not found
  }

  void _sendfeedback() {
    String email = receverEmail;  // Use your default email here
    String query = 'subject=feedback&body=Write your feedback here';
    EmailHelper emailinst = EmailHelper(email: email, query: query);
    emailinst.launchEmail();
  }

  // sendsupport method
  void _sendsupport() {
    String email = receverEmail
    ;  // Use your default email here
    String query = 'subject=support&body=what support needed';
    EmailHelper emailinst = EmailHelper(email: email, query: query);
    emailinst.launchEmail();
  }

  // logout method
  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(authProvider.notifier).logout(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accounts',
          style: TextStyle(
            letterSpacing: 2,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<String?>(
        future: getUserEmail(),  // Fetch the email when building the page
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If email is found, display it
          final userEmail = snapshot.data ?? 'No email available';

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Email: $userEmail',  // Display the retrieved email
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              GestureDetector(
                onTap: _sendfeedback,
                child: const AccountCards(
                  aicon: Icons.feedback_outlined,
                  atext: 'Feedback',
                ),
              ),
              GestureDetector(
                onTap: _sendsupport,
                child: const AccountCards(
                  aicon: Icons.contact_support_outlined,
                  atext: 'Support',
                ),
              ),
              GestureDetector(
                onTap: () => _logout(context, ref),
                child: const AccountCards(
                  aicon: Icons.logout_rounded,
                  atext: 'Logout',
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'All rights reserved',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                    Text(
                      'version 1.0',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
