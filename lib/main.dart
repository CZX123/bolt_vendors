import 'library.dart';

void main() => runApp(BoltApp());

class BoltApp extends StatefulWidget {
  @override
  _BoltAppState createState() => _BoltAppState();
}

class _BoltAppState extends State<BoltApp> {
  final _themeNotifier = ThemeNotifier();

  Stream<StallMenuMap> _stallMenuStream;
  void _initStallMenuStream() {
    _stallMenuStream = FirebaseDatabase.instance
        .reference()
        .child('stallMenu')
        .onValue
        .map<StallMenuMap>((event) {
      if (event == null) return null;
      Map map;
      try {
        map = Map.from(event.snapshot.value);
      } catch (e) {
        map = List.from(event.snapshot.value).asMap();
      }
      Map<StallId, StallMenu> stallMenus = {};
      map.forEach((key, value) {
        final id = StallId(key is int ? key : int.tryParse(key));
        if (id.value != null) {
          stallMenus[id] = StallMenu.fromJson(id, value);
        }
      });
      return StallMenuMap(stallMenus);
    });
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Get theme preference from SharedPreferences when first initialising HomeState, and set accordingly
    SharedPreferences.getInstance().then((prefs) {
      _themeNotifier.isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
    _initStallMenuStream();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: _themeNotifier,
        ),
        // Stream of stall menus
        StreamProvider.value(
          value: _stallMenuStream,
        ),
        Provider.value(
          value: StallId(0),
        ),
        // Stream of stall balance
        StreamProvider.value(
          initialData: StallBalance(0),
          value: FirebaseDatabase.instance
              .reference()
              .child('stalin')
              .child('0')
              .child('balance')
              .onValue
              .map((event) {
            if (event?.snapshot?.value == null) return StallBalance(0);
            return StallBalance(event.snapshot.value);
          }),
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'Bolt for Vendors',
            theme: themeNotifier.currentThemeData,
            home: Home(),
          );
        },
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _isCollection = ValueNotifier(false);
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void dispose() {
    _isCollection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: AccountPage(),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isCollection,
        builder: (context, value, child) {
          return AnimatedSwitcher(
            transitionBuilder: (child, animation) {
              final opacity = animation.drive(Tween(
                begin: -1.0,
                end: 1.0,
              ));
              final position = CurvedAnimation(
                curve: Curves.fastOutSlowIn,
                parent: animation,
              ).drive(Tween(
                begin: Offset(0, 64),
                end: Offset.zero,
              ));
              return FadeTransition(
                opacity: opacity,
                child: ValueListenableBuilder<double>(
                  valueListenable: animation,
                  builder: (context, value, child) {
                    Offset offset = position.value;
                    if (animation.status == AnimationStatus.reverse) {
                      offset *= -1.0;
                    }
                    return Transform.translate(
                      offset: offset,
                      child: child,
                    );
                  },
                  child: child,
                ),
              );
            },
            duration: const Duration(milliseconds: 300),
            child: OrdersCollectionScreen(
              key: ValueKey(value),
              isCollection: value,
            ),
          );
        },
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: kElevationToShadow[4],
        ),
        child: BottomAppBar(
          elevation: 0,
          color: Theme.of(context).canvasColor,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
              SizedBox(
                width: (width - 192 - 40 * 2) / 2,
              ),
              SizedBox(
                width: 192,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isCollection,
                  builder: (context, value, child) {
                    return BottomNavigationBar(
                      currentIndex: value ? 1 : 0,
                      backgroundColor: Theme.of(context).canvasColor,
                      fixedColor: Theme.of(context).primaryColorDark,
                      elevation: 0,
                      items: [
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.restaurant),
                          title: const Text('Orders'),
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.room_service),
                          title: const Text('Collection'),
                        ),
                      ],
                      onTap: (index) {
                        _isCollection.value = index == 1;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
