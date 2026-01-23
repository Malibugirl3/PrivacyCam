import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isTesting = false;      // 是否正在测试连接
  String? _testResult;          // 测试结果消息（可为空）

  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 延迟到 build 后读取 Provider（因为 initState 时 ref 还没准备好）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _urlController.text = ref.read(settingsProvider).serverUrl;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // 从 Provider 读取设置
    final settings = ref.watch(settingsProvider);
    final useCloud = settings.useCloud;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 处理模式
          _buildModeSection(),
          
          const SizedBox(height: 24),
          
          // 服务器配置（仅云端模式显示）
          if (useCloud) _buildServerSection(),
          
          const SizedBox(height: 24),
          
          // 关于信息
          _buildAboutSection(),
        ],
      ),
    );
  }

    /// 构建处理模式区域
  Widget _buildModeSection() {
    final settings = ref.watch(settingsProvider);
    final useCloud = settings.useCloud;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '处理模式',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // 模式选择
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('云端处理'),
                  icon: Icon(Icons.cloud_outlined),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('本地处理'),
                  icon: Icon(Icons.phone_android_outlined),
                ),
              ],
              selected: {useCloud},
              onSelectionChanged: (value) {
                ref.read(settingsProvider.notifier).setUseCloud(value.first);
                setState(() {
                  _testResult = null;
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            // 模式说明
            Text(
              useCloud 
                  ? '使用云端服务器处理图片，效果更好，需要网络连接。'
                  : '使用本地算法处理图片，无需网络，速度更快。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

    /// 构建服务器配置区域
  Widget _buildServerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '服务器配置',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // 服务器地址输入
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: '服务器地址',
                hintText: 'http://192.168.1.100:5000',
                prefixIcon: const Icon(Icons.link),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveServerUrl,
                  tooltip: '保存',
                ),
              ),
              keyboardType: TextInputType.url,
              onSubmitted: (_) => _saveServerUrl(),
            ),
            
            const SizedBox(height: 16),
            
            // 测试连接按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_find),
                label: Text(_isTesting ? '测试中...' : '测试连接'),
              ),
            ),
            
            // 测试结果
            if (_testResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testResult!.startsWith('✓')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testResult!.startsWith('✓') 
                          ? Icons.check_circle 
                          : Icons.error,
                      color: _testResult!.startsWith('✓') 
                          ? Colors.green 
                          : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_testResult!)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

    /// 构建关于区域
  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '关于',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('版本'),
              trailing: const Text('1.0.0'),
              contentPadding: EdgeInsets.zero,
            ),
            
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('PrivacyCam'),
              subtitle: const Text('朋友圈隐形衣 - 保护你的照片隐私'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// 保存服务器地址
  void _saveServerUrl() {
    ref.read(settingsProvider.notifier).setServerUrl(_urlController.text.trim());
    setState(() {
      _testResult = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('服务器地址已保存'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // TODO: 使用 Riverpod 保存到全局状态
  }

  /// 测试服务器连接
  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      
      final response = await dio.get('${_urlController.text.trim()}/health');
      
      if (response.statusCode == 200) {
        setState(() {
          _testResult = '✓ 连接成功！服务器运行正常';
        });
      } else {
        setState(() {
          _testResult = '✗ 服务器响应异常: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '✗ 连接失败: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

}