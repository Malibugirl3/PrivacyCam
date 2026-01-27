import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';

import '../widgets/evalution_panel.dart';
import '../../core/constants/app_constants.dart';
/// Result Page / 结果页面
///
/// 显示处理后的图片，提供保存和分享功能。
/// Display the protected image with save and share options.

class ResultPage extends StatefulWidget {
  final String originalPath;
  final String protectedPath;
  final double protectionLevel;
  final String? taskId;
  final String serverUrl;

  const ResultPage({
    super.key,
    required this.originalPath,
    required this.protectedPath,
    required this.protectionLevel,
    this.taskId,
    required this.serverUrl,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
  
}

class _ResultPageState extends State<ResultPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('保护完成'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _goHome(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 图片对比区域（改为固定高度）
              SizedBox(
                height: 280,  // 固定高度，替代 Expanded
                child: _buildImageComparison(),
              ),

              // 页面指示器
              _buildPageIndicator(),

              const SizedBox(height: 16),

              // 保护信息
              _buildProtectionInfo(),

              // 评估面板（新增）
              EvaluationPanel(
                taskId: widget.taskId,
                baseUrl: widget.serverUrl,
              ),

              const SizedBox(height: 8),

              // 操作按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildActionButtons(context),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
    /// 构建图片对比区域
  Widget _buildImageComparison() {
    return PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      children: [
        _buildImagePage('原图', widget.originalPath, Icons.image_outlined),
        _buildImagePage('已保护', widget.protectedPath, Icons.shield_outlined),
      ],
    );
  }

  /// 构建单个图片页面
  Widget _buildImagePage(String label, String path, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 图片
          Expanded(
            child: GestureDetector(
              onTap: () => _showFullscreenPreview(_currentPage),  // 新增
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


    /// 构建页面指示器
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(0),
        const SizedBox(width: 8),
        _buildDot(1),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

    /// 构建保护信息
  Widget _buildProtectionInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            '已应用 ${widget.protectionLevel.toInt()}% 保护强度',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

    /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // 保存和分享按钮
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saveImage,
                icon: const Icon(Icons.save_alt),
                label: const Text('保存'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareImage,
                icon: const Icon(Icons.share),
                label: const Text('分享'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 返回首页按钮
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => _goHome(context),
            child: const Text('处理新图片'),
          ),
        ),
      ],
    );
  }

    /// 保存图片
  Future<void> _saveImage() async {
    try {

      // 检查权限
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if(!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if(!granted) {
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('需要相册权限才能保存图片'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }
      // 保存到相册
      // await Gal.saveImage(File(widget.protectedPath));
      await Gal.putImage(widget.protectedPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Text('图片已保存到相册'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 12),
                Text('保存图片失败: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 分享图片
  Future<void> _shareImage() async {
    await Share.shareXFiles(
      [XFile(widget.protectedPath)],
      text: '我用 PrivacyCam 保护了这张照片 🛡️',
    );
  }

  /// 返回首页
  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// 全屏预览图片
  void _showFullscreenPreview(int initialPage) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,  // 背景透明
        barrierColor: Colors.black87,  // 半透明黑色背景
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullscreenImageViewer(
            originalPath: widget.originalPath,
            protectedPath: widget.protectedPath,
            initialPage: initialPage,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}

/// 全屏图片查看器
class _FullscreenImageViewer extends StatefulWidget {
  final String originalPath;
  final String protectedPath;
  final int initialPage;

  const _FullscreenImageViewer({
    required this.originalPath,
    required this.protectedPath,
    required this.initialPage,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),  // 点击关闭
        child: Stack(
          children: [
            // 图片 PageView
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildFullscreenImage(widget.originalPath),
                _buildFullscreenImage(widget.protectedPath),
              ],
            ),

            // 顶部关闭按钮
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),

            // 底部标签和指示器
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // 标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _currentPage == 0 ? '原图' : '已保护',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 指示器
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(0),
                      const SizedBox(width: 8),
                      _buildDot(1),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreenImage(String path) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          File(path),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}