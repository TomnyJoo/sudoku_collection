/// 最佳成绩数据模型
class BestScore {

  BestScore({ 
    required this.time,
    required this.mistakes,
    required this.timestamp,
  });

  /// 从JSON字符串创建最佳成绩
  factory BestScore.fromJson(final Map<String, dynamic> json) => BestScore(
        time: json['time'] as int,
        mistakes: json['mistakes'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
  final int time;
  final int mistakes;
  final DateTime timestamp;

  /// 将最佳成绩转换为JSON字符串
  Map<String, dynamic> toJson() => {
        'time': time,
        'mistakes': mistakes,
        'timestamp': timestamp.toIso8601String(),
      };

  /// 创建最佳成绩的副本
  BestScore copyWith({
    int? time,
    int? mistakes,
    DateTime? timestamp,
  }) => BestScore(
        time: time ?? this.time,
        mistakes: mistakes ?? this.mistakes,
        timestamp: timestamp ?? this.timestamp,
      );
}
