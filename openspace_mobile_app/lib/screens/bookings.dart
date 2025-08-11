import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/model/Booking.dart';
import 'package:openspace_mobile_app/service/bookingservice.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> with SingleTickerProviderStateMixin {
  late Future<List<Booking>> _allBookingsFuture;
  final BookingService _bookingService = BookingService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _allBookingsFuture = _bookingService.fetchMyBookings();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: const Text('My Bookings', style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.primaryBlue,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Active Bookings'),
            Tab(text: 'Past Bookings'),
            Tab(text: 'Pending Bookings'),
          ],
        ),
      ),
      body: Container(
        color: AppConstants.white,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBookingTab((booking) => booking.status.toLowerCase() == 'accepted'),
            _buildBookingTab((booking) => booking.status.toLowerCase() == 'rejected' || DateTime.now().isAfter(booking.endDate ?? DateTime.now())),
            _buildBookingTab((booking) => booking.status.toLowerCase() == 'pending'),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTab(bool Function(Booking) filter) {
    return FutureBuilder<List<Booking>>(
      future: _allBookingsFuture,
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

        final bookings = snapshot.data!.where(filter).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: AppConstants.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppConstants.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Contact', booking.contact),
                    _buildDetailRow('Purpose', booking.purpose),
                    _buildDetailRow('District', booking.district),
                    _buildDetailRow('Start', formatDate(booking.startDate)),
                    if (booking.endDate != null)
                      _buildDetailRow('End', formatDate(booking.endDate!)),
                    Text(
                      'Status: ${booking.status}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _getStatusColor(booking.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}