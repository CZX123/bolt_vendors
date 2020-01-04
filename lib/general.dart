import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A better implementation of [UnmodifiableListView] that uses [listEquals] for its [==] comparisons.
///
/// To use this when creating a new unmodifiable list, instead of calling `List<T> list = List.unmodifiable([...])`, use `List<T> list = BetterUnmodifiableList([...])`.
class BetterUnmodifiableList<T> extends UnmodifiableListView<T> {
  BetterUnmodifiableList(Iterable<T> source) : super(source);

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) return false;
    final BetterUnmodifiableList typedOther = other;
    return listEquals(this, typedOther);
  }

  @override
  int get hashCode => hashList(this);
}

/// A better implementation of [Map] that uses [mapEquals] for its [==] comparisons.
///
/// To use this when creating a new map, instead of calling `Map<K, V> map = {}`, use `Map<K, V> map = BetterMap()`.
class BetterMap<K, V> extends MapView<K, V> {
  const BetterMap([Map<K, V> map]) : super(map ?? const {});

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) return false;
    final BetterMap typedOther = other;
    return mapEquals(this, typedOther);
  }

  @override
  int get hashCode {
    return hashList(entries.map((entry) {
      return hashValues(entry.key, entry.value);
    }));
  }
}

/// A better implementation of [UnmodifiableMapView] that uses [mapEquals] for its [==] comparisons.
///
/// To use this when creating a new unmodifiable map, instead of calling `Map<K, V> map = Map.unmodifiable({...})`, use `Map<K, V> map = BetterUnmodifiableMap({...})`.
class BetterUnmodifiableMap<K, V> extends UnmodifiableMapView<K, V> {
  BetterUnmodifiableMap(Map<K, V> map) : super(map);

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) return false;
    final BetterUnmodifiableMap typedOther = other;
    return mapEquals(this, typedOther);
  }

  @override
  int get hashCode {
    return hashList(entries.map((entry) {
      return hashValues(entry.key, entry.value);
    }));
  }
}

extension TimeOfDayFromNumExtension<T extends num> on T {
  /// Returns a [TimeOfDay] from a number in 12h AM format. E.g. `10.30.am`
  TimeOfDay get am {
    assert(0 <= this && this < 12.60);
    int hour = this.toInt();
    final int minute = ((this - hour) * 100).toInt();
    assert(minute < 60);
    // 12am == 0000h
    if (hour == 12) hour = 0;
    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  /// Returns a [TimeOfDay] from a number in 12h PM format. E.g. `10.30.pm`
  TimeOfDay get pm {
    final amTime = this.am;
    return amTime.replacing(hour: amTime.hour + 12);
  }

  /// Returns a [TimeOfDay] from a number in 24h format. E.g. `1330.h`
  TimeOfDay get h {
    assert(0 <= this && this < 23.60);
    final int hour = this ~/ 100;
    final int minute = (this - hour * 100).toInt();
    assert(minute < 60);
    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }
}

extension TypeConversionExtension on String {
  int toInt() {
    return int.parse(this);
  }

  double toDouble() {
    return double.parse(this);
  }

  num toNum() {
    return num.parse(this);
  }

  /// Returns a [TimeOfDay] from a string in 24h format, with hours and minutes separated by a colon. E.g. `10:30`, `15:45`
  TimeOfDay toTime() {
    final hoursAndMinutes = this.split(':');
    assert(hoursAndMinutes.length == 2, 'Invalid time string: $this');
    return TimeOfDay(
      hour: hoursAndMinutes.first.toInt(),
      minute: hoursAndMinutes.last.toInt(),
    );
  }
}

extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get windowSize => MediaQuery.of(this).size;
  EdgeInsets get windowPadding => MediaQuery.of(this).padding;
  EdgeInsets get windowInsets => MediaQuery.of(this).viewInsets;
}
