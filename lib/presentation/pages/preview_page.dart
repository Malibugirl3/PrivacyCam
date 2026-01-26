import 'dart:io';
import 'package:flutter/material.dart';   /// 导入 Flutter 材料组件库, 实现 Material Design 风格，以及以下几种功能
                                          /// 1. 状态管理: 使用 StatefulWidget 管理页面状态
                                          /// 2. 图片显示: 使用 Image.file 显示用户选择的图片
                                          /// 3. 保护等级选择: 使用三个按钮提供低/中/高三个保护等级选择
                                          /// 4. 开始保护: 使用按钮触发保护过程
import 'package:flutter/services.dart';   /// 用于 HapticFeedback
import 'package:audioplayers/audioplayers.dart';  /// 用于播放音频
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

import 'result_page.dart';

/// 导入保护结果模型和本地保护实现
import '../../application/protect_manager.dart';
import '../../infrastructure/cloud/cloud_protect_impl.dart';

/// Preview Page / 预览页面
/// 
/// 显示用户选择的图片，并提供保护等级选择。
/// Display the selected image and provide protection level options.

class PreviewPage extends ConsumerStatefulWidget {
  final String imagePath;

  const PreviewPage({super.key, required this.imagePath});

  @override
  ConsumerState<PreviewPage> createState() => _PreviewPageState();

}

class _PreviewPageState extends ConsumerState<PreviewPage> {
  /// 保护强度：0-100
  double _protectionLevel = 50;  // 默认 50%

  /// 是否正在处理
  bool _isProcessing = false;

  /// 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// 初始化音频播放器
  @override
  void dispose() {
    _audioPlayer.dispose();  // 释放资源
    super.dispose();
  }
  
    /// 播放滑动音效
  Future<void> _playTickSound() async {
    await _audioPlayer.play(AssetSource('sounds/tick.mp3'), volume: 0.3);
  }

  /// 保护服务实例
  late final ProtectManager _protectManager;

  @override
  void initState() {
    super.initState();
    _protectManager = ProtectManager();
    
    // // 注入云端服务（使用你的电脑 IP）
    // _protectManager.setCloudService(
    //   // CloudProtectImpl(baseUrl: 'http://10.138.58.77:5000'),
    // );
    /// 从 Provider 读取设置, 改到 _startProtection() 中动态设置
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片预览'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 图片预览区域
              Expanded(
                flex: 3,
                child: _buildImagePreview(),
              ),

              const SizedBox(height: 16),

              // 保护等级选择
              _buildProtectionSelector(),

              const SizedBox(height: 24),

              // 开始保护按钮
              _buildProtectButton(),

              const SizedBox(height: 16),
            ],
          ),  /// 返回 Column 组件，包含图片预览区域、保护等级选择、开始保护按钮
        ),  /// 返回 Padding 组件，包含 Column 组件，包含图片预览区域、保护等级选择、开始保护按钮
      ),  /// 返回 SafeArea 组件，包含 Padding 组件，包含 Column 组件，包含图片预览区域、保护等级选择、开始保护按钮
    ); /// 返回 Scaffold 组件，包含 AppBar 和 Body 内容
  }


  /// 构建保护强度选择器（滑动条）
  /// Build the protection strength selector (slider)
  /// 
  /// 构建保护强度选择器（滑动条），包含标题、当前值、滑动条、刻度标签、描述文字。
  /// Build the protection strength selector (slider), including title, current value, slider, scale labels, and description text.
  /// 
  /// 参数：[context] 上下文
  Widget _buildProtectionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和当前值
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '保护强度',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),  // 添加动画
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getLevelColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_protectionLevel.toInt()}%',
                style: TextStyle(
                  color: _getLevelColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // 滑动条
        TweenAnimationBuilder<Color?>(
          tween: ColorTween(
            begin: _getLevelColor(),
            end: _getLevelColor(),
          ),
          duration: const Duration(milliseconds: 200),
          builder: (context, color, child) {
            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: color?.withOpacity(0.2),
                thumbColor: color,
                overlayColor: color?.withOpacity(0.1),
                trackHeight: 8,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              ),
              child: Slider(
                value: _protectionLevel,
                min: 0,
                max: 100,
                onChanged: (value) {
                  if ((value - _protectionLevel).abs() >= 5) {
                    HapticFeedback.selectionClick();
                  }
                  setState(() {
                    _protectionLevel = value;
                  });
                },
              ),
            );
          },
        ),
        
        // 刻度标签
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text('50%', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text('100%', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // 描述文字
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _getLevelDescription(),
            key: ValueKey(_getLevelDescription()),  // 重要：让 Flutter 知道内容变了
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  /// 根据强度获取颜色
  Color _getLevelColor() {
    if (_protectionLevel < 30) {
      return Colors.green;
    } else if (_protectionLevel < 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }


  /// 获取等级说明文字
  String _getLevelDescription() {
    if (_protectionLevel == 0) {
      return '无保护，原图效果';
    } else if (_protectionLevel < 30) {
      return '轻微扰动，几乎不影响画质，基础防护';
    } else if (_protectionLevel < 70) {
      return '中等扰动，平衡画质与防护效果';
    } else if (_protectionLevel < 100) {
      return '强力扰动，高防护，可能轻微影响画质';
    } else {
      return '最强保护，最高防护等级';
    }
  }

    /// 构建开始保护按钮
  Widget _buildProtectButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _startProtection,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '开始保护',
                style: TextStyle(fontSize: 18),
              ),
      ),
    );
  }

  /// 构建图片预览区域
  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }


  /// 开始保护处理
  Future<void> _startProtection() async {
    setState(() {
      _isProcessing = true;
    });

    /// 从 Provider 读取设置, 动态设置保护管理器
    final settings = ref.read(settingsProvider);

    if(settings.useCloud) {
      _protectManager.setCloudService(
        CloudProtectImpl(baseUrl: settings.serverUrl),
      );
    }

    // 调用保护服务
    final result = await _protectManager.protect(
      imagePath: widget.imagePath,
      protectionLevel: _protectionLevel,
      preferCloud: settings.useCloud,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (result.success) {
      // 成功 - 跳转到结果页
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            originalPath: widget.imagePath,
            protectedPath: result.protectedImagePath!,
            protectionLevel: _protectionLevel,
            taskId: result.taskId,
          ),
        ),
      );
    } else {
      // 失败 - 显示错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? '处理失败'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}