import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/viewmodel/app_config_viewmodel.dart';

class TermsConditionsScreen extends ConsumerWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigNotifierProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E3F98),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E3F98), Color(0xFF1A2352)],
          ),
        ),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9EFFF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        size: 40,
                        color: Color(0xFF2E3F98),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3F98),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Last Updated: May 2025",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildHeader("Welcome to Prostuti!"),
                  const SizedBox(height: 10),
                  const Text(
                    "Prostuti is an educational platform that helps students prepare, practice, and solve doubts through a collaborative learning environment. Prostuti Services are available via www.prostuti.app, the Prostuti mobile app, and any official tools or integrations provided by Prostuti.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildHeader("Prohibited Content and Activities"),
                  const SizedBox(height: 10),
                  const Text(
                    "You are solely responsible for your conduct on the Prostuti platform. You agree not to:",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBulletPoint("Violate any laws or regulations."),
                  _buildBulletPoint("Harass or abuse other users."),
                  _buildBulletPoint("Post illegal or inappropriate content."),
                  _buildBulletPoint(
                      "Attempt unauthorized access to Prostuti's servers or networks."),
                  const SizedBox(height: 15),
                  const Text(
                    "Prohibited Content includes, but is not limited to:",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBulletPoint(
                      "Content promoting racism, hatred, or violence."),
                  _buildBulletPoint("Harassing or exploiting others."),
                  _buildBulletPoint(
                      "Posting sexually suggestive or violent material."),
                  _buildBulletPoint("Soliciting personal info from minors."),
                  _buildBulletPoint(
                      "Posting false or misleading information or engaging in illegal activities."),
                  _buildBulletPoint(
                      "Sharing unauthorized copyrighted content or promoting spam."),
                  const SizedBox(height: 15),
                  const Text(
                    "Prohibited Activities include:",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBulletPoint("Engaging in criminal activity or fraud."),
                  _buildBulletPoint("Circumventing security measures."),
                  _buildBulletPoint(
                      "Impersonating others or using someone else's account."),
                  _buildBulletPoint(
                      "Using harmful software like viruses or bots."),
                  _buildBulletPoint(
                      "Conducting unauthorized commercial activities."),
                  _buildBulletPoint(
                      "Violating any applicable laws or regulations."),
                  const SizedBox(height: 10),
                  const Text(
                    "Prostuti platform content responsibility lies with you, including prohibited content.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),
                  _buildHeader("Liability & Warranty Disclaimer"),
                  const SizedBox(height: 10),
                  const Text(
                    "Prostuti is not liable for any direct, indirect, incidental, or consequential damages arising from the use of the platform. The platform and its content are provided \"as is,\" without any warranties, express or implied. We do not guarantee that the platform will be error-free, uninterrupted, or that the content will be accurate or complete. You use the platform at your own risk.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),
                  _buildHeader("Subscription Policy"),
                  const SizedBox(height: 10),
                  const Text(
                    "Subscription Plans: You can purchase four types of subscription plans on Prostuti:",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBulletPoint("1 month"),
                  _buildBulletPoint("3 months"),
                  _buildBulletPoint("6 months"),
                  _buildBulletPoint("12 months"),
                  const SizedBox(height: 15),
                  _buildSubSection("Auto-renewal:",
                      "Prostuti does not have an auto-renewal system. Your subscription will automatically expire at the end of the designated period."),
                  _buildSubSection("Price Changes:",
                      "We may change the subscription price from time to time. You will be notified in advance before the new price takes effect. If you do not agree with the new price, you can cancel the subscription before it takes effect."),
                  _buildSubSection("Refund Policy:",
                      "Once a subscription is purchased, there is no option for cancellation or refund, except as required by law."),
                  const SizedBox(height: 15),
                  const Text(
                    "Post-Subscription Benefits: After your subscription period ends, you will still have access to the following features:",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildBulletPoint("Test system"),
                  _buildBulletPoint("Unlimited doubt solving"),
                  _buildBulletPoint("Unlimited use of flashcards"),
                  _buildBulletPoint("Some pre-recorded courses"),
                  const SizedBox(height: 20),
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),
                  _buildHeader("Copyright and License"),
                  const SizedBox(height: 10),
                  const Text(
                    "All content on the Prostuti platform, including but not limited to text, graphics, logos, images, and software, is the property of Prostuti or its content suppliers and is protected by intellectual property laws. You may not use any content on the platform without express written permission from Prostuti.\n\nBusiness License: TRAD/DNCC/043699/2024",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),
                  _buildHeader("Termination"),
                  const SizedBox(height: 10),
                  const Text(
                    "Your access to the platform may be terminated by Prostuti at any time for any reason, including but not limited to breaking these terms and conditions.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),
                  _buildHeader("Governing Law"),
                  const SizedBox(height: 10),
                  const Text(
                    "This Agreement shall be governed by and interpreted in accordance with the laws of Bangladesh. You may use the Prostuti platform strictly for personal educational purposes, subject to the terms outlined in this Agreement. You must not use the platform for any illegal or unauthorized activities, and you agree to comply with all applicable laws and regulations.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 20),
                  _buildHeader("Contact Us"),
                  const SizedBox(height: 10),
                  const Text(
                    "For any inquiries or issues, please feel free to contact us:",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildContactRow(
                      Icons.email_outlined, "Email:", "support@prostuti.app"),
                  // Shown only when the backend has a support number on file;
                  // the number is not duplicated in the app.
                  if (config != null && config.hasSupportNumber)
                    _buildContactRow(Icons.phone_outlined, "Phone:",
                        config.supportMobileNumber),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E3F98),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "I Accept",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E3F98),
        height: 1.5,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF2E3F98),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: const Color(0xFF2E3F98),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2E3F98),
            ),
          ),
        ],
      ),
    );
  }
}
