import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/services/localization_service.dart';
import '../../../core/services/nav.dart';
import '../../config/model/app_config.dart';
import '../view/subscription_view.dart';
import '../viewmodel/access_control.dart';

/// Explains why a feature is closed and offers the subscription flow.
///
/// Returns true if the user chose to go to the subscription screen, so callers
/// can abandon whatever they were about to do either way.
Future<bool> showTrialGateDialog(
  BuildContext context,
  FeatureAccess access,
) async {
  final l10n = context.l10n!;

  final (String title, String message) = switch (access.reason) {
    AccessReason.limitReached => (
        l10n.trialLimitReachedTitle,
        l10n.trialLimitReachedMessage(access.limit ?? 0),
      ),
    AccessReason.trialExpired => (
        l10n.trialEndedTitle,
        l10n.trialEndedMessage,
      ),
    // Anything else reaching this dialog is a feature the backend simply does
    // not include in the trial.
    _ => (l10n.subscription, l10n.featureNotInTrial),
  };

  final theme = Theme.of(context);

  final choseSubscribe = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: theme.colorScheme.primary,
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      // No colour override: the theme's text styles already carry the right
      // foreground for light and dark.
      content: Text(message, style: theme.textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            l10n.notNow,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            l10n.subscribeNow,
            style: TextStyle(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  if (choseSubscribe == true) {
    Nav().push(SubscriptionView());
    return true;
  }
  return false;
}

/// A strip showing how much trial the user has left.
///
/// Renders nothing unless the user is actually inside a trial window, so it is
/// safe to drop at the top of any screen. When [feature] is capped it also
/// shows the remaining allowance.
class TrialStatusBanner extends ConsumerWidget {
  final FreeFeature feature;

  const TrialStatusBanner({super.key, required this.feature});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(accessControlProvider).valueOrNull;
    if (status == null || status.tier != AccessTier.trial) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = context.l10n!;
    final access = status.accessTo(feature);
    final remaining = access.remaining;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 18,
            color: theme.colorScheme.onSecondary,
          ),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.trialDaysLeft(status.daysRemaining),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (remaining != null) ...[
                  const Gap(2),
                  Text(
                    l10n.freeMockTestsLeft(remaining, access.limit!),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
