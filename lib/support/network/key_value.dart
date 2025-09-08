class KeyValue<T> {
  String key;
  T value;

  KeyValue(this.key, this.value);

  @override
  String toString() {
    return '$key=$value';
  }

  Map<String, String> toMap() {
    return {key: value.toString()};
  }
}
