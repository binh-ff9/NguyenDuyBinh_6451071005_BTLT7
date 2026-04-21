import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  final NewsService _newsService = NewsService();

  List<News> _newsList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _refreshCount = 0;
  DateTime? _lastRefreshed;

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _loadNews();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final news = await _newsService.fetchNews();
      setState(() {
        _newsList = news;
        _isLoading = false;
        _lastRefreshed = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Gọi lại API khi pull-to-refresh, cập nhật state mới
  Future<void> _onRefresh() async {
    try {
      final news = await _newsService.fetchNews();
      setState(() {
        _newsList = news;
        _refreshCount++;
        _lastRefreshed = DateTime.now();
        _errorMessage = '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Đã tải ${news.length} tin tức mới!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1565C0),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  String _timeAgo() {
    if (_lastRefreshed == null) return '';
    final diff = DateTime.now().difference(_lastRefreshed!);
    if (diff.inSeconds < 60) return 'vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    return '${diff.inHours} giờ trước';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildSkeletonList()
          : _errorMessage.isNotEmpty && _newsList.isEmpty
              ? _buildErrorState()
              : _buildRefreshableList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tin Tức Hôm Nay',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          if (_lastRefreshed != null)
            Text(
              'Cập nhật ${_timeAgo()}${_refreshCount > 0 ? ' · Đã refresh $_refreshCount lần' : ''}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      backgroundColor: const Color(0xFF1565C0),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Làm mới',
          onPressed: _isLoading ? null : _onRefresh,
        ),
      ],
    );
  }

  // RefreshIndicator bao bọc ListView để xử lý pull-to-refresh
  Widget _buildRefreshableList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF1565C0),
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      displacement: 60,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Pull-to-refresh hint banner
          SliverToBoxAdapter(child: _buildHintBanner()),

          // News list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildNewsCard(_newsList[index], index),
                childCount: _newsList.length,
              ),
            ),
          ),

          // Bottom info
          SliverToBoxAdapter(
            child: _buildBottomInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildHintBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.2),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.swipe_down_alt_rounded,
              size: 18, color: Color(0xFF1565C0)),
          SizedBox(width: 10),
          Text(
            'Kéo xuống để refresh dữ liệu',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(News news, int index) {
    // Color palette cho category tags
    final tagColors = [
      const Color(0xFF1565C0),
      const Color(0xFF6A1B9A),
      const Color(0xFF00695C),
      const Color(0xFFE65100),
      const Color(0xFFC62828),
    ];
    final cardColor = tagColors[index % tagColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored header bar
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags
                if (news.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: news.tags
                        .take(3)
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: cardColor,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                const SizedBox(height: 8),

                // Title
                Text(
                  news.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 6),

                // Body preview
                Text(
                  news.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                // Footer
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: cardColor.withOpacity(0.15),
                      child: Text(
                        'U${news.userId}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: cardColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'User ${news.userId}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(Icons.remove_red_eye_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${news.views}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.favorite_border,
                        size: 14, color: Color(0xFFE53935)),
                    const SizedBox(width: 4),
                    Text(
                      '${news.reactions}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Center(
        child: Text(
          '${_newsList.length} bài tin · Kéo xuống để xem thêm',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Skeleton loading (shimmer effect)
  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerValue =
            (_shimmerController.value * 2 - 1).abs(); // 0.0 → 1.0 → 0.0
        final color = Color.lerp(
          Colors.grey[200],
          Colors.grey[100],
          shimmerValue,
        )!;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _shimmerBox(60, 18, color,
                            radius: 8),
                        const SizedBox(width: 8),
                        _shimmerBox(50, 18, color,
                            radius: 8),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _shimmerBox(double.infinity, 16, color),
                    const SizedBox(height: 6),
                    _shimmerBox(double.infinity, 13, color),
                    const SizedBox(height: 4),
                    _shimmerBox(200, 13, color),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _shimmerBox(24, 24, color, radius: 12),
                        const SizedBox(width: 8),
                        _shimmerBox(60, 12, color),
                        const Spacer(),
                        _shimmerBox(40, 12, color),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double width, double height, Color color,
      {double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 72, color: Color(0xFF1565C0)),
            const SizedBox(height: 16),
            const Text(
              'Không tải được tin tức!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
