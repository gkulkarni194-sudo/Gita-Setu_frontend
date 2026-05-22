import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../../widgets/admin_guard.dart';
import 'admin_mentor_screen.dart';
import 'admin_settings_screen.dart';
import '../../constants/app_constants.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardTab(),
    const AdminMentorScreen(),
    const AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1a1560),
            border: Border(
              top: BorderSide(color: AppColors.gold, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF1a1560),
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.white54,
            items: const [
              BottomNavigationBarItem(
                  icon: Text('📊', style: TextStyle(fontSize: 22)),
                  label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Text('🧘', style: TextStyle(fontSize: 22)),
                  label: 'Mentors'),
              BottomNavigationBarItem(
                  icon: Text('⚙️', style: TextStyle(fontSize: 22)),
                  label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class _DashboardMetrics {
  final String databaseConnected;
  final String aiEngine;
  final List<String> activeProtocols;

  const _DashboardMetrics({
    required this.databaseConnected,
    required this.aiEngine,
    required this.activeProtocols,
  });

  factory _DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return _DashboardMetrics(
      databaseConnected: json['database_connected'] as String? ?? '—',
      aiEngine: json['ai_engine'] as String? ?? '—',
      activeProtocols: (json['active_protocols'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab
// ---------------------------------------------------------------------------

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  _DashboardMetrics? _metrics;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMetrics();
  }

  Future<void> _fetchMetrics() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/admin/dashboard');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;

      // Flat error envelope from Bug 4 fix
      if (body['status'] == 'error') {
        throw Exception(body['response'] ?? 'Unknown server error');
      }

      final data = body['data'] as Map<String, dynamic>? ?? body;
      setState(() {
        _metrics = _DashboardMetrics.fromJson(data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchMetrics,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAdminBadge(),
                  const SizedBox(height: 16),
                  Text(
                    'Admin Dashboard',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  Text(
                    'Live backend protocol metrics',
                    style: GoogleFonts.lato(
                        fontSize: 14, color: AppColors.warmGrey),
                  ),
                  const SizedBox(height: 28),
                  _buildMetricsSection(),
                  const SizedBox(height: 24),
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    context,
                    '🧘',
                    'Manage Mentors',
                    'Add, edit or remove mentor profiles and schedules',
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminMentorScreen())),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1560),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛡️', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            'ADMIN',
            style: GoogleFonts.lato(
              fontSize: 11,
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return _ErrorCard(message: _error!, onRetry: _fetchMetrics);
    }

    final m = _metrics!;
    return Column(
      children: [
        _buildMetricRow('🗄️', 'Database', m.databaseConnected),
        const SizedBox(height: 12),
        _buildMetricRow('🤖', 'AI Engine', m.aiEngine),
        const SizedBox(height: 12),
        _buildProtocolsCard(m.activeProtocols),
      ],
    );
  }

  Widget _buildMetricRow(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lato(
                    fontSize: 11,
                    color: AppColors.warmGrey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolsCard(List<String> protocols) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                'ACTIVE PROTOCOLS',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: AppColors.warmGrey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: protocols.map((p) => _ProtocolChip(label: p)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String emoji, String title,
      String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.saffronLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      )),
                  Text(subtitle,
                      style: GoogleFonts.lato(
                          fontSize: 12, color: AppColors.warmGrey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.warmGrey),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ProtocolChip extends StatelessWidget {
  final String label;
  const _ProtocolChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1560).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1a1560).withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1a1560),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 10),
          Text(
            'Failed to load metrics',
            style: GoogleFonts.playfairDisplay(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                GoogleFonts.lato(fontSize: 12, color: AppColors.warmGrey),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text('Retry',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}