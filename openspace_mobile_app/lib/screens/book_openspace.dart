import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:file_picker/file_picker.dart';

import '../service/bookingservice.dart';

class BookingPage extends StatefulWidget {
  final int spaceId;
  final String? spaceName;
  const BookingPage({
    super.key,
    required this.spaceId,
    this.spaceName,
  });

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  bool _isSubmitting = false;

  // Single user fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Common fields
  final _locationController = TextEditingController();
  final _activitiesController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    if (widget.spaceName != null) {
      _locationController.text = widget.spaceName!;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? _startTime : _endTime) ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
    );
    if (result != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Validation Error',
        text: 'Please select a start date.',
      );
      return;
    }
    if (_endDate != null && _startDate != null && _endDate!.isBefore(_startDate!)) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Validation Error',
        text: 'End date cannot be before the start date.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final String username = _nameController.text;
      final String contact = _phoneController.text;
      final String formattedStartDate = DateFormat('yyyy-MM-dd').format(_startDate!);
      final String? formattedEndDate = _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null;
      final String district = _locationController.text.isNotEmpty ? _locationController.text : "Kinondoni";

      // Combine date and time for backend if required (adjust based on backend needs)
      String startDateTime = '$formattedStartDate ${_startTime?.format(context) ?? '00:00'}';
      String? endDateTime = _endDate != null ? '$formattedEndDate ${_endTime?.format(context) ?? '00:00'}' : null;

      debugPrint('Submitting Booking: Space ID: ${widget.spaceId}, Username: $username, Contact: $contact, Start DateTime: $startDateTime, End DateTime: $endDateTime, Purpose: ${_activitiesController.text}, District: $district, File: ${_selectedFile?.path ?? "None"}');

      bool success = await _bookingService.createBooking(
        spaceId: widget.spaceId,
        username: username,
        contact: contact,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
        purpose: _activitiesController.text,
        district: district,
        file: _selectedFile,
      );

      if (success) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Booking Submitted!',
          text: 'Your community space booking request has been sent successfully and is pending approval.',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      }
    } catch (e) {
      debugPrint('Booking Error: $e');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Booking Error',
        text: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF6B48FF)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: const Color(0xFF6B48FF)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: _buildInputDecoration(label, icon),
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _isSubmitting ? null : onTap,
        child: InputDecorator(
          decoration: _buildInputDecoration(label + (isRequired ? ' *' : ''), icon),
          child: Text(
            text,
            style: TextStyle(
              color: text.startsWith("Select") || text == "YYYY-MM-DD" || text == "HH:MM" ? Colors.grey : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Community Space'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6B48FF),
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Booking Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6B48FF)),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _nameController,
                label: 'Full Name *',
                icon: Icons.person_outline,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              _buildFormField(
                controller: _phoneController,
                label: 'Phone Number *',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
              ),
              _buildFormField(
                controller: _emailController,
                label: 'Email Address (Optional)',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value != null && value.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value) ? 'Please enter a valid email' : null,
              ),
              _buildFormField(
                controller: _locationController,
                label: 'Space Name / District *',
                icon: Icons.location_on,
                validator: (value) => value == null || value.isEmpty ? 'Please specify the location/district' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'Start Date *',
                      icon: Icons.calendar_today,
                      text: _startDate == null ? 'YYYY-MM-DD' : DateFormat('yyyy-MM-dd').format(_startDate!),
                      onTap: () => _selectDate(context, true),
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'End Date',
                      icon: Icons.calendar_today,
                      text: _endDate == null ? 'YYYY-MM-DD' : DateFormat('yyyy-MM-dd').format(_endDate!),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'Start Time *',
                      icon: Icons.access_time,
                      text: _startTime == null ? 'HH:MM' : _startTime!.format(context),
                      onTap: () => _selectTime(context, true),
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateTimeField(
                      label: 'End Time *',
                      icon: Icons.access_time,
                      text: _endTime == null ? 'HH:MM' : _endTime!.format(context),
                      onTap: () => _selectTime(context, false),
                      isRequired: true,
                    ),
                  ),
                ],
              ),
              _buildFormField(
                controller: _activitiesController,
                label: 'Activities Planned *',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please describe your planned activities' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B48FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                )
                    : const Text('Submit Booking Request'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5)],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Terms',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6B48FF)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Bookings are subject to availability',
                      style: TextStyle(color: Colors.black87),
                    ),
                    Text(
                      '• Please arrive on time for your scheduled slot',
                      style: TextStyle(color: Colors.black87),
                    ),
                    Text(
                      '• Cancellations must be made at least 24 hours in advance',
                      style: TextStyle(color: Colors.black87),
                    ),
                    Text(
                      '• Keep the space clean and follow all facility rules',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _activitiesController.dispose();
    super.dispose();
  }
}