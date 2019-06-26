import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
import 'src/widgets/animated_fade.dart';
import 'src/widgets/dismissible_card.dart';
import 'theme.dart';

void main() => runApp(BoltApp());

class BoltApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: ThemeNotifier(),
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
  EdgeInsets windowPadding;

  @override
  void initState() {
    super.initState();
    // Get theme preference from SharedPreferences when first initialising HomeState, and set accordingly
    SharedPreferences.getInstance().then((prefs) {
      Provider.of<ThemeNotifier>(context).isDarkMode =
          prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Combines both padding and viewInsets, since on Android the bottom padding due to navigation bar is actually in the viewInsets, not the padding
    windowPadding =
        MediaQuery.of(context).padding + MediaQuery.of(context).viewInsets;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<EdgeInsets>.value(
      value: windowPadding,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: Drawer(
          child: SettingsPage(),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 8 + windowPadding.top,
            ),
            DismissibleCard(
              key: UniqueKey(),
              onDismiss: (direction) {
                print(direction);
              },
              background: (context, animation, cardWidth, isDismissed) {
                Animation<Offset> offset = Tween<Offset>(
                  begin: Offset(-0.5, 0),
                  end: Offset(0, 0),
                ).animate(animation);
                Animation<double> opacity = CurvedAnimation(
                  parent: animation,
                  curve: Interval(0.1, 0.2),
                );
                return Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    Container(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.greenAccent.withOpacity(0.3)
                          : Colors.green,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SlideTransition(
                        position: offset,
                        child: FadeTransition(
                          opacity: opacity,
                          child: Container(
                            width: cardWidth,
                            alignment: Alignment.center,
                            child: AnimatedFade(
                              opacity: isDismissed ? 0 : 1,
                              child: Icon(
                                Icons.check,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              secondaryBackground:
                  (context, animation, cardWidth, isDismissed) {
                Animation<Offset> offset = Tween<Offset>(
                  begin: Offset(0.5, 0),
                  end: Offset(0, 0),
                ).animate(animation);
                Animation<double> opacity = CurvedAnimation(
                  parent: animation,
                  curve: Interval(0.1, 0.2),
                );
                return Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    Container(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.pink.withOpacity(0.3)
                          : Colors.red,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SlideTransition(
                        position: offset,
                        child: FadeTransition(
                          opacity: opacity,
                          child: Container(
                            width: cardWidth,
                            alignment: Alignment.center,
                            child: AnimatedFade(
                              opacity: isDismissed ? 0 : 1,
                              child: Icon(
                                Icons.delete,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              child: Container(
                height: 200,
                alignment: Alignment.center,
                child: Text('Hello World!'),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Center(
              child: RaisedButton(
                child: Text('Reset'),
                onPressed: () {
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        // body: ListView.builder(
        //   itemCount: items.length,
        //   itemBuilder: (context, index) {
        //     final item = items[index];

        //     return ClipPath(
        //       clipBehavior: Clip.antiAlias,
        //       clipper: ShapeBorderClipper(
        //         shape: ContinuousRectangleBorder(
        //           borderRadius: BorderRadius.circular(24),
        //         ),
        //       ),
        //       // TODO: Use Custom Dismissable, current one won't fulfill our needs
        //       child: Dismissible(
        //         // Each Dismissible must contain a Key. Keys allow Flutter to
        //         // uniquely identify widgets.
        //         key: Key(item),
        //         // Provide a function that tells the app
        //         // what to do after an item has been swiped away.
        //         onDismissed: (direction) {
        //           // Remove the item from the data source.
        //           setState(() {
        //             items.removeAt(index);
        //           });
        //         },
        //         // Show a red background as the item is swiped away.
        //         secondaryBackground: ClipPath(
        //           clipBehavior: Clip.antiAlias,
        //           clipper: ShapeBorderClipper(
        //             shape: ContinuousRectangleBorder(
        //               borderRadius: BorderRadius.circular(24),
        //             ),
        //           ),
        //           child: Container(
        //             height: 200,
        //             color: Colors.red,
        //           ),
        //         ),
        //         background: ClipPath(
        //           clipBehavior: Clip.antiAlias,
        //           clipper: ShapeBorderClipper(
        //             shape: ContinuousRectangleBorder(
        //               borderRadius: BorderRadius.circular(24),
        //             ),
        //           ),
        //           child: Container(
        //             height: 200,
        //             color: Colors.green,
        //           ),
        //         ),
        //         child: Material(
        //           color: Theme.of(context).cardColor,
        //           shape: ContinuousRectangleBorder(
        //             borderRadius: BorderRadius.circular(24),
        //           ),
        //           clipBehavior: Clip.antiAlias,
        //           elevation: 8,
        //           child: Container(
        //             height: 200,
        //             alignment: Alignment.center,
        //             child: Text(item),
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }
}
