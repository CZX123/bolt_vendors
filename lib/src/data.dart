import '../library.dart';

class OrderMap extends BetterUnmodifiableMap<DateTime, OrderList> {
  /// Example structure of [orderMapJson]:
  /// ```
  /// {
  ///   "2019-10-12 10:00:00" : { /** See [OrderList] */ },
  ///   "2019-10-12 10:30:00" : { /** See [OrderList] */ },
  /// }
  /// ```
  OrderMap.fromJson(Map<String, dynamic> orderMapJson)
      : super(orderMapJson.map((dateTimeString, orderListJson) {
          return MapEntry(
            DateTime.parse(dateTimeString),
            OrderList.fromJson(orderListJson),
          );
        }));
}

class OrderList extends BetterUnmodifiableList<Order> {
  /// Example structure of [orderListJson]:
  /// ```
  /// {
  ///   101: { /** See [Order] */ },
  ///   102: { /** See [Order] */ }
  /// }
  /// ```
  OrderList.fromJson(Map orderListJson)
      : super(orderListJson.entries.map((entry) {
          final int orderId =
              entry.key is int ? entry.key : int.parse(entry.key);
          return Order.fromJson(orderId, entry.value as Map<String, dynamic>);
        }));
}

class Order {
  final int id;
  final int userId;
  final DishOrderList dishes;

  /// Example structure of [orderJson]:
  /// ```
  /// {
  ///   "userId" : "1",
  ///   "dishes" : [ /** See [DishOrderList] */ ]
  /// }
  /// ```
  Order.fromJson(int orderId, Map<String, dynamic> orderJson)
      : id = orderId,
        userId = orderJson['userId'] is int
            ? orderJson['userId']
            : int.parse(orderJson['userId']),
        dishes = DishOrderList.fromJson(orderJson['dishes'] as List);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final Order typedOther = other;
    return id == typedOther.id &&
        userId == typedOther.userId &&
        dishes == typedOther.dishes;
  }

  @override
  int get hashCode => hashValues(id, userId, hashList(dishes));
}

class DishOrderList extends BetterUnmodifiableList<DishOrder> {
  /// Example structure of [dishOrderListJson]:
  /// ```
  /// [
  ///   {
  ///     "dishID" : 1,
  ///     "options" : [ 0, 1 ],
  ///     "quantity" : 1
  ///   },
  ///   {
  ///     "dishID" : 2,
  ///     "options" : [ 0 ],
  ///     "quantity" : 2
  ///   }
  /// ]
  /// ```
  DishOrderList.fromJson(List dishOrderListJson)
      : super(dishOrderListJson.map((dishOrderJson) {
          return DishOrder.fromJson(dishOrderJson as Map<String, dynamic>);
        }));
}

class DishOrder {
  final int dishId;
  final int quantity;
  final List<int> optionIdList;

  /// Example structure of [dishOrderJson]:
  /// ```
  /// {
  ///   "dishID" : 1,
  ///   "options" : [ 0, 1 ],
  ///   "quantity" : 1
  /// }
  /// ```
  DishOrder.fromJson(Map<String, dynamic> dishOrderJson)
      : dishId = dishOrderJson['dishId'],
        quantity = dishOrderJson['quantity'],
        assert(dishOrderJson['options'] is List),
        optionIdList = dishOrderJson['options'].map((optionId) {
          if (optionId is int) return optionId;
          return int.parse(optionId);
        }).toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final DishOrder typedOther = other;
    return dishId == typedOther.dishId &&
        quantity == typedOther.quantity &&
        listEquals(optionIdList, typedOther.optionIdList);
  }

  @override
  int get hashCode => hashValues(dishId, quantity, hashList(optionIdList));
}
