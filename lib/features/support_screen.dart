import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prostuti/core/services/localization_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config/viewmodel/app_config_viewmodel.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({Key? key}) : super(key: key);

  // Helper methods for launching URLs
  Future<void> _launchCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      // Handle error
      debugPrint('Could not launch $callUri');
    }
  }

  Future<void> _launchMessage(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      // Handle error
      debugPrint('Could not launch $smsUri');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(appConfigNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6EEFA),
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.l10n!.helpAndSupport, // "হেল্প & সাপোর্ট"
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: const Color(0xFFE6EEFA),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Customer support illustration
                      Image.asset(
                        'assets/icons/support.png',
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),

                      // Title text
                      Text(
                        context.l10n!.contactUsForAnyQuestions,
                        // "যে কোনো প্রয়োজনে এখনি যোগাযোগ করুন"
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Description text
                      Text(
                        context.l10n!.supportDescription,
                        // "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever"
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Call and message buttons, driven entirely by the
                      // support number the backend serves. While the config is
                      // in flight, and whenever no number is configured, no
                      // contact button is offered at all — better than a button
                      // that dials nothing.
                      configAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (config) {
                          if (!config.hasSupportNumber) {
                            return const SizedBox.shrink();
                          }
                          final number = config.dialableSupportNumber;

                          return Column(
                            children: [
                              // Call button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () => _launchCall(number),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4169E8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    context.l10n!.helplineCall,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Message button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: () => _launchMessage(number),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.blue.shade100),
                                    backgroundColor: const Color(0xFFE6EEFA),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    context.l10n!.messageToSupport,
                                    style: const TextStyle(
                                      color: Color(0xFF4169E8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
