/// A model class used to represent a selectable item.
class MultiSelectItem<V> {
  const MultiSelectItem(this.value, this.label, this.imageUrl, this.initials, this.companyName, this.jobTitle);

  final V value;
  final String label;
  final String imageUrl;
  final String initials;
  final String companyName;
  final String jobTitle;
}
