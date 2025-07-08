import 'package:flutter/material.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/utils/custom_text_style.dart';
import 'package:stadium_food/src/presentation/widgets/buttons/primary_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: CustomTextStyle.size18Weight600Text(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Stadium Food App Privacy Policy'),
              _buildSectionDate('Last Updated: July 8, 2025'),
              
              _buildSectionTitle('1. Introduction'),
              _buildParagraph(
                'Welcome to the Stadium Food App. We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.'
              ),
              
              _buildSectionTitle('2. Information We Collect'),
              _buildParagraph(
                'We collect information that you provide directly to us, including:'
              ),
              _buildBulletPoint('Personal Information: Name, email address, phone number, and profile image'),
              _buildBulletPoint('Account Information: Login credentials and user preferences'),
              _buildBulletPoint('Transaction Information: Order history, payment details, and delivery addresses'),
              _buildBulletPoint('Location Information: Stadium selection and device location for delivery services'),
              _buildBulletPoint('Device Information: Device type, operating system, and unique device identifiers'),
              
              _buildSectionTitle('3. How We Use Your Information'),
              _buildParagraph(
                'We use the information we collect to:'
              ),
              _buildBulletPoint('Provide, maintain, and improve our services'),
              _buildBulletPoint('Process transactions and send related information'),
              _buildBulletPoint('Send you technical notices, updates, and support messages'),
              _buildBulletPoint('Respond to your comments, questions, and customer service requests'),
              _buildBulletPoint('Personalize your experience and provide content recommendations'),
              _buildBulletPoint('Monitor and analyze trends, usage, and activities in connection with our services'),
              
              _buildSectionTitle('4. Sharing Your Information'),
              _buildParagraph(
                'We may share your information with:'
              ),
              _buildBulletPoint('Stadium vendors and food providers to fulfill your orders'),
              _buildBulletPoint('Service providers who perform services on our behalf'),
              _buildBulletPoint('Professional advisors, such as lawyers and accountants'),
              _buildBulletPoint('Law enforcement or other governmental authorities when required by law'),
              
              _buildSectionTitle('5. Your Choices'),
              _buildParagraph(
                'You can control your information through:'
              ),
              _buildBulletPoint('Account Settings: Update or delete your profile information'),
              _buildBulletPoint('Marketing Communications: Opt-out of promotional emails'),
              _buildBulletPoint('Location Information: Control location permissions through your device settings'),
              _buildBulletPoint('Account Deactivation: Request to deactivate your account by contacting support'),
              
              _buildSectionTitle('6. Data Security'),
              _buildParagraph(
                'We implement appropriate technical and organizational measures to protect the security of your personal information. However, no electronic transmission or storage technology is completely secure, so we cannot guarantee the absolute security of your data.'
              ),
              
              _buildSectionTitle('7. Children\'s Privacy'),
              _buildParagraph(
                'Our services are not intended for children under 13 years of age, and we do not knowingly collect personal information from children under 13.'
              ),
              
              _buildSectionTitle('8. Changes to This Privacy Policy'),
              _buildParagraph(
                'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.'
              ),
              
              _buildSectionTitle('9. Contact Us'),
              _buildParagraph(
                'If you have any questions about this Privacy Policy, please contact us at:'
              ),
              _buildParagraph(
                'Email: switch2future@gmail.com'
              ),
              
              const SizedBox(height: 30),
              PrimaryButton(
                text: 'I Understand',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: CustomTextStyle.size18Weight600Text(),
      ),
    );
  }

  Widget _buildSectionDate(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        date,
        style: CustomTextStyle.size14Weight400Text(Colors.grey),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: CustomTextStyle.size14Weight400Text(),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: CustomTextStyle.size14Weight600Text()),
          Expanded(
            child: Text(
              text,
              style: CustomTextStyle.size14Weight400Text(),
            ),
          ),
        ],
      ),
    );
  }
}
