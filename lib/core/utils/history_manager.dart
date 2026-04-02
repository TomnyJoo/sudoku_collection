/// 通用游戏历史记录管理器
/// 提供撤销/重做功能，支持状态快照管理
class HistoryManager<T> { /// 是否可以重做 

  /// 构造函数
  HistoryManager({
    required final T Function(T state, List<T> history, int index) copyWith,
    this.maxHistorySize = 100,
  }) : _copyWith = copyWith;

  final List<T> _history = [];  /// 历史记录列表
  int _currentIndex = -1; /// 当前历史索引
  // ignore: unused_field
  final T Function(T state, List<T> history, int index) _copyWith; /// 状态复制函数
  final int maxHistorySize; /// 最大历史记录大小

  int get historyCount => _history.length; /// 获取当前历史记录数量
  int get currentIndex => _currentIndex; /// 获取当前历史索引
  bool get canUndo => _currentIndex > 0; /// 是否可以撤销
  bool get canRedo => _currentIndex < _history.length - 1;

  /// 初始化历史记录
  void initialize(final T initialState) {
    _history.clear();
    _history.add(initialState);
    _currentIndex = 0;
  }

  /// 添加新状态到历史记录
  void addState(final T newState) {
    // 如果当前不是最新状态，删除后面的历史记录
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // 添加新状态
    _history.add(newState);
    _currentIndex = _history.length - 1;

    // 限制历史记录大小
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
      _currentIndex = _history.length - 1;
    }
  }

  /// 撤销操作
  T? undo() {
    if (!canUndo) return null;
    
    _currentIndex--;
    return _history[_currentIndex];
  }

  /// 重做操作
  T? redo() {
    if (!canRedo) return null;
    
    _currentIndex++;
    return _history[_currentIndex];
  }

  /// 获取当前状态
  T get currentState => _history[_currentIndex];

  /// 清空历史记录（保留当前状态）
  void clearHistory() {
    if (_history.isEmpty) return;
    
    final currentState = _history[_currentIndex];
    _history.clear();
    _history.add(currentState);
    _currentIndex = 0;
  }

  /// 获取历史记录信息
  Map<String, dynamic> getHistoryInfo() => {
      'totalStates': _history.length,
      'currentIndex': _currentIndex,
      'canUndo': canUndo,
      'canRedo': canRedo,
      'maxSize': maxHistorySize,
    };

  /// 检查历史记录是否为空
  bool get isEmpty => _history.isEmpty;

  /// 获取历史记录大小
  int get size => _history.length;
}
