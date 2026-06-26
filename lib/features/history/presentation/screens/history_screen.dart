import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:truthlens/core/widgets/app_header.dart';
import 'package:truthlens/core/widgets/responsive_layout.dart';
import 'package:truthlens/core/widgets/navigation_sidebar.dart';
import 'package:truthlens/features/history/presentation/providers/history_provider.dart';
import 'package:truthlens/features/history/data/models/saved_article_model.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _verdictFilter = 'all'; // 'all' | 'true' | 'false' | 'mixture'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditNotesDialog(SavedArticle article) {
    final notesController = TextEditingController(text: article.notes);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Personal Annotation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editing notes for: "${article.title}"',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
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
              onPressed: () async {
                await ref.read(historyProvider.notifier).updateNotes(article.id, notesController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Annotation updated successfully.')),
                  );
                }
              },
              child: const Text('Save Notes'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(SavedArticle article) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Bookmark'),
          content: const Text('Are you sure you want to remove this bookmark?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(historyProvider.notifier).removeArticle(article.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bookmark removed.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);

    // Perform local search and filter
    final filtered = state.articles.where((article) {
      final matchesSearch = article.title.toLowerCase().contains(_searchQuery) ||
          article.notes.toLowerCase().contains(_searchQuery);

      final matchesVerdict = _verdictFilter == 'all' ||
          article.verdict.toLowerCase() == _verdictFilter.toLowerCase();

      return matchesSearch && matchesVerdict;
    }).toList();

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
                  child: state.isLoading && state.articles.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.error != null && state.articles.isEmpty
                          ? Center(child: Text(state.error!))
                          : Column(
                              children: [
                                _buildControlsBar(),
                                Expanded(
                                  child: filtered.isEmpty
                                      ? _buildEmptyState()
                                      : LayoutBuilder(
                                          builder: (context, constraints) {
                                            final crossCount = constraints.maxWidth > 700 ? 2 : 1;
                                            return GridView.builder(
                                              padding: const EdgeInsets.all(24),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossCount,
                                                crossAxisSpacing: 24,
                                                mainAxisSpacing: 24,
                                                mainAxisExtent: 260,
                                              ),
                                              itemCount: filtered.length,
                                              itemBuilder: (context, index) {
                                                final article = filtered[index];
                                                return _buildArticleCard(article);
                                              },
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search saved claims or notes...',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All Bookmarks', Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                _buildFilterChip('true', 'True', const Color(0xFF166534)),
                const SizedBox(width: 8),
                _buildFilterChip('false', 'False', const Color(0xFF991B1B)),
                const SizedBox(width: 8),
                _buildFilterChip('mixture', 'Mixture', const Color(0xFF92400E)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, Color activeColor) {
    final isSelected = _verdictFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _verdictFilter = value;
          });
        }
      },
      selectedColor: activeColor.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? activeColor : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? activeColor : Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No Saved Articles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "You haven't bookmarked any news verifications matching your criteria. Try scanning a claim on the dashboard!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(SavedArticle article) {
    final verdictStyle = _getVerdictStyle(article.verdict);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: verdictStyle.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: verdictStyle.border),
                  ),
                  child: Text(
                    verdictStyle.label,
                    style: TextStyle(color: verdictStyle.text, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(article.savedAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: InkWell(
                onTap: () => context.go('/report/${article.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${article.title}"',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.url,
                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PERSONAL NOTES',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.notes.isNotEmpty ? article.notes : 'No annotations recorded.',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontStyle: article.notes.isEmpty ? FontStyle.italic : FontStyle.normal),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditNotesDialog(article),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit Notes', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(article),
                    icon: Icon(Icons.delete_outline, size: 14, color: Theme.of(context).colorScheme.error),
                    label: Text('Remove', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.error)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
        );
      case 'false':
        return _VerdictUIStyle(
          bg: const Color(0xFFFEE2E2),
          border: const Color(0xFFFECACA),
          text: const Color(0xFF991B1B),
          label: 'FALSE',
        );
      case 'mixture':
        return _VerdictUIStyle(
          bg: const Color(0xFFFEF3C7),
          border: const Color(0xFFFDE68A),
          text: const Color(0xFF92400E),
          label: 'MIXED',
        );
      default:
        return _VerdictUIStyle(
          bg: const Color(0xFFF3F4F6),
          border: const Color(0xFFE5E7EB),
          text: const Color(0xFF374151),
          label: 'UNVERIFIED',
        );
    }
  }
}

class _VerdictUIStyle {
  final Color bg;
  final Color border;
  final Color text;
  final String label;

  _VerdictUIStyle({
    required this.bg,
    required this.border,
    required this.text,
    required this.label,
  });
}
