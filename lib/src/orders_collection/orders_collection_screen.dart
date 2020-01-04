import '../../library.dart';

/// Code for both the orders and collection screen is shared as they are very similar
class OrdersCollectionScreen extends StatelessWidget {
  /// Whether the screen is the collection screen
  final bool isCollection;
  const OrdersCollectionScreen({
    Key key,
    this.isCollection = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int stallId = Provider.of<StallId>(context).value;
    final topPadding = MediaQuery.of(context).padding.top;
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.only(top: topPadding + 96),
          sliver: SliverToBoxAdapter(
            child: Text(
              isCollection ? 'Collection' : 'Orders',
              style: Theme.of(context).textTheme.display3,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(
            bottom: 4,
          ),
          sliver: FirebaseSliverAnimatedList(
            query: FirebaseDatabase.instance
                .reference()
                .child('stallOrders/$stallId'),
            itemBuilder: (context, snapshot, animation, index) {
              return OrderGroupCard(
                key: ValueKey(snapshot.key),
                data: snapshot,
                animation: animation,
                isCollection: isCollection,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A card containing orders at a specific time
class OrderGroupCard extends StatefulWidget {
  final DataSnapshot data;
  final Animation<double> animation;

  /// Whether the screen is the collection screen
  final bool isCollection;
  const OrderGroupCard({
    Key key,
    @required this.data,
    @required this.animation,
    this.isCollection = false,
  }) : super(key: key);

  @override
  _OrderGroupCardState createState() => _OrderGroupCardState();
}

class _OrderGroupCardState extends State<OrderGroupCard> {
  static const duration = Duration(milliseconds: 300);
  FirebaseAnimatedListItemBuilder itemBuilder;
  List<DataSnapshot> _model;
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  bool _loaded = false;
  TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    itemBuilder = (context, snapshot, animation, index) {
      return OrderCard(
        key: ValueKey(snapshot.key),
        time: _time,
        data: snapshot,
        animation: animation,
        isCollection: widget.isCollection,
        last: index == _model.length - 1,
      );
    };
    _time ??= widget.data.key.toTime();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int stallId = Provider.of<StallId>(context).value;
    _model ??= FirebaseList(
      query: FirebaseDatabase.instance
          .reference()
          .child('stallOrders/$stallId/${widget.data.key}/orders')
          .orderByChild('completed')
          .equalTo(widget.isCollection),
      onChildAdded: _onChildAdded,
      onChildRemoved: _onChildRemoved,
      onChildChanged: _onChildChanged,
      onChildMoved: _onChildMoved,
      onValue: _onValue,
    );
  }

  @override
  void dispose() {
    _model.clear();
    super.dispose();
  }

  void _onChildAdded(int index, DataSnapshot snapshot) {
    if (!_loaded) {
      return; // AnimatedList is not created yet
    }
    _animatedListKey.currentState.insertItem(index, duration: duration);
  }

  void _onChildRemoved(int index, DataSnapshot snapshot) {
    // The child should have already been removed from the model by now
    assert(index >= _model.length || _model[index].key != snapshot.key);
    _animatedListKey.currentState.removeItem(
      index,
      (BuildContext context, Animation<double> animation) {
        return itemBuilder(context, snapshot, animation, index);
      },
      duration: duration,
    );
  }

  // No animation, just update contents
  void _onChildChanged(int index, DataSnapshot snapshot) {
    setState(() {});
  }

  // No animation, just update contents
  void _onChildMoved(int fromIndex, int toIndex, DataSnapshot snapshot) {
    setState(() {});
  }

  void _onValue(DataSnapshot _) {
    setState(() {
      _loaded = true;
    });
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return itemBuilder(context, _model[index], animation, index);
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: widget.animation,
      ),
      child: FadeTransition(
        opacity: widget.animation.drive(Tween(
          begin: -1.0,
          end: 1.0,
        )),
        child: DismissibleCard(
          onDismiss: (direction) {
            return OrderSwipeAPI.dismissAllOrdersAtTime(
              context: context,
              direction: direction,
              isCollection: widget.isCollection,
              stallId: Provider.of<StallId>(context),
              time: _time,
            );
          },
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
          backgroundColor: Colors.green,
          backgroundIcon: const Icon(
            Icons.check,
            color: Colors.white,
            size: 28,
          ),
          secondaryBackgroundColor:
              widget.isCollection ? Colors.orange : Colors.red,
          secondaryBackgroundIcon: Icon(
            widget.isCollection ? Icons.undo : Icons.delete,
            color: Colors.white,
            size: 28,
          ),
          builder: (gestureDetector) {
            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  gestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: .4,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _time.format(context),
                            style: Theme.of(context).textTheme.body2,
                          ),
                          Text(
                            _model.length == 0
                                ? 'No orders'
                                : _model.length == 1
                                    ? '1 order'
                                    : '${_model.length} orders',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!_loaded)
                    SizedBox.shrink()
                  else
                    AnimatedList(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      key: _animatedListKey,
                      initialItemCount: _model.length,
                      itemBuilder: _buildItem,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// An individual order
class OrderCard extends StatefulWidget {
  final TimeOfDay time;
  final DataSnapshot data;
  final Animation<double> animation;
  final bool isCollection;
  final bool last;
  const OrderCard({
    Key key,
    @required this.time,
    @required this.data,
    @required this.animation,
    this.isCollection = false,
    this.last = false,
  }) : super(key: key);

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  List<Widget> _generateDishOptions(List<DishOption> options) {
    return options.map((option) {
      return Container(
        padding: const EdgeInsets.fromLTRB(6, 1, 6, 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(69),
            bottomLeft: Radius.circular(69),
            bottomRight: Radius.circular(69),
          ),
          color: Colors.primaries[option.colourCode],
        ),
        child: Text(
          option.name,
          style: Theme.of(context).textTheme.caption.copyWith(
                color:
                    Colors.primaries[option.colourCode].computeLuminance() < .6
                        ? Colors.white
                        : Colors.black87,
              ),
        ),
      );
    }).toList();
  }

  List<Widget> _generateDishes() {
    final stallId = Provider.of<StallId>(context);
    final stallMenuMap = Provider.of<StallMenuMap>(context);
    if (stallMenuMap == null) return [];
    final stallMenu = Provider.of<StallMenuMap>(context).value[stallId].menu;
    final List dishes = widget.data.value['dishes'];
    return dishes.map((dish) {
      final int id = dish['id'];
      final Dish menuDish = stallMenu.firstWhere((menuDish) {
        return menuDish.id == id;
      });
      final List<DishOption> options = dish['options'] != null
          ? (dish['options'] as List).map((optionId) {
              return menuDish.options
                  .firstWhere((option) => optionId == option.id);
            }).toList()
          : [];
      final int quantity = dish['quantity'];
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('$quantity× ${menuDish.name}'),
            if (options.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 5,
                runSpacing: 3,
                children: _generateDishOptions(options),
              ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: widget.animation,
      ),
      child: FadeTransition(
        opacity: widget.animation.drive(Tween(
          begin: -1.0,
          end: 1.0,
        )),
        child: ClipRect(
          child: DismissibleCard(
            onDismiss: (direction) {
              return OrderSwipeAPI.dismissOrder(
                context: context,
                direction: direction,
                isCollection: widget.isCollection,
                stallId: Provider.of<StallId>(context),
                time: widget.time,
                orderId: widget.data.key,
              );
            },
            backgroundColor: Colors.green,
            backgroundIcon: const Icon(
              Icons.check,
              color: Colors.white,
              size: 28,
            ),
            secondaryBackgroundColor:
                widget.isCollection ? Colors.orange : Colors.red,
            secondaryBackgroundIcon: Icon(
              widget.isCollection ? Icons.undo : Icons.delete,
              color: Colors.white,
              size: 28,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: .4,
                  ),
                  bottom: widget.last
                      ? BorderSide.none
                      : BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: .4,
                        ),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '#${widget.data.key}',
                    style: Theme.of(context).textTheme.display1,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _generateDishes(),
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
