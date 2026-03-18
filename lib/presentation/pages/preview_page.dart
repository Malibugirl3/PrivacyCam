import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/protect_manager.dart';
import '../../domain/models/portrait_risk_result.dart';
import '../../infrastructure/cloud/cloud_protect_impl.dart';
import '../../infrastructure/local/local_portrait_risk_service.dart';
import '../../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'result_page.dart';

class PreviewPage extends ConsumerStatefulWidget {
  const PreviewPage({super.key, required this.imagePath});

  final String imagePath;

  @override
  ConsumerState<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends ConsumerState<PreviewPage> {
  late final ProtectManager _protectManager;
  late final LocalPortraitRiskService _portraitRiskService;

  double _protectionLevel = 50;
  bool _isProcessing = false;

  bool _isRiskLoading = true;
  String? _riskError;
  PortraitRiskResult? _riskResult;

  @override
  void initState() {
    super.initState();
    _protectManager = ProtectManager();
    _portraitRiskService = LocalPortraitRiskService();
    _runPortraitRiskScan();
  }

  @override
  void dispose() {
    unawaited(_portraitRiskService.dispose());
    super.dispose();
  }

  Future<void> _runPortraitRiskScan() async {
    setState(() {
      _isRiskLoading = true;
      _riskError = null;
    });

    try {
      final result = await _portraitRiskService.analyze(widget.imagePath);
      if (!mounted) return;
      setState(() {
        _riskResult = result;
        _isRiskLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _riskError = AppLocalizations.of(context).faceScanFailed(e.toString());
        _isRiskLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).previewTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(flex: 3, child: _buildImagePreview()),
              const SizedBox(height: 16),
              _buildPortraitRiskCard(),
              const SizedBox(height: 16),
              _buildProtectionSelector(),
              const SizedBox(height: 20),
              _buildProtectButton(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

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
        child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildPortraitRiskCard() {
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _isRiskLoading
          ? Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Expanded(child: Text(t.scanningPortraitRisk)),
              ],
            )
          : _riskError != null
              ? Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_riskError!)),
                    IconButton(
                      tooltip: t.retry,
                      onPressed: _runPortraitRiskScan,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                )
              : _buildRiskContent(),
    );
  }

  Widget _buildRiskContent() {
    final t = AppLocalizations.of(context);
    final risk = _riskResult;
    if (risk == null) return Text(t.noRiskResult);

    final color = _riskColor(risk.level);
    final label = _riskLabel(risk.level);
    final recommendationText = switch (risk.level) {
      PortraitRiskLevel.low => t.recommendationLow,
      PortraitRiskLevel.medium => t.recommendationMedium,
      PortraitRiskLevel.high => t.recommendationHigh,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.face_retouching_natural, color: color),
            const SizedBox(width: 8),
            Text(
              t.portraitRiskTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '$label - ${risk.score}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          risk.faceCount == 0
              ? t.noClearFaceSummary
              : t.detectedFacesSummary(risk.faceCount),
        ),
        const SizedBox(height: 4),
        Text(
          t.facesDetected(risk.faceCount),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          t.recommendationPrefix(recommendationText),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildProtectionSelector() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.protectionStrength,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _getLevelColor(),
            inactiveTrackColor: _getLevelColor().withOpacity(0.2),
            thumbColor: _getLevelColor(),
            overlayColor: _getLevelColor().withOpacity(0.1),
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
        ),
        Text(
          _getLevelDescription(),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

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
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                AppLocalizations.of(context).startProtection,
                style: const TextStyle(fontSize: 18),
              ),
      ),
    );
  }

  Future<void> _startProtection() async {
    setState(() {
      _isProcessing = true;
    });

    final settings = ref.read(settingsProvider);
    if (settings.useCloud) {
      _protectManager.setCloudService(
        CloudProtectImpl(baseUrl: settings.serverUrl),
      );
    }

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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            originalPath: widget.imagePath,
            protectedPath: result.protectedImagePath!,
            protectionLevel: _protectionLevel,
            taskId: result.taskId,
            serverUrl: settings.serverUrl,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? AppLocalizations.of(context).processingFailed,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _getLevelColor() {
    if (_protectionLevel < 30) return Colors.green;
    if (_protectionLevel < 70) return Colors.orange;
    return Colors.red;
  }

  String _getLevelDescription() {
    final t = AppLocalizations.of(context);
    if (_protectionLevel == 0) return t.protectionLevelDescriptionNone;
    if (_protectionLevel < 30) return t.protectionLevelDescriptionLight;
    if (_protectionLevel < 70) return t.protectionLevelDescriptionBalanced;
    if (_protectionLevel < 100) return t.protectionLevelDescriptionStrong;
    return t.protectionLevelDescriptionMax;
  }

  Color _riskColor(PortraitRiskLevel level) {
    switch (level) {
      case PortraitRiskLevel.low:
        return Colors.green;
      case PortraitRiskLevel.medium:
        return Colors.orange;
      case PortraitRiskLevel.high:
        return Colors.red;
    }
  }

  String _riskLabel(PortraitRiskLevel level) {
    final t = AppLocalizations.of(context);
    switch (level) {
      case PortraitRiskLevel.low:
        return t.riskLevelLow;
      case PortraitRiskLevel.medium:
        return t.riskLevelMedium;
      case PortraitRiskLevel.high:
        return t.riskLevelHigh;
    }
  }
}
