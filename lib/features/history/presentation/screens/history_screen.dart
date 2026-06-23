import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truthlens/core/widgets/app_header.dart';
import 'package:truthlens/core/widgets/responsive_layout.dart';
import 'package:truthlens/core/widgets/navigation_sidebar.dart';
import 'package:truthlens/features/history/presentation/providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      drawer: ResponsiveLayout.isMobile(context) ? const NavigationDrawerMobile() : null,
      body: Row(
        children: [
          if (ResponsiveLayout.isTabletDesktop(context)) const NavigationSidebar(),
          Expanded(
            child: Column(
              children: [
                const AppHeader(title: 'Saved Articles'),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.error != null
                          ? Center(child: Text(state.error!))
                          : ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: state.articles.length,
                              itemBuilder: (context, index) {
                                final article = state.articles[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ListTile(
                                    title: Text(article.title),
                                    subtitle: Text('Verdict: ${article.verdict}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        ref.read(historyProvider.notifier).removeArticle(article.id);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
