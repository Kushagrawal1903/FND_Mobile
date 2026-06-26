import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:truthlens/core/widgets/responsive_layout.dart';
import 'package:truthlens/core/widgets/app_header.dart';
import 'package:truthlens/core/widgets/navigation_sidebar.dart';
import 'package:truthlens/features/verify/presentation/providers/verify_provider.dart';
import 'package:truthlens/features/feedback/presentation/providers/feedback_provider.dart';
import 'package:truthlens/features/history/presentation/providers/history_provider.dart';
import 'package:truthlens/features/history/data/models/saved_article_model.dart';
import 'package:truthlens/features/verify/data/models/claim_check_model.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _claimController = TextEditingController();
  final _urlController = TextEditingController();
  final _deepAnalysisController = TextEditingController();

  final _feedbackTitleController = TextEditingController();
  final _feedbackDescController = TextEditingController();
  final _feedbackFormKey = GlobalKey<FormState>();

  bool _isSubmittingFeedback = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(verifyProvider.notifier).clearResult();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _claimController.dispose();
    _urlController.dispose();
    _deepAnalysisController.dispose();
    _feedbackTitleController.dispose();
    _feedbackDescController.dispose();
    super.dispose();
  }

  void _verifyClaim() {
    final text = _claimController.text.trim();
    if (text.length >= 10) {
      ref.read(verifyProvider.notifier).checkClaim(text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a claim text of at least 10 characters.')),
      );
    }
  }

  void _verifyUrl() {
    final text = _urlController.text.trim();
    if (text.startsWith('http')) {
      ref.read(verifyProvider.notifier).checkUrl(text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL starting with http:// or https://')),
      );
    }
  }

  void _deepAnalyze() {
    final text = _deepAnalysisController.text.trim();
    if (text.length >= 10) {
      ref.read(verifyProvider.notifier).deepAnalyze(text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a text block of at least 10 characters.')),
      );
    }
  }

  Future<void> _submitFeedback() async {
    if (!_feedbackFormKey.currentState!.validate()) return;
    setState(() => _isSubmittingFeedback = true);
    try {
      await ref.read(feedbackProvider.notifier).submitReport(
        _feedbackTitleController.text.trim(),
        _feedbackDescController.text.trim(),
      );
      _feedbackTitleController.clear();
      _feedbackDescController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingFeedback = false);
    }
  }

  void _showSaveArticleDialog(VerificationResult result) {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyProvider);

    return Scaffold(
      drawer: ResponsiveLayout.isMobile(context) ? const NavigationDrawerMobile() : null,
      body: Row(
        children: [
          if (ResponsiveLayout.isTabletDesktop(context)) const NavigationSidebar(),
          Expanded(
            child: Column(
              children: [
                const AppHeader(title: 'Verify Information'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTabs(),
                                  const SizedBox(height: 24),
                                  _buildForm(),
                                  const SizedBox(height: 24),
                                  if (state.isLoading)
                                    _buildLoadingState()
                                  else if (state.error != null)
                                    _buildErrorState(state.error!)
                                  else if (state.result != null)
                                    _buildResultCard(state.result!),
                                  if (ResponsiveLayout.isMobile(context)) ...[
                                    const SizedBox(height: 32),
                                    _buildFeedbackSection(),
                                  ],
                                ],
                              ),
                            ),
                            if (ResponsiveLayout.isTabletDesktop(context)) ...[
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 1,
                                child: _buildFeedbackSection(),
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

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Verify Claim'),
          Tab(text: 'Verify URL'),
          Tab(text: 'Deep Analysis'),
        ],
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildForm() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );

    return SizedBox(
      height: 240,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildInputTab(
            'Statement or claim to check',
            'e.g. "COVID-19 vaccines contain microchips for tracking people."',
            _claimController,
            _verifyClaim,
            maxLines: 4,
            border: border,
          ),
          _buildInputTab(
            'URL to Fact-Check',
            'https://example.com/news-article-headline',
            _urlController,
            _verifyUrl,
            maxLines: 1,
            border: border,
          ),
          _buildInputTab(
            'Text block to analyze',
            'Paste a full paragraph, article chunk, or statement here.',
            _deepAnalysisController,
            _deepAnalyze,
            maxLines: 6,
            border: border,
          ),
        ],
      ),
    );
  }

  Widget _buildInputTab(
    String label,
    String hint,
    TextEditingController controller,
    VoidCallback onSubmit, {
    required int maxLines,
    required OutlineInputBorder border,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: hint,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onSubmit,
          icon: const Icon(Icons.verified_outlined, size: 18),
          label: const Text('Initiate Verification'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
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
              children: [
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agentic verification running',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Planner, evidence, credibility, reasoning, and report agents are executing.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildProgressStep('Collecting evidence')),
                const SizedBox(width: 12),
                Expanded(child: _buildProgressStep('Scoring sources')),
                const SizedBox(width: 12),
                Expanded(child: _buildProgressStep('Generating report')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(VerificationResult result) {
    final verdictStyle = _getVerdictStyle(result.verdict);

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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CLAIM',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.claim,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: verdictStyle.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: verdictStyle.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(verdictStyle.icon, size: 16, color: verdictStyle.text),
                          const SizedBox(width: 6),
                          Text(
                            verdictStyle.label,
                            style: TextStyle(color: verdictStyle.text, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confidence: ${result.confidence}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              'Reasoning',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result.explanation,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showSaveArticleDialog(result),
                  icon: const Icon(Icons.bookmark_border, size: 18),
                  label: const Text('Save Bookmark'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.go('/report/${result.id}'),
                  icon: const Icon(Icons.summarize_outlined, size: 18),
                  label: const Text('Detailed Report'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    final feedbackState = ref.watch(feedbackProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Form(
            key: _feedbackFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Submit Feedback',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Report an incorrect verdict or missing evidence to the administration team.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _feedbackTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Inaccurate verdict',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _feedbackDescController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Explanation',
                    hintText: 'Explain what is incorrect or what information is missing.',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Explanation is required' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSubmittingFeedback ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  child: _isSubmittingFeedback
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Report'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
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
                'My Feedback Feed (${feedbackState.reports.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (feedbackState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (feedbackState.reports.isEmpty)
                const Text(
                  'You have not submitted any reports yet.',
                  style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: feedbackState.reports.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final report = feedbackState.reports[index];
                    final statusStyle = _getReportStatusStyle(report.status);
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  report.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusStyle.bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusStyle.border),
                                ),
                                child: Text(
                                  report.status.toUpperCase(),
                                  style: TextStyle(color: statusStyle.text, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            report.description,
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              DateFormat.yMMMd().format(report.createdAt),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
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
        );
      case 'false':
        return _VerdictUIStyle(
          bg: const Color(0xFFFEE2E2),
          border: const Color(0xFFFECACA),
          text: const Color(0xFF991B1B),
          label: 'FALSE',
          icon: Icons.dangerous_outlined,
        );
      case 'mixture':
        return _VerdictUIStyle(
          bg: const Color(0xFFFEF3C7),
          border: const Color(0xFFFDE68A),
          text: const Color(0xFF92400E),
          label: 'MIXED',
          icon: Icons.contrast_outlined,
        );
      default:
        return _VerdictUIStyle(
          bg: const Color(0xFFF3F4F6),
          border: const Color(0xFFE5E7EB),
          text: const Color(0xFF374151),
          label: 'UNVERIFIED',
          icon: Icons.help_outline,
        );
    }
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

class _VerdictUIStyle {
  final Color bg;
  final Color border;
  final Color text;
  final String label;
  final IconData icon;

  _VerdictUIStyle({
    required this.bg,
    required this.border,
    required this.text,
    required this.label,
    required this.icon,
  });
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
