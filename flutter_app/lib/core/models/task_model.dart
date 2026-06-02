/// 任务模型
class TaskModel {
  final int taskId;
  final String taskName;
  final String? taskDesc;
  final List<String> taskImage;
  final int taskScore;
  final String publisherName;
  final String taskStatus;
  final String creationTime;
  final String? completionTime;
  final String? publisherId;
  final String? recipientId;

  TaskModel({
    required this.taskId,
    required this.taskName,
    this.taskDesc,
    required this.taskImage,
    required this.taskScore,
    required this.publisherName,
    required this.taskStatus,
    required this.creationTime,
    this.completionTime,
    this.publisherId,
    this.recipientId,
  });

  static int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final taskImage = json['taskImage'];
    final recordList = taskImage is List
        ? taskImage
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
        : (taskImage != null && taskImage.toString().isNotEmpty
              ? taskImage
                    .toString()
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList()
              : <String>[]);
    return TaskModel(
      taskId: _asInt(json['taskId']),
      taskName: _asNullableString(json['taskName']) ?? '',
      taskDesc: _asNullableString(json['taskDesc']),
      taskImage: recordList,
      taskScore: _asInt(json['taskScore']),
      publisherName:
          _asNullableString(json['publisherName']) ??
          _asNullableString(json['publisherEmail']) ??
          '',
      taskStatus: _asNullableString(json['taskStatus']) ?? 'pending',
      creationTime: json['creationTime']?.toString() ?? '',
      completionTime: json['completionTime']?.toString(),
      publisherId:
          _asNullableString(json['publisherId']) ??
          _asNullableString(json['publisherEmail']),
      recipientId:
          _asNullableString(json['recipientId']) ??
          _asNullableString(json['receiverEmail']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'taskName': taskName,
      'taskDesc': taskDesc,
      'taskImage': taskImage,
      'taskScore': taskScore,
      'publisherName': publisherName,
      'taskStatus': taskStatus,
      'creationTime': creationTime,
      'completionTime': completionTime,
      'publisherId': publisherId,
      'recipientId': recipientId,
    };
  }
}

/// 任务列表响应
class TaskListResponse {
  final List<TaskModel> record;
  final int total;
  final int pageSize;
  final int totalPages;
  final int current;

  TaskListResponse({
    required this.record,
    this.total = 0,
    this.pageSize = 0,
    required this.totalPages,
    this.current = 1,
  });

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    final recordRaw = json['record'];
    final record = recordRaw is List
        ? (recordRaw)
              .whereType<Map>()
              .map(
                (item) => TaskModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <TaskModel>[];
    return TaskListResponse(
      record: record,
      total: TaskModel._asInt(json['total'], record.length),
      pageSize: TaskModel._asInt(json['pageSize'], record.length),
      totalPages: TaskModel._asInt(json['totalPages']),
      current: TaskModel._asInt(json['current'], 1),
    );
  }
}
