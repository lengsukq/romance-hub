import 'dart:convert';

import 'package:http/http.dart' as http;

/// 情话接口：酷酷 API 土味情话
/// 文档 https://api.zxki.cn/doc/twqh.html
const String _sweetTalkApiUrl = 'https://api.zxki.cn/api/twqh';

/// 情话服务：每次请求返回一句情话（纯文本或 JSON 中的文案）
class SweetTalkService {
  SweetTalkService._();
  static final SweetTalkService instance = SweetTalkService._();

  /// 获取一句情话。失败时返回 null，调用方可显示默认文案或隐藏。
  Future<String?> fetchOne() async {
    try {
      final response = await http
          .get(Uri.parse(_sweetTalkApiUrl))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final body = response.body.trim();
      if (body.isEmpty) return null;
      // 兼容：接口可能返回纯文本或 JSON（如 {"data":"..."}）
      if (body.startsWith('{')) {
        final map = jsonDecode(body) as Map<String, dynamic>?;
        if (map == null) return body;
        final text = map['data'] ?? map['content'] ?? map['msg'] ?? map['text'];
        return text?.toString();
      }
      return body;
    } catch (_) {
      return null;
    }
  }
}
