import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:truthlens/core/widgets/app_header.dart';
import 'package:truthlens/core/widgets/responsive_layout.dart';
import 'package:truthlens/core/widgets/navigation_sidebar.dart';
import 'package:truthlens/features/admin/presentation/providers/admin_provider.dart';
import 'package:truthlens/features/auth/data/models/user_model.dart';
import 'package:truthlens/features/feedback/data/models/feedback_report_model.dart';
import 'package:truthlens/features/admin/data/models/admin_analytics_model.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  String _activeSubTab = 'reports'; // 'reports' | 'users'

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);

    return Scaffold(
      drawer: ResponsiveLayout.isMobile(context) ? const NavigationDrawerMobile() : null,
      body: Row(
        children: [
          if (ResponsiveLayout.isTabletDesktop(context)) const NavigationSidebar(),
          Expanded(
            child: Column(
              children: [
                const AppHeader(title: 'Admin Dashboard'),
                Expanded(
                  child: state.isLoading && state.analytics == null
                      ? const Center(child: CircularProgressIndicator())
                      : state.error != null && state.analytics == null
                          ? Center(child: Text(state.error!))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 1200),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (state.analytics != null) ...[
                                        _buildKPIs(context, state.analytics!),
                                        const SizedBox(height: 24),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            if (constraints.maxWidth > 900) {
                                              return Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: _buildManagementSection(state),
                                                  ),
                                                  const SizedBox(width: 24),
                                                  Expanded(
                                                    flex: 1,
                                                    child: _buildRightBentoColumn(state.analytics!),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Column(
                                                children: [
                                                  _buildManagementSection(state),
                                                  const SizedBox(height: 24),
                                                  _buildRightBentoColumn(state.analytics!),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIs(BuildContext context, AdminAnalytics analytics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _kpiCard(
              context,
              'Total Users',
              analytics.totalUsers.toString(),
              Icons.group_outlined,
              subtitle: 'Active Members',
              subtitleColor: Theme.of(context).colorScheme.tertiary,
              subtitleIcon: Icons.trending_up,
            ),
            _kpiCard(
              context,
              'Total Fact Checks',
              analytics.totalFactChecks.toString(),
              Icons.fact_check_outlined,
              subtitle: 'Avg Conf: ${analytics.averageConfidence}%',
              subtitleColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            _kpiCard(
              context,
              'Pending Feedback',
              analytics.pendingFeedback.toString(),
              Icons.pending_actions_outlined,
              subtitle: 'Requires attention',
              subtitleColor: Theme.of(context).colorScheme.error,
              subtitleIcon: Icons.warning_amber_outlined,
            ),
            _kpiCard(
              context,
              'Saved Bookmarks',
              analytics.savedBookmarks.toString(),
              Icons.bookmark_added_outlined,
              subtitle: 'Saved by community',
              subtitleColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        );
      },
    );
  }

  Widget _kpiCard(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    required String subtitle,
    required Color subtitleColor,
    IconData? subtitleIcon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (subtitleIcon != null) ...[
                        Icon(subtitleIcon, size: 12, color: subtitleColor),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: subtitleColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection(AdminState state) {
    return Column(
      children: [
        // Sub tabs controls
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              _subTabButton('reports', 'Feedback Reports (${state.reports.length})'),
              const SizedBox(width: 8),
              _subTabButton('users', 'User Accounts (${state.users.length})'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Active Sub Tab Content
        if (_activeSubTab == 'reports')
          _buildFeedbackReportsTable(state.reports)
        else
          _buildUsersDirectoryTable(state.users),
      ],
    );
  }

  Widget _subTabButton(String tab, String label) {
    final isActive = _activeSubTab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeSubTab = tab),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).colorScheme.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackReportsTable(List<FeedbackReport> reports) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Flagged Feedback Reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          if (reports.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No feedback reports submitted yet.',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final rep = reports[index];
                final statusStyle = _getReportStatusStyle(rep.status);
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rep.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusStyle.bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: statusStyle.border),
                            ),
                            child: Text(
                              rep.status.toUpperCase(),
                              style: TextStyle(color: statusStyle.text, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rep.description,
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMd().format(rep.createdAt),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: rep.status == 'reviewed'
                                    ? null
                                    : () => ref.read(adminProvider.notifier).updateReportStatus(rep.id, 'reviewed'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text('Review', style: TextStyle(fontSize: 11)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: rep.status == 'resolved'
                                    ? null
                                    : () => ref.read(adminProvider.notifier).updateReportStatus(rep.id, 'resolved'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F5132),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text('Resolve', style: TextStyle(fontSize: 11)),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 18),
                                onPressed: () {
                                  ref.read(adminProvider.notifier).deleteReport(rep.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUsersDirectoryTable(List<User> users) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'System Users Directory',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No users registered.',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                final isAdmin = user.role == 'admin';
                final isProtected = user.email == 'admin@fakenewsdetection.com';
                return ListTile(
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAdmin ? const Color(0xFFF3E8FF) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isAdmin ? const Color(0xFF6B21A8) : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      if (!isAdmin && !isProtected) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete User'),
                                content: const Text('Deleting this user will cascade delete all their bookmarks and reports. Proceed?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                  ElevatedButton(
                                    onPressed: () {
                                      ref.read(adminProvider.notifier).deleteUser(user.id);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRightBentoColumn(AdminAnalytics analytics) {
    return Column(
      children: [
        // Verdict Distribution Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verdict Distribution',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 160,
                child: Center(
                  child: CustomPaint(
                    size: const Size(140, 140),
                    painter: _PieChartPainter(analytics.verdictDistribution),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildVerdictLegend(analytics.verdictDistribution),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Activity Feed Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Audit Logs / Feed',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildAuditRow('Staff Analyst reviewed feedback.', 'Report was marked as Reviewed.', 'Just now', Theme.of(context).colorScheme.primary),
              const Divider(height: 24),
              _buildAuditRow('Admin deleted a user account.', 'Cascaded deletions applied to database.', '1 hour ago', Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerdictLegend(Map<String, int> distribution) {
    final tr = distribution['true'] ?? 0;
    final fa = distribution['false'] ?? 0;
    final mx = distribution['mixture'] ?? 0;
    final total = tr + fa + mx;
    final tPct = total > 0 ? (tr / total * 100).round() : 0;
    final fPct = total > 0 ? (fa / total * 100).round() : 0;
    final mPct = total > 0 ? (mx / total * 100).round() : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _legendItem(const Color(0xFF22C55E), 'True ($tPct%)'),
        _legendItem(const Color(0xFFEF4444), 'False ($fPct%)'),
        _legendItem(const Color(0xFFF59E0B), 'Mix ($mPct%)'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAuditRow(String title, String subtitle, String time, Color dotColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  _StatusUIStyle _getReportStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusUIStyle(bg: const Color(0xFFF3F4F6), border: const Color(0xFFE5E7EB), text: Colors.grey.shade700);
      case 'reviewed':
        return _StatusUIStyle(bg: const Color(0xFFDBEAFE), border: const Color(0xFFBFDBFE), text: const Color(0xFF1E40AF));
      case 'resolved':
        return _StatusUIStyle(bg: const Color(0xFFD1FAE5), border: const Color(0xFFA7F3D0), text: const Color(0xFF065F46));
      default:
        return _StatusUIStyle(bg: const Color(0xFFF3F4F6), border: const Color(0xFFE5E7EB), text: Colors.grey);
    }
  }
}

class _StatusUIStyle {
  final Color bg;
  final Color border;
  final Color text;

  _StatusUIStyle({
    required this.bg,
    required this.border,
    required this.text,
  });
}

class _PieChartPainter extends CustomPainter {
  final Map<String, int> distribution;

  _PieChartPainter(this.distribution);

  @override
  void paint(Canvas canvas, Size size) {
    final tr = (distribution['true'] ?? 0).toDouble();
    final fa = (distribution['false'] ?? 0).toDouble();
    final mx = (distribution['mixture'] ?? 0).toDouble();
    final unv = (distribution['unverified'] ?? 0).toDouble();

    final total = tr + fa + mx + unv;
    if (total == 0) {
      final paint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16;
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - 8, paint);
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;

    final paintTrue = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.butt;

    final paintFalse = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.butt;

    final paintMix = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.butt;

    final paintUnverified = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.butt;

    if (tr > 0) {
      final sweepAngle = (tr / total) * 2 * pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paintTrue);
      startAngle += sweepAngle;
    }
    if (fa > 0) {
      final sweepAngle = (fa / total) * 2 * pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paintFalse);
      startAngle += sweepAngle;
    }
    if (mx > 0) {
      final sweepAngle = (mx / total) * 2 * pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paintMix);
      startAngle += sweepAngle;
    }
    if (unv > 0) {
      final sweepAngle = (unv / total) * 2 * pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paintUnverified);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
