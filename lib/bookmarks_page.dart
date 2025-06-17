import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart';
import 'webview_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Article> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('bookmarks') ?? [];

    setState(() {
      _bookmarks =
          stored.map((jsonStr) => Article.fromJson(json.decode(jsonStr))).toList();
      _isLoading = false;
    });
  }

  Future<void> _removeBookmark(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final removedArticle = _bookmarks.removeAt(index);
    final updated = _bookmarks.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('bookmarks', updated);
    setState(() {});

    // Show snackbar with Undo
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Bookmark removed"),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () async {
              _bookmarks.insert(index, removedArticle);
              final restored = _bookmarks.map((a) => jsonEncode(a.toJson())).toList();
              await prefs.setStringList('bookmarks', restored);
              setState(() {});
            },
          ),
        ),
      );
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('d MMMM, y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarked Articles"),
        backgroundColor: isDark ? Colors.grey[900] : Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookmarks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border,
                size: 80, color: isDark ? Colors.white38 : Colors.grey),
            const SizedBox(height: 12),
            Text(
              "No bookmarks added yet.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadBookmarks,
        child: ListView.builder(
          itemCount: _bookmarks.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final article = _bookmarks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: isDark ? 0 : 4,
              color: isDark ? Colors.grey[850] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WebViewPage(url: article.url),
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: article.urlToImage.isNotEmpty
                          ? Image.network(
                        article.urlToImage,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 110,
                            height: 110,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image,
                                size: 40, color: Colors.grey),
                          );
                        },
                      )
                          : Container(
                        width: 110,
                        height: 110,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${article.source} • ${formatDate(article.publishedAt)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.white60
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.redAccent,
                      onPressed: () => _removeBookmark(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}