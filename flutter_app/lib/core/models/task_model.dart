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

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final taskImage = json['taskImage'];
    final recordList = taskImage is List
        ? List<String>.from(taskImage.map((e) => e?.toString() ?? ''))
        : (taskImage != null ? [taskImage.toString()] : <String>[]);
    return TaskModel(
      taskId: json['taskId'] as int? ?? 0,
      taskName: json['taskName'] as String? ?? '',
      taskDesc: json['taskDesc'] as String?,
      taskImage: recordList,
      taskScore: json['taskScore'] as int? ?? 0,
      publisherName: json['publisherName'] as String? ?? json['publisherEmail'] as String? ?? '',
      taskStatus: json['taskStatus'] as String? ?? '未开始',
      creationTime: json['creationTime'] != null ? json['creationTime'].toString() : '',
      completionTime: json['completionTime'] != null ? json['completionTime'].toString() : null,
      publisherId: json['publisherId'] as String? ?? json['publisherEmail'] as String?,
      recipientId: json['recipientId'] as String? ?? json['receiverEmail'] as String?,
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
  final int totalPages;

  TaskListResponse({
    required this.record,
    required this.totalPages,
  });

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    final recordRaw = json['record'];
    final record = recordRaw is List
        ? (recordRaw)
            .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
            .toList()
        : <TaskModel>[];
    return TaskListResponse(
      record: record,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}
