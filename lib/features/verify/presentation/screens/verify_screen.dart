import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truthlens/core/widgets/responsive_layout.dart';
import 'package:truthlens/core/widgets/app_header.dart';
import 'package:truthlens/core/widgets/navigation_sidebar.dart';
import 'package:truthlens/features/verify/presentation/providers/verify_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _claimController.dispose();
    _urlController.dispose();
    _deepAnalysisController.dispose();
    super.dispose();
  }

  void _verifyClaim() {
    if (_claimController.text.length > 10) {
      ref.read(verifyProvider.notifier).checkClaim(_claimController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Claim must be at least 10 characters')));
    }
  }

  void _verifyUrl() {
    if (_urlController.text.startsWith('http')) {
      ref.read(verifyProvider.notifier).checkUrl(_urlController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid URL')));
    }
  }

  void _deepAnalyze() {
    if (_deepAnalysisController.text.length > 20) {
      ref.read(verifyProvider.notifier).deepAnalyze(_deepAnalysisController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Text must be at least 20 characters')));
    }
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
                const AppHeader(title: 'Dashboard'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
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
                              const SizedBox(height: 32),
                              if (state.isLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (state.error != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Theme.of(context).colorScheme.errorContainer,
                                  child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                )
                              else if (state.result != null)
                                _buildResultCard(state.result!),
                            ],
                          ),
                        ),
                        if (ResponsiveLayout.isTabletDesktop(context)) ...[
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: _buildFeedbackPanel(),
                          ),
                        ]
                      ],
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
        borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }

  Widget _buildForm() {
    return SizedBox(
      height: 200,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildInputTab('Enter a claim to verify...', _claimController, _verifyClaim),
          _buildInputTab('Enter URL to article...', _urlController, _verifyUrl),
          _buildInputTab('Paste full text for deep analysis...', _deepAnalysisController, _deepAnalyze, maxLines: 6),
        ],
      ),
    );
  }

  Widget _buildInputTab(String hint, TextEditingController controller, VoidCallback onSubmit, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(hintText: hint),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onSubmit,
          child: const Text('Analyze'),
        ),
      ],
    );
  }

  Widget _buildResultCard(dynamic result) {
    // Result UI Logic
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Verification Complete', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => context.go('/report/${result.id}'),
                  icon: const Icon(Icons.analytics),
                  label: const Text('Detailed Report'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Verdict: ${result.verdict}', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(result.explanation),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Submit Feedback', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Help us improve accuracy by reporting misclassifications.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            child: const Text('Report Issue'),
          ),
        ],
      ),
    );
  }
}
