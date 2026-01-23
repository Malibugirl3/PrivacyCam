import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'settings_page.dart';
import 'preview_page.dart';
/// Home Page / 首页
/// 
/// The main entry point of the app where users can:
/// - Take a photo with camera
/// - Select a photo from gallery
/// 
/// 应用的主入口，用户可以：
/// - 使用相机拍照
/// - 从相册选择照片

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 原有内容
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  _buildHeader(context),
                  const Spacer(flex: 1),
                  _buildActionButtons(context),
                  const Spacer(flex: 2),
                  _buildFooter(context),
                ],
              ),
            ),
            
            // 右上角设置按钮
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
                tooltip: '设置',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build header section with logo and title
  /// 构建头部区域（Logo 和标题）
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Shield Icon / 盾牌图标
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_outlined,
            size: 60,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // App Name / 应用名称
        Text(
          'PrivacyCam',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle / 副标题
        Text(
          '朋友圈隐形衣',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Description / 描述
        Text(
          '为你的照片添加 AI 防护\n让隐私更安全',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Build action buttons for camera and gallery
  /// 构建相机和相册按钮
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Camera Button / 相机按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('拍摄照片'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Gallery Button / 相册按钮
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('从相册选择'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build footer with version info
  /// 构建底部版本信息
  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '对抗扰动技术保护',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'v1.0.0',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  /// Pick image from camera or gallery
  /// 从相机或相册选取图片
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      
      if (image != null) {
        // 跳转到预览页面
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewPage(imagePath: image.path),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

