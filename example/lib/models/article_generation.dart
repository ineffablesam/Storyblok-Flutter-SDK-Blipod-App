class ArticleGeneration {
  final String id;
  final String userId;
  final String articleUrl;
  final String? articleTitle;
  final String status;
  final String detailedStatus;
  final int progressPercentage;
  final int? estimatedTimeRemaining;
  final String? summaryText;
  final String? audioFilePath;
  final String? audioFileUrl;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? startedAt;
  final String? errorStage;
  final DateTime? errorTimestamp;
  final DateTime? failedAt;
  final DateTime? requestFailedAt;
  final String? elevenlabsError;
  final String? replicateError;
  final String? storageError;
  final String? fileName;

  ArticleGeneration({
    required this.id,
    required this.userId,
    required this.articleUrl,
    this.articleTitle,
    required this.status,
    required this.detailedStatus,
    required this.progressPercentage,
    this.estimatedTimeRemaining,
    this.summaryText,
    this.audioFilePath,
    this.audioFileUrl,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.startedAt,
    this.errorStage,
    this.errorTimestamp,
    this.failedAt,
    this.requestFailedAt,
    this.elevenlabsError,
    this.replicateError,
    this.storageError,
    this.fileName,
  });

  factory ArticleGeneration.fromJson(Map<String, dynamic> json) {
    return ArticleGeneration(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      articleUrl: json['article_url'] as String,
      articleTitle: json['article_title'] as String?,
      status: json['status'] as String,
      detailedStatus: json['detailed_status'] as String,
      progressPercentage: json['progress_percentage'] as int,
      estimatedTimeRemaining: json['estimated_time_remaining'] as int?,
      summaryText: json['summary_text'] as String?,
      audioFilePath: json['audio_file_path'] as String?,
      audioFileUrl: json['audio_file_url'] as String?,
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      errorStage: json['error_stage'] as String?,
      errorTimestamp: json['error_timestamp'] != null
          ? DateTime.parse(json['error_timestamp'] as String)
          : null,
      failedAt: json['failed_at'] != null
          ? DateTime.parse(json['failed_at'] as String)
          : null,
      requestFailedAt: json['request_failed_at'] != null
          ? DateTime.parse(json['request_failed_at'] as String)
          : null,
      elevenlabsError: json['elevenlabs_error'] as String?,
      replicateError: json['replicate_error'] as String?,
      storageError: json['storage_error'] as String?,
      fileName: json['file_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'article_url': articleUrl,
      'article_title': articleTitle,
      'status': status,
      'detailed_status': detailedStatus,
      'progress_percentage': progressPercentage,
      'estimated_time_remaining': estimatedTimeRemaining,
      'summary_text': summaryText,
      'audio_file_path': audioFilePath,
      'audio_file_url': audioFileUrl,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'error_stage': errorStage,
      'error_timestamp': errorTimestamp?.toIso8601String(),
      'failed_at': failedAt?.toIso8601String(),
      'request_failed_at': requestFailedAt?.toIso8601String(),
      'elevenlabs_error': elevenlabsError,
      'replicate_error': replicateError,
      'storage_error': storageError,
      'file_name': fileName,
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isGenerating =>
      status == 'generating' || status == 'queued' || status == 'pending';
}
