import 'package:flutter/material.dart';

/// 确认对话框组件
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '确定',
    String cancelText = '取消',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            onCancel?.call();
            Navigator.of(context).pop(false);
          },
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop(true);
          },
          style: TextButton.styleFrom(
            foregroundColor: confirmColor ?? Colors.red,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
