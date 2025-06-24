import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/model/Booking.dart';
import 'package:openspace_mobile_app/service/bookingservice.dart';
import 'package:intl/intl.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late Future<List<Booking>> _bookingsFuture;
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _bookingService.fetchMyBookings();
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No bookings found.'),
            );
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                child: ListTile(
                  title: Text(
                    booking.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact: ${booking.contact}'),
                      Text('Purpose: ${booking.purpose}'),
                      Text('District: ${booking.district}'),
                      Text('Start: ${formatDate(booking.startDate)}'),
                      if (booking.endDate != null)
                        Text('End: ${formatDate(booking.endDate!)}'),
                      Text('Status: ${booking.status}',
                          style: TextStyle(color: _getStatusColor(booking.status))),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
