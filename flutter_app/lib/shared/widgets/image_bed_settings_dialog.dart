import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/models/image_bed_model.dart';
import 'package:romance_hub_flutter/core/services/config_service.dart';
import 'package:romance_hub_flutter/core/utils/snackbar_utils.dart';

/// 图床设置弹框：列表 + 添加图床，与良人共用
class ImageBedSettingsDialog extends StatefulWidget {
  const ImageBedSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const ImageBedSettingsDialog(),
    );
  }

  @override
  State<ImageBedSettingsDialog> createState() => _ImageBedSettingsDialogState();
}

class _ImageBedSettingsDialogState extends State<ImageBedSettingsDialog> {
  final ConfigService _configService = ConfigService();
  List<ImageBedModel> _imageBeds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImageBeds();
  }

  Future<void> _loadImageBeds() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final res = await _configService.getImageBeds();
    if (!mounted) return;
    setState(() {
      _imageBeds = res.data ?? [];
      _loading = false;
    });
  }

  Future<void> _showAddImageBedDialog() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nameCtrl = TextEditingController();
    final apiUrlCtrl = TextEditingController(text: 'https://api.imgbb.com/1/upload');
    final apiKeyCtrl = TextEditingController();
    String bedType = 'imgbb';
    bool isDefault = _imageBeds.isEmpty;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('添加图床'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: '图床名称',
                        hintText: '如：IMGBB',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: bedType,
                      decoration: const InputDecoration(
                        labelText: '图床类型',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'imgbb', child: Text('imgBB')),
                        DropdownMenuItem(value: 'smms', child: Text('SM.MS')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() {
                            bedType = v;
                            apiUrlCtrl.text = v == 'imgbb'
                                ? 'https://api.imgbb.com/1/upload'
                                : 'https://sm.ms/api/v2/upload';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: apiUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'API 地址',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: apiKeyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        hintText: '必填',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: isDefault,
                          onChanged: (v) => setDialogState(() => isDefault = v ?? false),
                          activeColor: colorScheme.primary,
                        ),
                        GestureDetector(
                          onTap: () => setDialogState(() => isDefault = !isDefault),
                          child: Text('设为默认（与良人共用）', style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () async {
                    final bedName = nameCtrl.text.trim();
                    final apiUrl = apiUrlCtrl.text.trim();
                    final apiKey = apiKeyCtrl.text.trim();
                    if (bedName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写图床名称')),
                      );
                      return;
                    }
                    if (apiUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写 API 地址')),
                      );
                      return;
                    }
                    if (apiKey.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写 API Key')),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    final res = await _configService.updateImageBed(
                      bedName: bedName,
                      bedType: bedType,
                      apiUrl: apiUrl,
                      apiKey: apiKey,
                      isDefault: isDefault,
                    );
                    if (!mounted) return;
                    if (res.isSuccess) {
                      SnackBarUtils.showSuccess(context, '图床已保存，与良人共用');
                      _loadImageBeds();
                    } else {
                      SnackBarUtils.showError(context, res.msg);
                    }
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget content;
    if (_loading) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
          ),
        ),
      );
    } else {
      content = SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '与良人共用。上传时由后端决定使用此处配置或服务端兜底。',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (_imageBeds.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '暂无图床，请添加并设为默认。',
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ] else ...[
              const SizedBox(height: 12),
              ..._imageBeds.map((bed) => ListTile(
                dense: true,
                leading: Icon(Icons.cloud_rounded, color: colorScheme.primary, size: 22),
                title: Text(bed.bedName, style: theme.textTheme.bodyMedium),
                subtitle: Text(
                  '${bed.bedType} · ${bed.apiUrl}${bed.isDefault ? " · 默认" : ""}',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _showAddImageBedDialog,
              icon: Icon(Icons.add_rounded, size: 20, color: colorScheme.primary),
              label: Text('添加图床', style: TextStyle(color: colorScheme.primary)),
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text('图床设置'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 420),
        child: content,
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
