import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

typedef BackgroundBuilder = Widget Function(BuildContext context,
    Animation<double> animation, double cardWidth, bool isDismissed);

const SpringDescription spring = SpringDescription(
  mass: 0.5,
  stiffness: 100,
  damping: 15.55634918,
);
const Curve kResizeTimeCurve = Interval(0.4, 1.0, curve: Curves.ease);
const double kMinFlingVelocity = 700;

enum DismissDirection { left, right }

typedef DismissCallback = void Function(DismissDirection direction);

class DismissibleCard extends StatefulWidget {
  final Widget child;
  final BackgroundBuilder background;
  final BackgroundBuilder secondaryBackground;
  final Color cardColor;
  final EdgeInsets padding;
  final ShapeBorder shape;
  final double elevation;
  final double highlightElevation;
  final DismissCallback onDismiss;
  DismissibleCard({
    Key key,
    @required this.child,
    @required this.background,
    @required this.secondaryBackground,
    this.cardColor,
    this.onDismiss,
    this.padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
    this.shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24))),
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

  void onDragEnd(DragEndDetails details) {
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
          .then((_) {
        if (widget.onDismiss != null)
          widget.onDismiss(mainController.value > 0.5
              ? DismissDirection.right
              : DismissDirection.left);
        setState(() {
          dismissed = true;
        });
      });
      return;
    }
    if (mainController.value > 0.75 ||
        velocity > kMinFlingVelocity && mainController.value >= 0.5) {
      if (velocity < 400) velocity = 400;
      mainController
          .animateWith(BoundedFrictionSimulation(
              1.5, mainController.value, velocity / windowWidth, 0, 1))
          .then((_) {
        if (widget.onDismiss != null) widget.onDismiss(DismissDirection.right);
        setState(() {
          dismissed = true;
        });
      });
      // setState(() {
      //   dismissed = true;
      // });
    } else if (mainController.value < 0.25 ||
        velocity < -kMinFlingVelocity && mainController.value <= 0.5) {
      if (velocity > -400) velocity = -400;
      mainController
          .animateWith(BoundedFrictionSimulation(
              1.5, mainController.value, velocity / windowWidth, 0, 1))
          .then((_) {
        if (widget.onDismiss != null) widget.onDismiss(DismissDirection.left);
        setState(() {
          dismissed = true;
        });
      });
    } else {
      mainController.animateWith(ScrollSpringSimulation(
          spring, mainController.value, 0.5, velocity / windowWidth));
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
                      widget.padding.left, 0, widget.padding.right, 0)
                  : widget.padding,
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: widget.shape,
                ),
                child: widget.background(
                  context,
                  Tween<double>(begin: -1, end: 1).animate(mainController),
                  cardWidth,
                  dismissed,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: mainController,
            builder: (context, child) {
              return Visibility(
                visible: mainController.value < 0.5,
                child: child,
              );
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
                child: widget.secondaryBackground(
                  context,
                  Tween<double>(begin: 1, end: -1).animate(mainController),
                  cardWidth,
                  dismissed,
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
          child: GestureDetector(
            onHorizontalDragDown: onDragDown,
            onHorizontalDragUpdate: onDragUpdate,
            onHorizontalDragEnd: onDragEnd,
            onHorizontalDragCancel: onDragCancel,
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
                    color: widget.cardColor ?? Theme.of(context).canvasColor,
                    shape: widget.shape,
                    clipBehavior: Clip.antiAlias,
                    child: child,
                  );
                },
                child: AnimatedSize(
                  vsync: this,
                  curve: Curves.easeInOutCubic,
                  duration: Duration(milliseconds: 250),
                  child:
                      dismissed ? SizedBox(width: windowWidth) : widget.child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
