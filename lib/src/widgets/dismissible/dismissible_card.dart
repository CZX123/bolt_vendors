import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

const SpringDescription spring = SpringDescription(
  mass: 0.5,
  stiffness: 100,
  damping: 15.55634918,
);
const Curve kResizeTimeCurve = Interval(0.4, 1.0, curve: Curves.ease);
const double kMinDismissVelocity = 700;

typedef DismissCallback = Future<DismissAction> Function(
    DismissDirection direction);

enum DismissAction {
  /// Collapses the card
  remove,

  /// Does not collapse the card, nor abort the dismissal. The card will just stay in its "semi-dismissed" state. Used in orders page as FirebaseAnimatedList will automatically collapse the card.
  stay,

  /// Aborts the dismissal. Card will go back to its original place.
  abort,
}

class DismissibleCard extends StatefulWidget {
  final Widget child;
  final Widget Function(Widget Function({@required Widget child})) builder;
  //final BackgroundBuilder background;
  //final BackgroundBuilder secondaryBackground;
  final Color backgroundColor;
  final Icon backgroundIcon;
  final Color secondaryBackgroundColor;
  final Icon secondaryBackgroundIcon;
  final Color cardColor;
  final EdgeInsets padding;
  final ShapeBorder shape;
  final double elevation;
  final double highlightElevation;
  final DismissCallback onDismiss;
  const DismissibleCard({
    Key key,
    this.child,
    this.builder,
    @required this.backgroundColor,
    @required this.backgroundIcon,
    @required this.secondaryBackgroundColor,
    @required this.secondaryBackgroundIcon,
    this.cardColor,
    @required this.onDismiss,
    this.padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
    this.shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.elevation: 2,
    this.highlightElevation: 6,
  }) : super(key: key);

  _DismissibleCardState createState() => _DismissibleCardState();
}

class _DismissibleCardState extends State<DismissibleCard>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  ValueNotifier<bool> cardPressed = ValueNotifier(false);
  bool dismissed = false;
  double windowWidth;
  double cardWidth; // windowWidth - horizontal padding
  AnimationController mainController;

  void onDragDown(DragDownDetails details) {
    mainController.value = mainController.value;
    cardPressed.value = true;
  }

  void onDragUpdate(DragUpdateDetails details) {
    mainController.value += details.primaryDelta / windowWidth / 2;
  }

  void onDragEnd(DragEndDetails details) async {
    cardPressed.value = false;
    double velocity = details.primaryVelocity;
    if (velocity == 0 &&
        (mainController.value < 0.25 || mainController.value > 0.75)) {
      mainController
          .animateTo(
            mainController.value > 0.5 ? 1 : 0,
            duration: Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn.flipped,
          )
          .then(onAnimEnd);
      return;
    }
    if (mainController.value > 0.75 ||
        velocity > kMinDismissVelocity && mainController.value >= 0.5) {
      if (velocity < 400) velocity = 400;
      mainController
          .animateWith(BoundedFrictionSimulation(
              1.5, mainController.value, velocity / windowWidth, 0, 1))
          .then(onAnimEnd);
      // setState(() {
      //   dismissed = true;
      // });
    } else if (mainController.value < 0.25 ||
        velocity < -kMinDismissVelocity && mainController.value <= 0.5) {
      if (velocity > -400) velocity = -400;
      mainController
          .animateWith(BoundedFrictionSimulation(
              1.5, mainController.value, velocity / windowWidth, 0, 1))
          .then(onAnimEnd);
    } else {
      mainController.animateWith(ScrollSpringSimulation(
          spring, mainController.value, 0.5, velocity / windowWidth));
    }
  }

  void onAnimEnd(_) async {
    final dismissAction = await widget.onDismiss(mainController.value > 0.5
        ? DismissDirection.startToEnd
        : DismissDirection.endToStart);
    switch (dismissAction) {
      case DismissAction.remove:
        setState(() {
          dismissed = true;
        });
        break;
      case DismissAction.abort:
        mainController.animateTo(
          0.5,
          duration: Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
        );
        break;
      case DismissAction.stay:
        break;
    }
  }

  void onDragCancel() {
    cardPressed.value = false;
    mainController.animateTo(
      0.5,
      duration: Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    mainController = AnimationController(
      value:
          0.5, // 0 means dismissed to the left, 1 means dismissed to the right
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    windowWidth = MediaQuery.of(context).size.width;
    cardWidth = windowWidth - widget.padding.horizontal;
  }

  @override
  void dispose() {
    super.dispose();
    mainController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Animation<double> animation = Tween<double>(
      begin: -1,
      end: 1,
    ).animate(mainController);
    final Animation<Offset> iconOffset = Tween<Offset>(
      begin: Offset(-.5, 0),
      end: Offset(0, 0),
    ).animate(animation);
    final Animation<Offset> secondaryIconOffset = Tween<Offset>(
      begin: Offset(.5, 0),
      end: Offset(1, 0),
    ).animate(animation);
    final Animation<double> iconOpacity = Tween<double>(
      begin: -1,
      end: 9,
    ).animate(animation);
    final Animation<double> secondaryIconOpacity = Tween<double>(
      begin: -1,
      end: -11,
    ).animate(animation);
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: AnimatedBuilder(
            animation: mainController,
            builder: (context, child) {
              if (mainController.value <= 0.5) return SizedBox.shrink();
              return child;
            },
            child: AnimatedPadding(
              curve: Curves.easeInOutCubic,
              duration: Duration(milliseconds: 250),
              padding: dismissed
                  ? EdgeInsets.fromLTRB(
                      widget.padding.left,
                      0,
                      widget.padding.right,
                      0,
                    )
                  : widget.padding,
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: widget.shape,
                ),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    Container(
                      color: widget.backgroundColor,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SlideTransition(
                        position: iconOffset,
                        child: FadeTransition(
                          opacity: iconOpacity,
                          child: Container(
                            width: cardWidth,
                            alignment: Alignment.center,
                            child: AnimatedOpacity(
                              opacity: dismissed ? 0 : 1,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.ease,
                              child: widget.backgroundIcon,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: mainController,
            builder: (context, child) {
              if (mainController.value >= 0.5) return SizedBox.shrink();
              return child;
            },
            child: AnimatedPadding(
              curve: Curves.easeInOutCubic,
              duration: Duration(milliseconds: 250),
              padding: dismissed
                  ? EdgeInsets.fromLTRB(
                      widget.padding.left, 0, widget.padding.right, 0)
                  : widget.padding,
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: widget.shape,
                ),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    Container(
                      color: widget.secondaryBackgroundColor,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SlideTransition(
                        position: secondaryIconOffset,
                        child: FadeTransition(
                          opacity: secondaryIconOpacity,
                          child: Container(
                            width: cardWidth,
                            alignment: Alignment.center,
                            child: AnimatedOpacity(
                              opacity: dismissed ? 0 : 1,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.ease,
                              child: widget.secondaryBackgroundIcon,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedPadding(
          curve: Curves.easeInOutCubic,
          duration: Duration(milliseconds: 250),
          padding: dismissed
              ? EdgeInsets.fromLTRB(
                  widget.padding.left, 0, widget.padding.right, 0)
              : widget.padding,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: Offset(-windowWidth / cardWidth, 0),
                    end: Offset(windowWidth / cardWidth, 0))
                .animate(mainController),
            child: ValueListenableBuilder(
              valueListenable: cardPressed,
              builder: (context, cardPressed, child) {
                return Material(
                  elevation: cardPressed
                      ? widget.highlightElevation
                      : widget.elevation,
                  color: widget.cardColor ?? Theme.of(context).cardColor,
                  shape: widget.shape,
                  clipBehavior: Clip.antiAlias,
                  child: child,
                );
              },
              child: AnimatedSize(
                vsync: this,
                curve: Curves.easeInOutCubic,
                duration: Duration(milliseconds: 250),
                child: dismissed
                    ? SizedBox(width: windowWidth)
                    : widget.builder != null
                        ? widget.builder(gestureDetector)
                        : gestureDetector(child: widget.child),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget gestureDetector({@required Widget child}) {
    return GestureDetector(
      onHorizontalDragDown: onDragDown,
      onHorizontalDragUpdate: onDragUpdate,
      onHorizontalDragEnd: onDragEnd,
      onHorizontalDragCancel: onDragCancel,
      child: child,
    );
  }
}
