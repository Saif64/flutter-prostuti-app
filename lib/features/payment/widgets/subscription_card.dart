import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:prostuti/core/services/size_config.dart';

class SubscriptionCard extends StatelessWidget {
  final String planTitle, price, durationText;
  final bool isSelected; // To determine if this card is selected

  const SubscriptionCard({
    super.key,
    required this.planTitle,
    required this.price,
    required this.durationText,
    this.isSelected = false, // Defaults to false if not provided
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth,
      height: SizeConfig.h(75),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
        image: isSelected // Add background image only if selected
            ? const DecorationImage(
                image: AssetImage('assets/images/sub_card_background.png'),
                fit: BoxFit.cover,
              )
            : null, // No background image if not selected
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(8),
              RichText(
                text: TextSpan(
                  text: '$price   ',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.w700),
                  children: <TextSpan>[
                    TextSpan(
                        text: durationText,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w400,
                            )),
                  ],
                ),
              ),
            ],
          ),
          if (isSelected)
            Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  "assets/icons/checkmark-circle-01.png",
                  fit: BoxFit.cover,
                )),
        ],
      ),
    );
  }
}
