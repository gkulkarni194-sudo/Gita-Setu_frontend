import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../local/profile_local_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'Cream';
  bool _notifications = true;
  bool _dailyShloka = true;
  bool _soundEnabled = true;

  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Cream',
      'bg': const Color(0xFFFDF8EE),
      'accent': const Color(0xFFFF6B00)
    },
    {'name': 'White', 'bg': Colors.white, 'accent': const Color(0xFFFF6B00)},
    {
      'name': 'Grey',
      'bg': const Color(0xFFF5F5F5),
      'accent': const Color(0xFF607D8B)
    },
    {
      'name': 'Dark',
      'bg': const Color(0xFF1a1a2e),
      'accent': const Color(0xFFFF6B00)
    },
  ];

  void _editName() {
    final service = ProfileLocalService(
      Hive.box<dynamic>(ProfileLocalService.boxName),
    );
    final ctrl = TextEditingController(text: service.getProfile()?.name ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Name',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            )),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Your name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.lato(color: AppColors.warmGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.updateName(ctrl.text);
              if (mounted) setState(() {});
              if (!mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Save', style: GoogleFonts.lato(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Local Data',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            )),
        content: Text(
            'Journals are stored only on this device. Mood and chat history are not saved locally or remotely.',
            style: GoogleFonts.lato(color: AppColors.warmGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('OK', style: GoogleFonts.lato(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _openAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileService = ProfileLocalService(
      Hive.box<dynamic>(ProfileLocalService.boxName),
    );
    final profile = profileService.getProfile();
    final name = profile?.name ?? 'Seeker';

    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Navigator.canPop(context))
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: AppColors.darkBrown),
                  ),
                const SizedBox(height: 16),

                Text('Settings',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    )),
                const SizedBox(height: 24),

                // Profile section
                _buildSectionTitle('👤 Profile'),
                _buildCard(children: [
                  _buildRow('Name', name,
                      onTap: _editName,
                      trailing: const Icon(Icons.edit,
                          size: 16, color: AppColors.primary)),
                  _buildDivider(),
                  _buildRow('Profile & Progress', '',
                      onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 14, color: AppColors.warmGrey)),
                ]),
                const SizedBox(height: 20),

                // Appearance section
                _buildSectionTitle('🎨 Appearance'),
                _buildCard(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Color Theme',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkBrown,
                            )),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _themes
                              .map((theme) => GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedTheme = theme['name']),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: theme['bg'],
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _selectedTheme ==
                                                      theme['name']
                                                  ? AppColors.primary
                                                  : AppColors.border,
                                              width: _selectedTheme ==
                                                      theme['name']
                                                  ? 3
                                                  : 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.1),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: _selectedTheme == theme['name']
                                              ? const Icon(Icons.check,
                                                  color: AppColors.primary,
                                                  size: 20)
                                              : null,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(theme['name'],
                                            style: GoogleFonts.lato(
                                              fontSize: 11,
                                              color: AppColors.warmGrey,
                                            )),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // Notifications section
                _buildSectionTitle('🔔 Notifications'),
                _buildCard(children: [
                  _buildSwitch('Push Notifications', _notifications,
                      (val) => setState(() => _notifications = val)),
                  _buildDivider(),
                  _buildSwitch('Daily Shloka Reminder', _dailyShloka,
                      (val) => setState(() => _dailyShloka = val)),
                  _buildDivider(),
                  _buildSwitch('Sound Effects', _soundEnabled,
                      (val) => setState(() => _soundEnabled = val)),
                ]),
                const SizedBox(height: 20),

                // About section
                _buildSectionTitle('ℹ️ About'),
                _buildCard(children: [
                  _buildRow('App Version', '1.0.0'),
                  _buildDivider(),
                  _buildRow('Privacy Policy', '',
                      trailing: const Icon(Icons.open_in_new,
                          size: 14, color: AppColors.primary),
                      onTap: () {}),
                  _buildDivider(),
                  _buildRow('Terms & Conditions', '',
                      trailing: const Icon(Icons.open_in_new,
                          size: 14, color: AppColors.primary),
                      onTap: () {}),
                  _buildDivider(),
                  _buildRow('Contact Support', '',
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 14, color: AppColors.warmGrey),
                      onTap: () {}),
                ]),
                const SizedBox(height: 20),

                _buildSectionTitle('Local Data'),
                _buildCard(children: [
                  _buildRow('Local Data Info', '',
                      textColor: Colors.red,
                      onTap: _deleteAccount,
                      trailing: const Icon(Icons.info_outline,
                          size: 16, color: Colors.red)),
                ]),
                const SizedBox(height: 20),

                _buildSectionTitle('Admin'),
                _buildCard(children: [
                  _buildRow('Admin Passkey Access', '',
                      textColor: AppColors.primary,
                      onTap: _openAdminLogin,
                      trailing: const Icon(Icons.admin_panel_settings,
                          size: 16, color: AppColors.primary)),
                ]),

                const SizedBox(height: 32),
                Center(
                  child: Text(
                      '🪷 GitaSetu v1.0.0\nMade with love for the ISKCON community',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 12, color: AppColors.warmGrey)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.warmGrey,
            letterSpacing: 0.5,
          )),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow(String label, String value,
      {VoidCallback? onTap, Widget? trailing, Color? textColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: textColor ?? AppColors.darkBrown,
                  fontWeight: FontWeight.w500,
                )),
            Row(
              children: [
                if (value.isNotEmpty)
                  Text(value,
                      style: GoogleFonts.lato(
                          fontSize: 14, color: AppColors.warmGrey)),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: AppColors.darkBrown,
                fontWeight: FontWeight.w500,
              )),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: AppColors.border,
    );
  }
}
