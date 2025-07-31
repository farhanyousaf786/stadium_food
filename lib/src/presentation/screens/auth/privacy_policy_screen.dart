import 'package:flutter/material.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
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
          Translate.get('privacy_policy_title'),
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
              _buildSectionTitle(Translate.get('privacy_policy_main_title')),
              _buildSectionDate(Translate.get('privacy_policy_last_updated')),
              
              _buildSectionTitle(Translate.get('privacy_policy_section_1_title')),
              _buildParagraph(Translate.get('privacy_policy_section_1_text')),
              
              _buildSectionTitle(Translate.get('privacy_policy_section_2_title')),
              _buildParagraph(Translate.get('privacy_policy_section_2_intro')),
              _buildBulletPoint(Translate.get('privacy_policy_section_2_bullet_1')),
              _buildBulletPoint(Translate.get('privacy_policy_section_2_bullet_2')),
              _buildBulletPoint(Translate.get('privacy_policy_section_2_bullet_3')),
              _buildBulletPoint(Translate.get('privacy_policy_section_2_bullet_4')),
              _buildBulletPoint(Translate.get('privacy_policy_section_2_bullet_5')),
              
              _buildSectionTitle(Translate.get('privacy_policy_section_3_title')),
              _buildParagraph(Translate.get('privacy_policy_section_3_intro')),
              _buildBulletPoint(Translate.get('privacy_policy_section_3_bullet_1')),
              _buildBulletPoint(Translate.get('privacy_policy_section_3_bullet_2')),
              _buildBulletPoint(Translate.get('privacy_policy_section_3_bullet_3')),
              _buildBulletPoint(Translate.get('privacy_policy_section_3_bullet_4')),
              _buildBulletPoint(Translate.get('privacy_policy_section_3_bullet_5')),
              _buildBulletPoint(Translate.get('privacy_policy_section_3_bullet_6')),
              
              _buildSectionTitle(Translate.get('privacy_policy_section_4_title')),
              _buildParagraph(Translate.get('privacy_policy_section_4_intro')),
              _buildBulletPoint(Translate.get('privacy_policy_section_4_bullet_1')),
              _buildBulletPoint(Translate.get('privacy_policy_section_4_bullet_2')),
              _buildBulletPoint(Translate.get('privacy_policy_section_4_bullet_3')),
              _buildBulletPoint(Translate.get('privacy_policy_section_4_bullet_4')),
              
              _buildSectionTitle(Translate.get('privacy_policy_section_5_title')),
              _buildParagraph(Translate.get('privacy_policy_section_5_intro')),
              _buildBulletPoint(Translate.get('privacy_policy_section_5_bullet_1')),
              _buildBulletPoint(Translate.get('privacy_policy_section_5_bullet_2')),
              _buildBulletPoint(Translate.get('privacy_policy_section_5_bullet_3')),
              _buildBulletPoint(Translate.get('privacy_policy_section_5_bullet_4')),
              
              _buildSectionTitle(Translate.get('privacy_policy_section_6_title')),
              _buildParagraph(Translate.get('privacy_policy_section_6_text')),
              
              _buildSectionTitle(Translate.get('privacy_policy_section_7_title')),
              _buildParagraph(Translate.get('privacy_policy_section_7_text')),
              
              _buildSectionTitle(Translate.get('privacy_policy_section_8_title')),
              _buildParagraph(Translate.get('privacy_policy_section_8_text')),
              
              _buildSectionTitle(Translate.get('privacy_policy_section_9_title')),
              _buildParagraph(Translate.get('privacy_policy_section_9_text')),
              _buildParagraph(Translate.get('privacy_policy_section_9_email')),
              
              const SizedBox(height: 30),
              PrimaryButton(
                text: Translate.get('privacy_policy_understand'),
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
