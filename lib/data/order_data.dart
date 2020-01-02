class Order {
  final int id;
  final DateTime dateTime;
  final int studentId;
  final int stallId;
  final List<Dish> dishList;
  final double totalCost;
  Order({this.id, this.dateTime, this.studentId, this.stallId, this.dishList, this.totalCost});
}

class Dish {
  final String name;
  final String image;
  final int quantity;
  final double unitCost;
  final List<DishOption> options;
  final double totalCost;
  Dish({this.name, this.image, this.quantity, this.unitCost, this.options, this.totalCost});
}

class DishOption {
  final String name;
  final String addCost;
  final int colourCode;
  DishOption({this.name, this.addCost, this.colourCode});
}
