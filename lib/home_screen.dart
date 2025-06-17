import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'news_feed_page.dart';
import 'bookmarks_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFabPressed() {
    if (_tabController.index == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add new post')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add to bookmarks')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color background = isDark ? const Color(0xFF121212) : Colors.grey.shade100;
    final Color appBarColor = isDark ? Colors.black : Colors.deepPurple;
    final Color selectedTabColor = Colors.white;
    final Color unselectedTabColor = isDark ? Colors.grey : Colors.white70;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Newsify',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: appBarColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white24,
              ),
              labelColor: selectedTabColor,
              unselectedLabelColor: unselectedTabColor,
              tabs: const [
                Tab(icon: Icon(Icons.article), text: 'News'),
                Tab(icon: Icon(Icons.bookmark), text: 'Bookmarks'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const _LoadingShimmer()
          : TabBarView(
        controller: _tabController,
        children: const [
          NewsFeedPage(),
          BookmarksPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text("Action"),
        elevation: 4,
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
