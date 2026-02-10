import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/constants/app_constants.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/shared/widgets/config_dialog.dart';

/// 调试面板对话框
/// 连点登录页锦书爱心 5 次后显示，用于排查打包后无法连接云阁等问题
class DebugPanelDialog extends StatefulWidget {
  final String currentBaseUrl;
  final VoidCallback onUrlUpdated;

  const DebugPanelDialog({
    super.key,
    required this.currentBaseUrl,
    required this.onUrlUpdated,
  });

  @override
  State<DebugPanelDialog> createState() => _DebugPanelDialogState();
}

class _DebugPanelDialogState extends State<DebugPanelDialog> {
  String _connectionStatus = '';
  bool _isTesting = false;
  bool _trustSslForCurrentHost = false;
  bool _trustSslLoaded = false;

  String get _buildMode {
    if (kReleaseMode) return 'Release（正式包）';
    if (kProfileMode) return 'Profile';
    return 'Debug（调试包）';
  }

  Future<void> _loadTrustSsl() async {
    if (_trustSslLoaded) return;
    final host = AppConfig.hostFromUrl(widget.currentBaseUrl);
    if (host == null) return;
    final saved = await AppConfig.getInsecureSslHost();
    if (mounted) {
      setState(() {
        _trustSslLoaded = true;
        _trustSslForCurrentHost = saved == host;
      });
    }
  }

  Future<void> _toggleTrustSsl(bool value) async {
    final host = AppConfig.hostFromUrl(widget.currentBaseUrl);
    if (host == null) return;
    setState(() => _trustSslForCurrentHost = value);
    if (value) {
      await AppConfig.setInsecureSslHost(host);
      await ApiService().setInsecureSslHost(host);
    } else {
      await AppConfig.setInsecureSslHost(null);
      await ApiService().setInsecureSslHost(null);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value ? '已信任此云阁证书，可重试登入' : '已关闭信任此云阁证书')),
      );
    }
  }

  Future<void> _testConnection() async {
    final baseUrl = widget.currentBaseUrl.trim();
    if (baseUrl.isEmpty) {
      setState(() => _connectionStatus = '请先配置云阁地址');
      return;
    }
    if (!AppConfig.isValidUrl(baseUrl)) {
      setState(() => _connectionStatus = '云阁地址格式无效');
      return;
    }

    setState(() {
      _isTesting = true;
      _connectionStatus = '正在连接…';
    });

    try {
      final url = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      final uri = Uri.parse(url);
      final dio = Dio(BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 5),
      ));
      // 测试时对该 host 放宽证书校验，以排除“浏览器能开、App 报证书错误”的情况
      final testHost = uri.host;
      final adapter = IOHttpClientAdapter();
      adapter.onHttpClientCreate = (client) {
        client.badCertificateCallback = (_, String host, __) => host == testHost;
        return client;
      };
      dio.httpClientAdapter = adapter;

      final path = '${AppConstants.apiBasePath}/common';
      final response = await dio.get(path);
      if (response.statusCode == 200) {
        setState(() => _connectionStatus = '连接成功');
      } else {
        setState(() => _connectionStatus = '云阁返回: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String msg = '连接失败';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        msg = '连接超时，请检查地址与网络';
      } else if (e.type == DioExceptionType.connectionError) {
        msg = '无法连接。若浏览器能打开而 App 不能，多为证书校验：请开启下方「信任此云阁证书」后重试';
      } else {
        msg = '${e.type}: ${e.message ?? ""}';
      }
      setState(() => _connectionStatus = msg);
    } catch (e) {
      setState(() => _connectionStatus = '异常: $e');
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  void _openConfigDialog() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (ctx) => ConfigDialog(
        initialUrl: widget.currentBaseUrl,
        onSave: (url) async {
          await AppConfig.setBaseUrl(url);
          await ApiService().updateBaseUrl(url);
          widget.onUrlUpdated();
          if (ctx.mounted) {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('云阁已更新，可再次测试连接')),
            );
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTrustSsl());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasHost = AppConfig.hostFromUrl(widget.currentBaseUrl) != null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.bug_report_rounded, size: 24, color: colorScheme.primary),
          const SizedBox(width: 10),
          const Text('调试'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(theme: theme, colorScheme: colorScheme, title: '构建模式'),
            Text(
              _buildMode,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (kReleaseMode) ...[
              const SizedBox(height: 8),
              Text(
                '正式包首次安装时未保存过云阁地址，会使用默认地址。若你的云阁为自建或内网，请在此配置后重试登入。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 20),
            _SectionTitle(theme: theme, colorScheme: colorScheme, title: '云阁地址'),
            Text(
              widget.currentBaseUrl.isEmpty ? '未配置' : widget.currentBaseUrl,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _openConfigDialog,
                  icon: Icon(Icons.edit_rounded, size: 18, color: colorScheme.primary),
                  label: const Text('配置云阁'),
                  style: OutlinedButton.styleFrom(foregroundColor: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Icon(Icons.wifi_find_rounded, size: 18, color: colorScheme.onPrimary),
                  label: Text(_isTesting ? '连接中…' : '测试连接'),
                ),
              ],
            ),
            if (hasHost) ...[
              const SizedBox(height: 16),
              _SectionTitle(theme: theme, colorScheme: colorScheme, title: '证书校验'),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '信任此云阁证书（不校验 SSL）',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Switch(
                    value: _trustSslForCurrentHost,
                    onChanged: _toggleTrustSsl,
                  ),
                ],
              ),
              Text(
                '若浏览器能打开默认地址而 App 连不上，多为证书校验差异，开启后即可连接。仅对当前云阁域名生效。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (_connectionStatus.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _connectionStatus == '连接成功' ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      size: 20,
                      color: _connectionStatus == '连接成功' ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _connectionStatus,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.theme,
    required this.colorScheme,
    required this.title,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
