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
    return TaskModel(
      taskId: json['taskId'] as int,
      taskName: json['taskName'] as String,
      taskDesc: json['taskDesc'] as String?,
      taskImage: json['taskImage'] is List
          ? List<String>.from(json['taskImage'])
          : (json['taskImage'] != null ? [json['taskImage'] as String] : []),
      taskScore: json['taskScore'] as int,
      publisherName: json['publisherName'] as String,
      taskStatus: json['taskStatus'] as String,
      creationTime: json['creationTime'] as String,
      completionTime: json['completionTime'] as String?,
      publisherId: json['publisherId'] as String?,
      recipientId: json['recipientId'] as String?,
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
