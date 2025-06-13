import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openspace_mobile_app/utils/constants.dart';
import 'dart:math';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  // Mock data for bookings
  static final List<Map<String, dynamic>> _mockBookings = [
    {
      'id': '1',
      'type': 'SINGLE',
      'name': 'Alice Johnson',
      'phone': '+1234567890',
      'email': 'alice.johnson@example.com',
      'location': 'Central Park',
      'activities': 'Morning yoga and meditation session',
      'startDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'endDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'startTime': '08:00 AM',
      'endTime': '10:00 AM',
      'openSpaceId': 'space_1',
    },
    {
      'id': '2',
      'type': 'GROUP',
      'groupName': 'Tech Meetup Group',
      'numberOfPeople': 20,
      'contactPerson': 'Bob Smith',
      'contactPhone': '+0987654321',
      'contactEmail': 'bob.smith@example.com',
      'location': 'Riverside Park',
      'activities': 'Tech workshop and networking event',
      'startDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'endDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'startTime': '10:00 AM',
      'endTime': '04:00 PM',
      'openSpaceId': 'space_2',
    },
    {
      'id': '3',
      'type': 'SINGLE',
      'name': 'Carol White',
      'phone': '+1122334455',
      'email': 'carol.white@example.com',
      'location': 'City Garden',
      'activities': 'Photography session',
      'startDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'endDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'startTime': '02:00 PM',
      'endTime': '04:00 PM',
      'openSpaceId': 'space_3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: AppConstants.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _mockBookings.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppConstants.grey
                    : AppConstants.darkTextSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No bookings found.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppConstants.grey
                      : AppConstants.darkTextSecondary,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _mockBookings.length,
          itemBuilder: (context, index) {
            final booking = _mockBookings[index];
            return _BookingCard(booking: booking);
          },
        ),
      ),
    );
  }
}

class _BookingCard extends StatefulWidget {
  final Map<String, dynamic> booking;

  const _BookingCard({required this.booking});

  @override
  __BookingCardState createState() => __BookingCardState();
}

class __BookingCardState extends State<_BookingCard> {
  String? _availabilityStatus;
  String? _reservationStatus;
  bool _isCheckingAvailability = false;
  bool _isCheckingReservation = false;

  // Mock availability check
  void _checkAvailability() {
    setState(() {
      _isCheckingAvailability = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      final statuses = ['CONFIRMED', 'PENDING', 'UNAVAILABLE'];
      setState(() {
        _isCheckingAvailability = false;
        final startDate = DateTime.parse(widget.booking['startDate']);
        _availabilityStatus = startDate.isBefore(DateTime.now())
            ? 'UNAVAILABLE'
            : statuses[Random().nextInt(statuses.length)];
      });
    });
  }

  // Mock reservation check
  void _checkReservation() {
    setState(() {
      _isCheckingReservation = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isCheckingReservation = false;
        final startDate = DateTime.parse(widget.booking['startDate']);
        final isSingle = widget.booking['type'] == 'SINGLE';
        final hasRequiredFields = isSingle
            ? (widget.booking['name']?.isNotEmpty ?? false) &&
            (widget.booking['phone']?.isNotEmpty ?? false) &&
            (widget.booking['email']?.isNotEmpty ?? false)
            : (widget.booking['groupName']?.isNotEmpty ?? false) &&
            (widget.booking['numberOfPeople'] != null) &&
            (widget.booking['contactPerson']?.isNotEmpty ?? false) &&
            (widget.booking['contactPhone']?.isNotEmpty ?? false) &&
            (widget.booking['contactEmail']?.isNotEmpty ?? false);
        if (startDate.isBefore(DateTime.now())) {
          _reservationStatus = 'EXPIRED';
        } else if (hasRequiredFields &&
            (widget.booking['location']?.isNotEmpty ?? false) &&
            (widget.booking['activities']?.isNotEmpty ?? false)) {
          _reservationStatus = 'VALID';
        } else {
          _reservationStatus = 'INVALID';
        }
      });
    });
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'CONFIRMED':
      case 'VALID':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'UNAVAILABLE':
      case 'INVALID':
      case 'EXPIRED':
        return Colors.red;
      default:
        return AppConstants.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final isSingle = booking['type'] == 'SINGLE';
    final startDate = booking['startDate'] != null
        ? DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['startDate']))
        : 'N/A';
    final endDate = booking['endDate'] != null
        ? DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['endDate']))
        : 'N/A';
    final startTime = booking['startTime'] ?? 'N/A';
    final endTime = booking['endTime'] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          leading: Icon(
            isSingle ? Icons.person : Icons.group,
            color: Theme.of(context).brightness == Brightness.light
                ? AppConstants.primaryBlue
                : AppConstants.lightAccent,
          ),
          title: Text(
            isSingle ? booking['name'] ?? 'Booking' : booking['groupName'] ?? 'Group Booking',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppConstants.primaryBlue
                  : AppConstants.lightAccent,
            ),
          ),
          subtitle: Text(
            '${booking['location'] ?? 'Unknown Location'} • $startDate',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Details',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppConstants.primaryBlue
                          : AppConstants.lightAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isSingle) ...[
                    _buildDetailRow(Icons.person, 'Name', booking['name'] ?? 'N/A'),
                    _buildDetailRow(Icons.phone, 'Phone', booking['phone'] ?? 'N/A'),
                    _buildDetailRow(Icons.email, 'Email', booking['email'] ?? 'N/A'),
                  ] else ...[
                    _buildDetailRow(Icons.group, 'Group Name', booking['groupName'] ?? 'N/A'),
                    _buildDetailRow(Icons.people, 'Number of People',
                        booking['numberOfPeople']?.toString() ?? 'N/A'),
                    _buildDetailRow(Icons.person, 'Contact Person',
                        booking['contactPerson'] ?? 'N/A'),
                    _buildDetailRow(Icons.phone, 'Contact Phone',
                        booking['contactPhone'] ?? 'N/A'),
                    _buildDetailRow(Icons.email, 'Contact Email',
                        booking['contactEmail'] ?? 'N/A'),
                  ],
                  _buildDetailRow(Icons.location_on, 'Location', booking['location'] ?? 'N/A'),
                  _buildDetailRow(Icons.calendar_today, 'Start Date', startDate),
                  _buildDetailRow(Icons.calendar_today, 'End Date', endDate),
                  _buildDetailRow(Icons.access_time, 'Start Time', startTime),
                  _buildDetailRow(Icons.access_time, 'End Time', endTime),
                  _buildDetailRow(Icons.event, 'Activities', booking['activities'] ?? 'N/A'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isCheckingAvailability ? null : _checkAvailability,
                          child: _isCheckingAvailability
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppConstants.white,
                            ),
                          )
                              : const Text('Track Availability'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isCheckingReservation ? null : _checkReservation,
                          child: _isCheckingReservation
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppConstants.white,
                            ),
                          )
                              : const Text('Check Reservation'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (_availabilityStatus != null)
                        Chip(
                          label: Text(
                            _availabilityStatus!,
                            style: const TextStyle(color: AppConstants.white),
                          ),
                          backgroundColor: _getStatusColor(_availabilityStatus),
                        ),
                      if (_reservationStatus != null)
                        Chip(
                          label: Text(
                            _reservationStatus!,
                            style: const TextStyle(color: AppConstants.white),
                          ),
                          backgroundColor: _getStatusColor(_reservationStatus),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).brightness == Brightness.light
                ? AppConstants.primaryBlue
                : AppConstants.lightAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppConstants.grey
                        : AppConstants.darkTextSecondary,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}