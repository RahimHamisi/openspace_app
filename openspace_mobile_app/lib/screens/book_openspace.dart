import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openspace_mobile_app/utils/constants.dart';

enum BookingType { single, group }

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  BookingType _bookingType = BookingType.single;

  // Single user fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Group fields
  final _groupNameController = TextEditingController();
  final _numberOfPeopleController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  // Common fields
  final _locationController = TextEditingController();
  final _activitiesController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process the booking data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking submitted successfully!')),
      );
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: _buildInputDecoration(label, icon),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
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
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppConstants.primaryBlue
                      : AppConstants.lightAccent,
                ),
              ),
              const SizedBox(height: 12),
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
        elevation: 8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
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
              const SizedBox(height: 16),
              Text(
                'Booking Type',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppConstants.primaryBlue
                      : AppConstants.lightAccent,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<BookingType>(
                      title: Text(
                        'Single User',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      value: BookingType.single,
                      groupValue: _bookingType,
                      onChanged: (value) {
                        setState(() {
                          _bookingType = value!;
                        });
                      },
                      activeColor: AppConstants.primaryBlue,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<BookingType>(
                      title: Text(
                        'Group of Users',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      value: BookingType.group,
                      groupValue: _bookingType,
                      onChanged: (value) {
                        setState(() {
                          _bookingType = value!;
                        });
                      },
                      activeColor: AppConstants.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _bookingType == BookingType.single
                  ? _buildSection(
                title: 'User Information',
                children: [
                  _buildFormField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  _buildFormField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  _buildFormField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ],
              )
                  : _buildSection(
                title: 'Group Information',
                children: [
                  _buildFormField(
                    controller: _groupNameController,
                    label: 'Group Name',
                    icon: Icons.group,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the group name';
                      }
                      return null;
                    },
                  ),
                  _buildFormField(
                    controller: _numberOfPeopleController,
                    label: 'Number of People',
                    icon: Icons.people,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of people';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  _buildFormField(
                    controller: _contactPersonController,
                    label: 'Contact Person Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the contact person name';
                      }
                      return null;
                    },
                  ),
                  _buildFormField(
                    controller: _contactPhoneController,
                    label: 'Contact Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the contact phone number';
                      }
                      return null;
                    },
                  ),
                  _buildFormField(
                    controller: _contactEmailController,
                    label: 'Contact Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the contact email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              _buildSection(
                title: 'Booking Details',
                children: [
                  _buildFormField(
                    controller: _locationController,
                    label: 'Location',
                    icon: Icons.location_on,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the location';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'Start Date',
                          icon: Icons.calendar_today,
                          text: _startDate == null
                              ? 'Select Start Date'
                              : DateFormat('yyyy-MM-dd').format(_startDate!),
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'End Date',
                          icon: Icons.calendar_today,
                          text: _endDate == null
                              ? 'Select End Date'
                              : DateFormat('yyyy-MM-dd').format(_endDate!),
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildSection(
                title: 'Schedule',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'Start Time',
                          icon: Icons.access_time,
                          text: _startTime == null
                              ? 'Select Start Time'
                              : _startTime!.format(context),
                          onTap: () => _selectTime(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTimeField(
                          label: 'End Time',
                          icon: Icons.access_time,
                          text: _endTime == null
                              ? 'Select End Time'
                              : _endTime!.format(context),
                          onTap: () => _selectTime(context, false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildSection(
                title: 'Activities',
                children: [
                  _buildFormField(
                    controller: _activitiesController,
                    label: 'Purpose of Booking',
                    icon: Icons.event,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please describe the purpose of the booking';
                      }
                      return null;
                    },
                  ),
                  Text(
                    'Please provide details about why you are booking this open space (e.g., event type, activities planned).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppConstants.grey
                          : AppConstants.darkTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text(
                  'Submit Booking',
                  style: TextStyle(fontSize: 18),
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