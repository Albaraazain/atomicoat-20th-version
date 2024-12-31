class CircularBuffer<T> {
  final int capacity;
  final List<T?> _buffer;
  int _start = 0;
  int _length = 0;

  CircularBuffer(this.capacity) : _buffer = List<T?>.filled(capacity, null);

  // Fix: Ensure buffer size is accessible
  int get bufferSize => _buffer.length;

  // Fix: Add missing null safety
  void add(T item) {
    if (_length < capacity) {
      _buffer[_length++] = item;
    } else {
      _buffer[_start] = item;
      _start = (_start + 1) % capacity;
    }
  }

  // Fix: Ensure addAll method works correctly
  void addAll(Iterable<T> items) {
    for (var item in items) {
      add(item);
    }
  }

  // Fix: Ensure list conversion preserves order
  List<T> toList() {
    final result = <T>[];
    for (int i = 0; i < _length; i++) {
      final item = _buffer[(_start + i) % capacity];
      if (item != null) result.add(item);
    }
    return result;
  }

  bool get isEmpty => _length == 0;
  bool get isNotEmpty => _length > 0;
  int get length => _length;

  T? operator [](int index) {
    if (index < 0 || index >= _length) return null;
    return _buffer[(_start + index) % capacity];
  }

  void removeAt(int index) {
    if (index < 0 || index >= _length) return;
    final actualIndex = (_start + index) % capacity;
    for (int i = actualIndex; i < _length - 1; i++) {
      _buffer[i % capacity] = _buffer[(i + 1) % capacity];
    }
    _length--;
  }

  T? get first => isEmpty ? null : _buffer[_start];
  T? get last => isEmpty ? null : _buffer[(_start + _length - 1) % capacity];

  Map<int, T> asMap() {
    return Map.fromEntries(
      Iterable.generate(_length, (index) => MapEntry(index, this[index]!)),
    );
  }

  Iterable<R> map<R>(R Function(T) toElement) {
    return Iterable.generate(_length, (index) => toElement(this[index]!));
  }
}
