abstract class IndexEnum<T> {
  final int value;
  final String string;
  const IndexEnum(this.value, this.string);

  static T fromIdx<T extends IndexEnum>(List<T> values, int idx) {
    try{
      return values.firstWhere((element) => element.value == idx, orElse: () => values[-1]);
    } catch (e) {
      throw Exception('Invalid index for enum conversion');
    }
  }
}
