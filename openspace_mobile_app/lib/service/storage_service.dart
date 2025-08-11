import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:openspace_mobile_app/model/openspace.dart';
import 'package:openspace_mobile_app/model/Report.dart';
import 'package:openspace_mobile_app/model/Booking.dart';

class StorageService {
  final box = Hive.box('appData');



  List<OpenSpaceMarker> getCachedOpenSpaces() {
    final spaces = box.get('openSpaces', defaultValue: []) as List<dynamic>;
    return spaces.map((s) => OpenSpaceMarker.fromJson(Map<String, dynamic>.from(s))).toList();
  }



  List<Report> getCachedReports() {
    final reports = box.get('reports', defaultValue: []) as List<dynamic>;
    return reports.map((r) => Report.fromJson(Map<String, dynamic>.from(r))).toList();
  }

  // Cache bookings
  Future<void> cacheBookings(List<Booking> bookings) async {
    await box.put('bookings', bookings.map((b) => b.toJson()).toList());
  }

  List<Booking> getCachedBookings() {
    final bookings = box.get('bookings', defaultValue: []) as List<dynamic>;
    return bookings.map((b) => Booking.fromJson(Map<String, dynamic>.from(b))).toList();
  }

  // Queue actions (reports or bookings)
  Future<void> queueAction(String type, Map<String, dynamic> payload) async {
    final action = {
      'id': Uuid().v4(),
      'type': type,
      'payload': payload,
      'timestamp': DateTime.now().toIso8601String(),
    };
    final actions = List<Map>.from(box.get('queuedActions', defaultValue: []));
    actions.add(action);
    await box.put('queuedActions', actions);
  }

  List<Map> getQueuedActions() {
    return List<Map>.from(box.get('queuedActions', defaultValue: []));
  }

  Future<void> clearAction(String id) async {
    final actions = List<Map>.from(box.get('queuedActions', defaultValue: []));
    actions.removeWhere((a) => a['id'] == id);
    await box.put('queuedActions', actions);
  }
}