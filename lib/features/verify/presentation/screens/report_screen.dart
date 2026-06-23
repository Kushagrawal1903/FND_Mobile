import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truthlens/core/widgets/app_header.dart';
import 'package:truthlens/core/widgets/responsive_layout.dart';
import 'package:truthlens/core/widgets/navigation_sidebar.dart';
import 'package:truthlens/features/verify/presentation/providers/verify_provider.dart';

class ReportScreen extends ConsumerWidget {
  final String reportId;

  const ReportScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verifyProvider);
    final result = state.result;

    return Scaffold(
      drawer: ResponsiveLayout.isMobile(context) ? const NavigationDrawerMobile() : null,
      body: Row(
        children: [
          if (ResponsiveLayout.isTabletDesktop(context)) const NavigationSidebar(),
          Expanded(
            child: Column(
              children: [
                const AppHeader(title: 'Detailed Report'),
                Expanded(
                  child: result == null
                      ? const Center(child: Text('No report found.'))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                onPressed: () => context.go('/'),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Back to Dashboard'),
                              ),
                              const SizedBox(height: 24),
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Verdict', style: Theme.of(context).textTheme.labelLarge),
                                            Text(
                                              result.verdict.toUpperCase(),
                                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                                color: _getVerdictColor(context, result.verdict),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(result.explanation),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 32),
                                      SizedBox(
                                        width: 120,
                                        height: 120,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CircularProgressIndicator(
                                              value: result.confidence / 100,
                                              strokeWidth: 12,
                                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                              color: _getVerdictColor(context, result.verdict),
                                            ),
                                            Center(
                                              child: Text(
                                                '${result.confidence}%',
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text('Sources Evaluated', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 16),
                              ...result.sources.map((source) => ListTile(
                                title: Text(source.publisher),
                                subtitle: Text(source.url),
                                trailing: Text(source.verdict),
                              )),
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

  Color _getVerdictColor(BuildContext context, String verdict) {
    if (verdict.toLowerCase() == 'true') return Theme.of(context).colorScheme.tertiary;
    if (verdict.toLowerCase() == 'false') return Theme.of(context).colorScheme.error;
    return Theme.of(context).colorScheme.primary;
  }
}
