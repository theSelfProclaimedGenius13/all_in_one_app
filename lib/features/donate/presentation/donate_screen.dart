import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String _razorpayUrl =
    dotenv.env['RAZOR_PAY_URL'] ?? 'https://your-fallback-url.com';
final String _buyMeACoffeeUrl =
    dotenv.env['BUY_ME_A_COFFEE_URL'] ?? 'https://your-fallback-url.com';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      // You can show a SnackBar error here if you want
      log('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Note: No AppBar, this screen is part of the ShellRoute
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Support This App',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'If you enjoy using this app, please consider supporting its development. Every contribution helps!',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(height: 40),

          // --- SECTION 1: INDIAN USERS ---
          Text(
            'Indian Users: Payment options below',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // We'll add Razorpay (UPI/Card) buttons here
          _buildDonateButton(
            text: 'Pay with UPI, Cards, etc. (Razorpay)',
            icon: Icons.credit_card,
            color: Colors.blue.shade700,
            onPressed: () {
              _launchUrl(_razorpayUrl);
            },
          ),

          const SizedBox(height: 40),

          // --- SECTION 2: OTHER USERS ---
          Text(
            'Other Users: Payment options below',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // We'll add the "Buy Me a Coffee" button here
          _buildDonateButton(
            text: 'Buy Me a Coffee',
            icon: Icons.coffee,
            color: Colors.amber.shade800,
            onPressed: () {
              _launchUrl(_buyMeACoffeeUrl);
            },
          ),
        ],
      ),
    );
  }

  // Helper widget for a consistent button style
  Widget _buildDonateButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
