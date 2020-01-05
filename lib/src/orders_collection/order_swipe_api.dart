import '../../library.dart';

/// Used when swiping orders
class OrderSwipeAPI {
  static final _rejectOrder = CloudFunctions.instance.getHttpsCallable(
    functionName: 'rejectOrder',
  );
  static final _completeOrder = CloudFunctions.instance.getHttpsCallable(
    functionName: 'completeOrder',
  );
  static final _undoCompleteOrder = CloudFunctions.instance.getHttpsCallable(
    functionName: 'undoCompleteOrder',
  );
  static final _removeOrder = CloudFunctions.instance.getHttpsCallable(
    functionName: 'removeOrder',
  );
  static final _rejectOrdersAtTime = CloudFunctions.instance.getHttpsCallable(
    functionName: 'rejectOrdersAtTime',
  );
  static final _completeOrdersAtTime = CloudFunctions.instance.getHttpsCallable(
    functionName: 'completeOrdersAtTime',
  );
  static final _undoCompleteOrdersAtTime = CloudFunctions.instance.getHttpsCallable(
    functionName: 'undoCompleteOrdersAtTime',
  );
  static final _removeOrdersAtTime = CloudFunctions.instance.getHttpsCallable(
    functionName: 'removeOrdersAtTime',
  );

  static String _formatTime(TimeOfDay time) {
    String _addLeadingZeroIfNeeded(int value) {
      if (value < 10) return '0$value';
      return value.toString();
    }

    final String hourLabel = _addLeadingZeroIfNeeded(time.hour);
    final String minuteLabel = _addLeadingZeroIfNeeded(time.minute);
    return '$hourLabel:$minuteLabel';
  }

  static Future<bool> _showRejectionDialog({
    @required BuildContext context,
    TimeOfDay time,
    String orderId,
  }) {
    assert(time != null || orderId != null);
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(time != null
              ? 'Reject all orders at ${time.format(context)}?'
              : 'Reject order $orderId?'),
          actions: <Widget>[
            FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<DismissAction> dismissOrder({
    @required BuildContext context,
    @required DismissDirection direction,
    bool isCollection = false,
    @required StallId stallId,
    @required TimeOfDay time,
    @required String orderId,
  }) async {
    final Map<String, dynamic> data = {
      'stallId': stallId.value,
      'time': _formatTime(time),
      'orderId': orderId,
    };
    HttpsCallableResult result;
    if (!isCollection) {
      if (direction == DismissDirection.endToStart) {
        final rejection = await _showRejectionDialog(
          context: context,
          orderId: orderId,
        );
        if (rejection == null || !rejection) {
          return DismissAction.abort;
        }
        result = await _rejectOrder.call(data);
      } else {
        result = await _completeOrder.call(data);
      }
    } else if (direction == DismissDirection.endToStart) {
      result = await _undoCompleteOrder.call(data);
    } else {
      result = await _removeOrder.call(data);
    }
    if (result.data['success']) {
      return DismissAction.stay;
    } else {
      return DismissAction.abort;
    }
  }

  static Future<DismissAction> dismissAllOrdersAtTime({
    @required BuildContext context,
    @required DismissDirection direction,
    bool isCollection = false,
    @required StallId stallId,
    @required TimeOfDay time,
  }) async {
    final Map<String, dynamic> data = {
      'stallId': stallId.value,
      'time': _formatTime(time),
    };
    HttpsCallableResult result;
    if (!isCollection) {
      if (direction == DismissDirection.endToStart) {
        final rejection = await _showRejectionDialog(
          context: context,
          time: time,
        );
        if (rejection == null || !rejection) {
          return DismissAction.abort;
        }
        result = await _rejectOrdersAtTime.call(data);
      } else {
        result = await _completeOrdersAtTime.call(data);
      }
    } else if (direction == DismissDirection.endToStart) {
      result = await _undoCompleteOrdersAtTime.call(data);
    } else {
      result = await _removeOrdersAtTime.call(data);
    }
    return DismissAction.abort;
  }
}
