import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:truthlens/core/widgets/app_header.dart';
import 'package:truthlens/core/widgets/responsive_layout.dart';
import 'package:truthlens/core/widgets/navigation_sidebar.dart';
import 'package:truthlens/features/verify/presentation/providers/verify_provider.dart';
import 'package:truthlens/features/verify/data/models/claim_check_model.dart';
import 'package:truthlens/features/history/presentation/providers/history_provider.dart';
import 'package:truthlens/features/history/data/models/saved_article_model.dart';

class ReportScreen extends ConsumerWidget {
  final String reportId;

  const ReportScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsyncValue = ref.watch(reportProvider(reportId));

    return Scaffold(
      drawer: ResponsiveLayout.isMobile(context) ? const NavigationDrawerMobile() : null,
      body: Row(
        children: [
          if (ResponsiveLayout.isTabletDesktop(context)) const NavigationSidebar(),
          Expanded(
            child: Column(
              children: [
                const AppHeader(title: 'Verification Report'),
                Expanded(
                  child: reportAsyncValue.when(
                    data: (report) => _buildReportContent(context, ref, report),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => _buildErrorState(context, err.toString()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, WidgetRef ref, VerificationResult report) {
    final verdictStyle = _getVerdictStyle(report.verdict);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Back to Verification'),
              ),
              const SizedBox(height: 16),

              // Header Section
              _buildHeaderCard(context, ref, report, verdictStyle),
              const SizedBox(height: 24),

              // Reasoning Section
              _buildSectionCard(
                context,
                title: 'Reasoning',
                icon: Icons.psychology_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        report.explanation,
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...report.reasoning.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final text = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: verdictStyle.bg,
                              child: Text(
                                '${idx + 1}',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: verdictStyle.text),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(text, style: const TextStyle(height: 1.4)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Supporting Evidence
              _buildSectionCard(
                context,
                title: 'Supporting Evidence (${report.evidenceCards.length})',
                icon: Icons.fact_check_outlined,
                child: report.evidenceCards.isEmpty
                    ? _buildEmptyState('No supporting evidence returned.')
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossCount = constraints.maxWidth > 650 ? 2 : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 220,
                            ),
                            itemCount: report.evidenceCards.length,
                            itemBuilder: (context, index) {
                              final ev = report.evidenceCards[index];
                              return _buildEvidenceCard(context, ev);
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),

              // Conflicting Evidence
              _buildSectionCard(
                context,
                title: 'Conflicting Evidence (${report.conflictingEvidence.length})',
                icon: Icons.compare_arrows_outlined,
                child: report.conflictingEvidence.isEmpty
                    ? _buildEmptyState('No conflicting evidence returned.')
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Text(
                          jsonEncode(report.conflictingEvidence),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Source Credibility
              _buildSectionCard(
                context,
                title: 'Source Credibility (${report.credibility.length})',
                icon: Icons.verified_user_outlined,
                child: report.credibility.isEmpty
                    ? _buildEmptyState('No source credibility details returned.')
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossCount = constraints.maxWidth > 650 ? 2 : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 240,
                            ),
                            itemCount: report.credibility.length,
                            itemBuilder: (context, index) {
                              final sc = report.credibility[index];
                              return _buildSourceCredibilityCard(context, sc);
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),

              // Execution Pipeline
              _buildSectionCard(
                context,
                title: 'Execution Pipeline',
                icon: Icons.account_tree_outlined,
                child: report.pipeline.isEmpty
                    ? _buildEmptyState('No pipeline details available.')
                    : _buildPipelineTimeline(context, report.pipeline),
              ),
              const SizedBox(height: 24),

              // Workflow Timing
              if (report.performance != null) ...[
                _buildSectionCard(
                  context,
                  title: 'Workflow Timing',
                  icon: Icons.timer_outlined,
                  child: _buildPerformanceMetrics(context, report.performance!),
                ),
                const SizedBox(height: 24),
              ],

              // Execution Metadata
              _buildSectionCard(
                context,
                title: 'Execution Metadata',
                icon: Icons.manage_search_outlined,
                child: _buildMetadataGrid(context, report.metadata),
              ),
              const SizedBox(height: 24),

              ExpansionTile(
                title: const Row(
                  children: [
                    Icon(Icons.data_object_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Raw JSON Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                backgroundColor: Theme.of(context).colorScheme.surface,
                children: [
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 400),
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade900,
                    child: SingleChildScrollView(
                      child: Text(
                        const JsonEncoder.withIndent('  ').convert(report.raw),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.greenAccent),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, WidgetRef ref, VerificationResult report, _VerdictUIStyle verdictStyle) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CLAIM',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        report.claim,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Analyzed: ${DateFormat.yMMMd().add_jm().format(report.createdAt)}',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: verdictStyle.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: verdictStyle.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(verdictStyle.icon, size: 18, color: verdictStyle.text),
                          const SizedBox(width: 6),
                          Text(
                            verdictStyle.label,
                            style: TextStyle(color: verdictStyle.text, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: report.confidence / 100,
                            strokeWidth: 8,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                            color: verdictStyle.barColor,
                          ),
                          Center(
                            child: Text(
                              '${report.confidence}%',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showSaveArticleDialog(context, ref, report),
              icon: const Icon(Icons.bookmark_outline, size: 18),
              label: const Text('Save Bookmark'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveArticleDialog(BuildContext context, WidgetRef ref, VerificationResult result) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Verification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Save this verification to review later or attach personal notes.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add context for later review.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final article = SavedArticle(
                  id: '',
                  title: result.claim,
                  url: result.url ?? (result.sources.isNotEmpty ? result.sources.first.url : 'https://truthlens.verify.info/claim'),
                  verdict: result.verdict,
                  notes: notesController.text,
                  savedAt: DateTime.now(),
                );
                ref.read(historyProvider.notifier).addArticle(article);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved successfully.')),
                );
              },
              child: const Text('Confirm Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildEvidenceCard(BuildContext context, EvidenceCard ev) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color(0xFFF8F9FF),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ev.title.isNotEmpty ? ev.title : 'Evidence Review',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Text(
                    ev.evidenceType,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Source: ${ev.source}',
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                ev.snippet,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Credibility: ${ev.credibilityScore}   ',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Verdict: ${ev.verdict}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (ev.url.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: ev.url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('URL copied to clipboard')),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Copy Link',
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.copy, size: 10, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCredibilityCard(BuildContext context, SourceCredibility sc) {
    final reliabilityStyle = _getReliabilityStyle(sc.reliability);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color(0xFFF8F9FF),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sc.domain,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (sc.officialSource)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.assured_workload_outlined, size: 10, color: Color(0xFF1E40AF)),
                        SizedBox(width: 4),
                        Text(
                          'Official',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: sc.url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL copied to clipboard')),
                );
              },
              child: Text(
                sc.url,
                style: const TextStyle(fontSize: 10, color: Colors.blue, decoration: TextDecoration.underline),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(context, 'Trust Score', sc.trustScore),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reliability', style: TextStyle(fontSize: 9, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: reliabilityStyle.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: reliabilityStyle.border),
                          ),
                          child: Text(
                            sc.reliability.toUpperCase(),
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: reliabilityStyle.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(context, 'Hist. Conf.', sc.historicalConfidence),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                sc.reason,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPipelineTimeline(BuildContext context, List<PipelineStep> steps) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final idx = entry.key;
        final step = entry.value;
        final isLast = idx == steps.length - 1;

        Color iconBg = Colors.grey.shade100;
        Color iconColor = Colors.grey;
        IconData icon = Icons.radio_button_unchecked;

        if (step.status == 'success') {
          iconBg = const Color(0xFFDCFCE7);
          iconColor = const Color(0xFF166534);
          icon = Icons.check;
        } else if (step.status == 'failed') {
          iconBg = const Color(0xFFFEE2E2);
          iconColor = const Color(0xFF991B1B);
          icon = Icons.close;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: iconBg == Colors.grey.shade100 ? Colors.grey.shade300 : Colors.transparent),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                if (!isLast)
                  Container(
                    width: 1.5,
                    height: 48,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.label,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        _formatDuration(step.durationMs),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildChipTag(context, 'Status: ${step.status.replaceAll('_', ' ')}'),
                      const SizedBox(width: 8),
                      _buildChipTag(context, 'Success: ${step.success ? "Yes" : "No"}'),
                      const SizedBox(width: 8),
                      _buildChipTag(context, 'Retries: ${step.retries}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChipTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context, PerformanceMetrics perf) {
    final list = [
      _TimingStep('Fact Check', perf.factCheckMs, const Color(0xFF2563EB)),
      _TimingStep('News Search', perf.newsSearchMs, const Color(0xFF7C3AED)),
      _TimingStep('Web Search', perf.webSearchMs, const Color(0xFF0891B2)),
      _TimingStep('Source Credibility', perf.credibilityMs, const Color(0xFF059669)),
      _TimingStep('LLM Analysis', perf.llmAnalysisMs, const Color(0xFFD97706)),
    ].where((step) => step.durationMs > 0).toList();

    final maxVal = list.map((e) => e.durationMs).fold(1.0, (prev, element) => element > prev ? element : prev);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latency Breakdown',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              'Total: ${_formatDuration(perf.totalMs)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...list.map((step) {
          final pct = step.durationMs / maxVal;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(step.label, style: const TextStyle(fontSize: 12)),
                    Text(
                      _formatDuration(step.durationMs),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: step.color),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(step.color),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetadataGrid(BuildContext context, VerificationMetadata? meta) {
    if (meta == null) return _buildEmptyState('No execution metadata.');
    final rows = [
      ['Evidence Round', meta.evidenceRound.toString()],
      ['Number of Sources', meta.sourceCount.toString()],
      ['Number of Searches', meta.searchCount.toString()],
      ['Confidence Threshold', '${meta.confidenceThreshold}%'],
      ['Visited Tools', meta.visitedTools.isNotEmpty ? meta.visitedTools.join(', ') : 'Not Available'],
      ['ErrorsCount', meta.errors.length.toString()],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 500 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.5,
          ),
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final row = rows[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    row[0].toUpperCase(),
                    style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    row[1],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(double ms) {
    if (ms <= 0) return 'Not Available';
    if (ms < 1000) return '${ms.toStringAsFixed(1)} ms';
    return '${(ms / 1000).toStringAsFixed(2)} s';
  }

  _VerdictUIStyle _getVerdictStyle(String verdict) {
    switch (verdict.toLowerCase()) {
      case 'true':
        return _VerdictUIStyle(
          bg: const Color(0xFFDCFCE7),
          border: const Color(0xFFBBF7D0),
          text: const Color(0xFF166534),
          label: 'TRUE',
          icon: Icons.verified_outlined,
          barColor: const Color(0xFF22C55E),
        );
      case 'false':
        return _VerdictUIStyle(
          bg: const Color(0xFFFEE2E2),
          border: const Color(0xFFFECACA),
          text: const Color(0xFF991B1B),
          label: 'FALSE',
          icon: Icons.dangerous_outlined,
          barColor: const Color(0xFFEF4444),
        );
      case 'mixture':
        return _VerdictUIStyle(
          bg: const Color(0xFFFEF3C7),
          border: const Color(0xFFFDE68A),
          text: const Color(0xFF92400E),
          label: 'MIXED',
          icon: Icons.contrast_outlined,
          barColor: const Color(0xFFF59E0B),
        );
      default:
        return _VerdictUIStyle(
          bg: const Color(0xFFF3F4F6),
          border: const Color(0xFFE5E7EB),
          text: const Color(0xFF374151),
          label: 'UNVERIFIED',
          icon: Icons.help_outline,
          barColor: Colors.grey,
        );
    }
  }

  _ReliabilityStyle _getReliabilityStyle(String val) {
    final v = val.toLowerCase();
    if (v.contains('very_high') || v.contains('high')) {
      return _ReliabilityStyle(bg: const Color(0xFFDCFCE7), border: const Color(0xFFBBF7D0), text: const Color(0xFF166534));
    }
    if (v.contains('medium')) {
      return _ReliabilityStyle(bg: const Color(0xFFFEF3C7), border: const Color(0xFFFDE68A), text: const Color(0xFF92400E));
    }
    if (v.contains('low')) {
      return _ReliabilityStyle(bg: const Color(0xFFFEE2E2), border: const Color(0xFFFECACA), text: const Color(0xFF991B1B));
    }
    return _ReliabilityStyle(bg: const Color(0xFFF3F4F6), border: const Color(0xFFE5E7EB), text: Colors.grey.shade800);
  }
}

class _VerdictUIStyle {
  final Color bg;
  final Color border;
  final Color text;
  final String label;
  final IconData icon;
  final Color barColor;

  _VerdictUIStyle({
    required this.bg,
    required this.border,
    required this.text,
    required this.label,
    required this.icon,
    required this.barColor,
  });
}

class _ReliabilityStyle {
  final Color bg;
  final Color border;
  final Color text;

  _ReliabilityStyle({
    required this.bg,
    required this.border,
    required this.text,
  });
}

class _TimingStep {
  final String label;
  final double durationMs;
  final Color color;

  _TimingStep(this.label, this.durationMs, this.color);
}
