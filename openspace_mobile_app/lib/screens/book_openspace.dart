// booking_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openspace_mobile_app/utils/constants.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:file_picker/file_picker.dart';

import '../service/bookingservice.dart';

enum BookingType { single, group }

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
  BookingType _bookingType = BookingType.single;

  // Single user fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController(); // UI only, not directly in backend model

  // Group fields
  final _groupNameController = TextEditingController();
  final _numberOfPeopleController = TextEditingController(); // UI only
  final _contactPersonController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController(); // UI only

  // Common fields
  final _locationController = TextEditingController(); // Used for 'district' currently
  final _activitiesController = TextEditingController(); // This will be 'purpose'
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime; // UI only, backend takes Date
  TimeOfDay? _endTime;   // UI only, backend takes Date

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
      lastDate: DateTime(DateTime.now().year + 5), // Allow booking 5 years in advance
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null; // Reset end date if it's before new start date
          }
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
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Example: allow specific types
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
    }
  }
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Validation Error',
        text: 'Please select a start date.',
      );
      return;
    }
    // Basic validation for end date if present
    if (_endDate != null && _startDate != null && _endDate!.isBefore(_startDate!)) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Validation Error',
        text: 'End date cannot be before the start date.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String username;
      String contact;

      if (_bookingType == BookingType.single) {
        username = _nameController.text;
        contact = _phoneController.text;
      } else {
        username = _contactPersonController.text.isNotEmpty
            ? _contactPersonController.text
            : _groupNameController.text;
        contact = _contactPhoneController.text;
      }

      final String formattedStartDate = DateFormat('yyyy-MM-dd').format(_startDate!);
      final String? formattedEndDate =
      _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null;

      final String district = _locationController.text.isNotEmpty
          ? _locationController.text
          : "Kinondoni";

      // Log the input parameters for debugging
      debugPrint('Submitting Booking:');
      debugPrint('Space ID: ${widget.spaceId}');
      debugPrint('Username: $username');
      debugPrint('Contact: $contact');
      debugPrint('Start Date: $formattedStartDate');
      debugPrint('End Date: $formattedEndDate');
      debugPrint('Purpose: ${_activitiesController.text}');
      debugPrint('District: $district');
      debugPrint('File: ${_selectedFile?.path ?? "None"}');

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
          text: 'Your open space booking request has been sent successfully and is pending approval.',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            Navigator.of(context).pop(); // Close the alert
            Navigator.of(context).pop(); // Go back from BookingPage
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
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }



  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.light
            ? AppConstants.primaryBlue
            : AppConstants.lightAccent,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).brightness == Brightness.light
            ? AppConstants.primaryBlue
            : AppConstants.lightAccent,
      ),
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
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isRequired = false, // To indicate visually if required
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: _buildInputDecoration(label + (isRequired ? ' *' : ''), icon),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: text.startsWith("Select") ? Colors.grey : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith( // Changed to titleLarge
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppConstants.primaryBlue
                      : AppConstants.lightAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16), // Increased spacing
              ...children,
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book an Open Space'),
        centerTitle: true,
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: AppConstants.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isSubmitting) return; // Prevent navigation while submitting
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Booking Type Selection
              _buildSection(
                  title: '1. Booking Type',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<BookingType>(
                            title: Text('Single User', style: Theme.of(context).textTheme.bodyMedium),
                            value: BookingType.single,
                            groupValue: _bookingType,
                            onChanged: _isSubmitting ? null : (value) => setState(() => _bookingType = value!),
                            activeColor: AppConstants.primaryBlue,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<BookingType>(
                            title: Text('Group/Organization', style: Theme.of(context).textTheme.bodyMedium),
                            value: BookingType.group,
                            groupValue: _bookingType,
                            onChanged: _isSubmitting ? null : (value) => setState(() => _bookingType = value!),
                            activeColor: AppConstants.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ]
              ),

              // User/Group Information
              if (_bookingType == BookingType.single)
                _buildSection(
                  title: '2. Your Information',
                  children: [
                    _buildFormField(
                      controller: _nameController,
                      label: 'Full Name *',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your name';
                        return null;
                      },
                    ),
                    _buildFormField(
                      controller: _phoneController,
                      label: 'Phone Number *',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your phone number';
                        return null;
                      },
                    ),
                    _buildFormField( // Email is for UI, not directly in backend model shown
                      controller: _emailController,
                      label: 'Email Address (Optional)',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                )
              else // Group Booking
                _buildSection(
                  title: '2. Group/Organization Information',
                  children: [
                    _buildFormField(
                      controller: _groupNameController,
                      label: 'Group/Organization Name *',
                      icon: Icons.group_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter the group name';
                        return null;
                      },
                    ),
                    _buildFormField( // UI Only for now, not in backend model directly
                      controller: _numberOfPeopleController,
                      label: 'Approx. Number of People (Optional)',
                      icon: Icons.people_outline,
                      keyboardType: TextInputType.number,
                    ),
                    _buildFormField(
                      controller: _contactPersonController,
                      label: 'Contact Person Name *',
                      icon: Icons.person_pin_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter contact person name';
                        return null;
                      },
                    ),
                    _buildFormField(
                      controller: _contactPhoneController,
                      label: 'Contact Phone Number *',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter contact phone';
                        return null;
                      },
                    ),
                    _buildFormField( // UI Only for now
                      controller: _contactEmailController,
                      label: 'Contact Email (Optional)',
                      icon: Icons.alternate_email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

              // Booking Details
              _buildSection(
                title: '3. Booking Details',
                children: [
                  _buildFormField(
                    controller: _locationController,
                    label: 'Space Name / District *', // Changed label
                    icon: Icons.location_on_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please specify the location/district';
                      return null;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'Start Date',
                          icon: Icons.calendar_today_outlined,
                          isRequired: true,
                          text: _startDate == null ? 'Select Start Date *' : DateFormat('EEE, MMM d, yyyy').format(_startDate!),
                          onTap: _isSubmitting ? (){} : () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'End Date',
                          icon: Icons.calendar_today_outlined,
                          text: _endDate == null ? 'Select End Date (Optional)' : DateFormat('EEE, MMM d, yyyy').format(_endDate!),
                          onTap: _isSubmitting ? (){} :() => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                  Row( // Optional: Time fields (UI only, backend only takes date)
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'Start Time',
                          icon: Icons.access_time_outlined,
                          text: _startTime == null ? 'Select Start Time (Optional)' : _startTime!.format(context),
                          onTap: _isSubmitting ? (){} :() => _selectTime(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'End Time',
                          icon: Icons.access_time_outlined,
                          text: _endTime == null ? 'Select End Time (Optional)' : _endTime!.format(context),
                          onTap: _isSubmitting ? (){} :() => _selectTime(context, false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              _buildSection(
                title: '4. Purpose & Attachments',
                children: [
                  _buildFormField(
                    controller: _activitiesController,
                    label: 'Purpose of Booking *',
                    icon: Icons.assignment_outlined,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please describe the purpose';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Provide details about why you are booking this open space (e.g., event type, activities planned).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppConstants.grey),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.attach_file_outlined, color: AppConstants.primaryBlue),
                    title: Text(_selectedFile == null ? 'Attach File (Optional)' : 'File: ${_selectedFile!.path.split('/').last}'),
                    subtitle: Text(_selectedFile == null ? 'E.g., Event proposal, ID copy' : 'Tap to change file', style: Theme.of(context).textTheme.bodySmall),
                    onTap: _isSubmitting ? null : _pickFile,
                    trailing: _selectedFile != null ? IconButton(icon: const Icon(Icons.clear, color: Colors.redAccent), onPressed: _isSubmitting ? null : () => setState(()=> _selectedFile = null)) : null,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  foregroundColor: AppConstants.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              const SizedBox(height: 20), // For scroll room
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
    _groupNameController.dispose();
    _numberOfPeopleController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _locationController.dispose();
    _activitiesController.dispose();
    super.dispose();
  }
}