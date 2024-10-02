// Model to represent the item structure
class ProductSelectModal {
  final String text;
  final int id;

  ProductSelectModal({required this.text, required this.id});

  // Method to create an Item from JSON
  factory ProductSelectModal.fromJson(Map<String, dynamic> json) {
    return ProductSelectModal(
      text: json['text'],
      id: json['id'],
    );
  }

  @override
  String toString() =>
      text; // This ensures that the text field is displayed in the dropdown
}
