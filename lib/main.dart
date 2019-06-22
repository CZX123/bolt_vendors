import 'package:flutter/material.dart';

void main() => runApp(BoltApp());

class BoltApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bolt for Vendors',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final items = List<String>.generate(10, (i) => "Item ${i + 1}");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return ClipPath(
            clipBehavior: Clip.antiAlias,
            clipper: ShapeBorderClipper(
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            // TODO: Use Custom Dismissable, current one won't fulfill our needs
            child: Dismissible(
              // Each Dismissible must contain a Key. Keys allow Flutter to
              // uniquely identify widgets.
              key: Key(item),
              // Provide a function that tells the app
              // what to do after an item has been swiped away.
              onDismissed: (direction) {
                // Remove the item from the data source.
                setState(() {
                  items.removeAt(index);
                });
              },
              // Show a red background as the item is swiped away.
              secondaryBackground: ClipPath(
                clipBehavior: Clip.antiAlias,
                clipper: ShapeBorderClipper(
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Container(
                  height: 200,
                  color: Colors.red,
                ),
              ),
              background: ClipPath(
                clipBehavior: Clip.antiAlias,
                clipper: ShapeBorderClipper(
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Container(
                  height: 200,
                  color: Colors.green,
                ),
              ),
              child: Material(
                color: Theme.of(context).cardColor,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                elevation: 8,
                child: Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Text(item),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
