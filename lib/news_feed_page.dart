import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart';
import '../services/news_service.dart';
import 'webview_page.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({super.key});

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  List<Article> _articles = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    try {
      final articles = await NewsService.fetchTeslaNews();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('d MMM y').format(date);
  }

  Future<bool> _isArticleBookmarked(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('bookmarks') ?? [];
    final jsonStr = jsonEncode(article.toJson());
    return existing.contains(jsonStr);
  }

  Future<void> _toggleBookmark(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('bookmarks') ?? [];
    final jsonStr = jsonEncode(article.toJson());

    if (existing.contains(jsonStr)) {
      existing.remove(jsonStr);
      await prefs.setStringList('bookmarks', existing);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bookmark removed")),
        );
      }
    } else {
      existing.add(jsonStr);
      await prefs.setStringList('bookmarks', existing);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Article bookmarked")),
        );
      }
    }
    setState(() {}); // Refresh the UI to update bookmark icons
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final filteredArticles = _articles
        .where((a) => a.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Material(
                elevation: isDark ? 0 : 4,
                borderRadius: BorderRadius.circular(12),
                color: isDark ? Colors.grey[900] : Colors.white,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search articles...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),

            // News List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: _loadNews,
                child: filteredArticles.isEmpty
                    ? const Center(child: Text("No articles found"))
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WebViewPage(url: article.url),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? const LinearGradient(
                            colors: [Colors.deepPurple, Colors.black],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : const LinearGradient(
                            colors: [Colors.white, Colors.deepPurpleAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDark
                              ? []
                              : [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image with fallback
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              child: Image.network(
                                article.urlToImage,
                                height: size.height * 0.25,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: size.height * 0.25,
                                    color: Colors.black,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: size.height * 0.25,
                                    color: Colors.grey[700],
                                    child: const Center(
                                      child: Icon(Icons.broken_image,
                                          size: 60, color: Colors.white),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                      isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    article.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${article.source} • ${formatDate(article.publishedAt)}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: isDark
                                                ? Colors.white60
                                                : Colors.black54,
                                          ),
                                        ),
                                      ),
                                      FutureBuilder<bool>(
                                        future: _isArticleBookmarked(article),
                                        builder: (context, snapshot) {
                                          final isBookmarked = snapshot.data ?? false;
                                          return IconButton(
                                            icon: Icon(
                                              isBookmarked
                                                  ? Icons.bookmark
                                                  : Icons.bookmark_add_outlined,
                                              color: isBookmarked
                                                  ? Colors.amber
                                                  : (isDark
                                                  ? Colors.white
                                                  : Colors.deepPurple),
                                            ),
                                            onPressed: () => _toggleBookmark(article),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}