import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class IosNotificationGuidePage extends StatelessWidget {
  const IosNotificationGuidePage({
    super.key,
    this.onComplete,
  });

  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        const Text(
          'Set up notifications',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Turn on these three settings so you never miss an update.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // Setting 1: Deliver Immediately
        _buildSettingCard(
          context,
          icon: CupertinoIcons.bell_fill,
          iconColor: const Color(0xFFFF9800),
          title: 'Delivery → Choose "Immediately"',
          description: 'OnePop delivers at the right time. Keep delivery set to "Immediately" so notifications show up right away instead of being batched.',
          steps: [
            '1. Open the Settings app.',
            '2. Tap Notifications, then OnePop.',
            '3. Make sure "Immediately" is selected (not "Scheduled Summary").',
          ],
          badgeText: 'Important',
          isHighlighted: true,
        ),

        const SizedBox(height: 20),

        // Setting 2: Banner style
        _buildSettingCard(
          context,
          icon: CupertinoIcons.rectangle_stack,
          iconColor: const Color(0xFF5B8DEF),
          title: 'Banner Style → Choose "Persistent"',
          description: 'Banners stay at the top until you tap or dismiss them, so you don\'t miss anything.',
          steps: [
            '1. In Notifications → OnePop, tap Banner Style.',
            '2. Select "Persistent" (not "Temporary").',
          ],
          badgeText: 'Recommended',
        ),

        const SizedBox(height: 20),

        // Setting 3: Show Previews
        _buildSettingCard(
          context,
          icon: CupertinoIcons.eye,
          iconColor: const Color(0xFF66BB6A),
          title: 'Show Previews → Choose "Always"',
          description: 'You\'ll see the full message on the lock screen so you can read it at a glance.',
          steps: [
            '1. In Notifications → OnePop, find Show Previews.',
            '2. Select "Always".',
          ],
          badgeText: 'Handy',
        ),

        const SizedBox(height: 32),

        // Why "Immediately" matters
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF9800).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.lightbulb,
                      color: Color(0xFFFF9800),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Why "Immediately"?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'OnePop is built around specific send times (e.g. 7:00, 12:30, 21:00) so content arrives when it\'s most useful.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you use "Scheduled Summary", iOS will hold notifications until your chosen summary time (e.g. 8:00 AM), which defeats the point of OnePop\'s timing.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Open Settings button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF5B8DEF).withValues(alpha: 0.1),
                const Color(0xFF9C27B0).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                CupertinoIcons.gear_alt,
                size: 48,
                color: Color(0xFF5B8DEF),
              ),
              const SizedBox(height: 16),
              const Text(
                'Open Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap below to jump straight to iOS Settings.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _openAppSettings(context),
                icon: const Icon(CupertinoIcons.arrow_right_circle),
                label: const Text('Open Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8DEF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Footer note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You can change these anytime in Settings → Notifications → OnePop.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (onComplete != null) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B8DEF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Get Started'),
            ),
          ),
        ],
      ],
    );

    return PopScope(
      canPop: onComplete == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && onComplete != null) {
          onComplete!();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Notification Settings'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: body,
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> steps,
    required String badgeText,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? iconColor.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? iconColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isHighlighted ? 12 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withValues(
                    alpha: isHighlighted ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? iconColor.withValues(alpha: 0.05)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.map((step) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isHighlighted)
                        Padding(
                          padding: const EdgeInsets.only(right: 8, top: 2),
                          child: Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            size: 16,
                            color: iconColor,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppSettings(BuildContext context) async {
    final uri = Uri.parse('app-settings:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
