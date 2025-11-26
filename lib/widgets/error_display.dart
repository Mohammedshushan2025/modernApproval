import 'package:flutter/material.dart';
import '../app_localizations.dart';

class ErrorDisplay extends StatelessWidget {
  final String errorMessageKey;
  final VoidCallback onRetry;

  const ErrorDisplay({
    super.key,
    required this.errorMessageKey,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorMessageKey == 'noInternet'
                  ? Icons.wifi_off_rounded
                  : Icons.error_outline_rounded,
              color: Colors.red.shade400,
              size: 70,
            ),
            const SizedBox(height: 20),
            Text(
              l.translate(errorMessageKey),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l.translate('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1F36),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
