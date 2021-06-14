import 'package:flutter/material.dart';

class FloatWidget extends StatefulWidget {
  final Widget child;
  final Widget floatChild;
  final FloatWidgetPostion position;
  final double attachToSide;

  FloatWidget({Key key,
    this.position = FloatWidgetPostion.bottomRight,
    @required this.child,
    @required this.floatChild, this.attachToSide})
      : assert(child != null),
        assert(floatChild != null),
        super(key: key);

  @override
  _FloatWidgetState createState() => _FloatWidgetState();
}

class _FloatWidgetState extends State<FloatWidget> {
  GlobalKey<_FloatViewState> _floatViewStateGlobalKey =
  GlobalKey<_FloatViewState>();
  GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0), () {
      _floatViewStateGlobalKey.currentState
          .setMaxSize(_childKey.currentContext.size);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(key: _childKey, child: widget.child),
        _FloatView(
          position: widget.position,
          key: _floatViewStateGlobalKey,
          child: widget.floatChild,
          attachToSide: widget.attachToSide,
        )
      ],
    );
  }
}

class _FloatView extends StatefulWidget {
  final Widget child;
  final FloatWidgetPostion position;
  final double attachToSide;

  _FloatView(
      {Key key, @required this.child, this.position, this.attachToSide})
      : assert(child != null),
        super(key: key);

  @override
  _FloatViewState createState() => _FloatViewState();
}

class _FloatViewState extends State<_FloatView> {
  GlobalKey _containerKey = GlobalKey();
  double left = 0;
  double top = 0;
  Duration duration = Duration(milliseconds: 0);

  double offsetX = 0;
  double offsetY = 0;

  Size maxSize = Size(0, 0);
  DragUpdateDetails updateDetails;

  void setMaxSize(Size size) {
    maxSize = size;

    switch (widget.position) {
      case FloatWidgetPostion.topLeft:
        left = 0;
        top = 0;
        break;
      case FloatWidgetPostion.topRight:
        left = maxSize.width - _containerKey.currentContext.size.width;
        top = 0;
        break;
      case FloatWidgetPostion.bottomLeft:
        left = 0;
        top = maxSize.height - _containerKey.currentContext.size.height;
        break;
      case FloatWidgetPostion.bottomRight:
        left = maxSize.width - _containerKey.currentContext.size.width;
        top = maxSize.height - _containerKey.currentContext.size.height;
        break;
    }
    setState(() {});
  }

  void _onPanDown(DragDownDetails details) {
    offsetX = details.localPosition.dx;
    offsetY = details.localPosition.dy;
  }

  void _updatePosition(DragUpdateDetails details) {
    duration = Duration(milliseconds: 0);
    updateDetails = details;
    left += details.delta.dx;
    top += details.delta.dy;

    if (left < 0) {
      left = 0;
    } else if (left + _containerKey.currentContext.size.width > maxSize.width) {
      left = maxSize.width - _containerKey.currentContext.size.width;
    }

    if (top < 0) {
      top = 0;
    } else if (top + _containerKey.currentContext.size.height >
        maxSize.height) {
      top = maxSize.height - _containerKey.currentContext.size.height;
    }

    setState(() {});
  }

  void _onPanEnd() {
    if (widget.attachToSide==null) return;
      duration = Duration(milliseconds: 100);
    if (left + _containerKey.currentContext.size.width / 2 >=
        maxSize.width / 2) {
      left = maxSize.width - _containerKey.currentContext.size.width-widget.attachToSide;
    } else {
      left = widget.attachToSide;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanDown: _onPanDown,
        onPanUpdate: _updatePosition,
        onPanCancel: _onPanEnd,
        onPanEnd: (details) => _onPanEnd(),
        child: Container(
          key: _containerKey,
          child: widget.child,
        ),
      ),
      duration: duration,
    );
  }
}

enum FloatWidgetPostion {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}
