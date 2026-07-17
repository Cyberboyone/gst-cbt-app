import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/profile_provider.dart';
import '../widgets/powered_by_footer.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final TextEditingController _friendCodeController = TextEditingController();
  bool _isClaiming = false;
  bool _claimed = false;

  @override
  void dispose() {
    _friendCodeController.dispose();
    super.dispose();
  }

  void _shareReferral(String code) {
    final msg = 'Join me on GST CBT Prep to practice and pass your General Studies courses offline!\n'
        'Use my invite code: $code to unlock 20 bonus coins instantly.\n'
        'Download the app now!';
    Share.share(msg);
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referral code copied to clipboard!')),
      );
    });
  }

  void _claimBonus() {
    final code = _friendCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isClaiming = true;
    });

    // Simulate validation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      if (code == profileProvider.profile?.referralCode) {
        setState(() {
          _isClaiming = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot enter your own referral code!'), backgroundColor: Colors.red),
        );
        return;
      }

      profileProvider.addCoins(20); // reward 20 coins
      
      setState(() {
        _isClaiming = false;
        _claimed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully claimed! +20 Coins 🪙 added to balance.'),
          backgroundColor: AppColors.navy,
        ),
      );
      _friendCodeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final code = profile?.referralCode ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite & Referrals', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          children: [
            // Banner illustration
            Container(
              height: 140.0,
              decoration: BoxDecoration(
                color: AppColors.peach,
                borderRadius: BorderRadius.circular(20.0),
              ),
              alignment: Alignment.center,
              child: const Text('🎁 🤝 🪙', style: TextStyle(fontSize: 48.0)),
            ),
            const SizedBox(height: 24.0),

            const Text(
              'Share the Knowledge',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900, color: AppColors.navy),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Invite your classmates to practice on GST CBT Prep. You both receive bonus coins when they complete their first quiz session!',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 13.5, height: 1.45),
            ),
            const SizedBox(height: 24.0),

            // Share Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const [
                  BoxShadow(color: AppColors.cardShadow, blurRadius: 10.0, offset: Offset(0, 4))
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'YOUR REFERRAL CODE',
                    style: TextStyle(color: AppColors.inkSoft, fontSize: 11.0, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          code,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                            letterSpacing: 1.0,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, color: AppColors.orange),
                          onPressed: () => _copyCode(code),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton.icon(
                      onPressed: () => _shareReferral(code),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share Code via WhatsApp / SMS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Claim Code Card
            if (!_claimed) ...[
              const Text(
                'Enter Invite Code',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: AppColors.navy),
              ),
              const SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: const [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 10.0, offset: Offset(0, 4))
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Pasted friend\'s code to unlock 20 starter coins immediately.',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 12.0, height: 1.3),
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _friendCodeController,
                            decoration: InputDecoration(
                              hintText: 'e.g., MUSA-A1B2',
                              hintStyle: const TextStyle(fontSize: 13.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        SizedBox(
                          height: 48.0,
                          child: ElevatedButton(
                            onPressed: _isClaiming ? null : _claimBonus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              elevation: 0,
                            ),
                            child: _isClaiming
                                ? const SizedBox(width: 20.0, height: 20.0, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white))
                                : const Text('Claim', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
            ],

            const PoweredByFooter(),
          ],
        ),
      ),
    );
  }
}
