import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/services/localization_service.dart';
import '../../../core/services/nav.dart';
import '../../../core/services/size_config.dart';

class TermsCondition extends StatelessWidget {
  const TermsCondition({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      (
        title: context.l10n!.benefitCoursesTitle,
        description: context.l10n!.benefitCoursesDesc,
      ),
      (
        title: context.l10n!.benefitMockTestsTitle,
        description: context.l10n!.benefitMockTestsDesc,
      ),
      (
        title: context.l10n!.benefitFlashcardsTitle,
        description: context.l10n!.benefitFlashcardsDesc,
      ),
      (
        title: context.l10n!.benefitTutorChatTitle,
        description: context.l10n!.benefitTutorChatDesc,
      ),
    ];

    return Container(
      height: SizeConfig.screenHeight * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  onPressed: () {
                    Nav().pop();
                  },
                  icon: const Icon(Icons.close)),
            ),
            const Gap(16),
            Text(
              context.l10n!.upgradeToPremiumTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(12),
            Text(
              textAlign: TextAlign.center,
              context.l10n!.premiumIntroDescription,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                const Gap(4),
                Text(
                  context.l10n!.premiumTagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const Gap(32),
            Text(
              context.l10n!.whyUpgradeTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(16),
            for (final benefit in benefits)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/sub_star.png",
                      height: 40,
                      width: 40,
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            benefit.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Gap(8),
                          Text(benefit.description,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
