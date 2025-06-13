import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:openspace_mobile_app/utils/constants.dart'; // Ensure this defines primaryBlue, white, etc.
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart'; // Optional for animations

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo updated!')),
      );
    }
  }


  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isSaving = false);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Profile updated successfully!',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            Navigator.of(context).pop(); // Close the popup
            Navigator.pop(context);     // Optionally close the edit page
          },
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppConstants.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
                        )
                            .animate()
                            .scale(duration: 300.ms, curve: Curves.easeOut)
                            .then() // Subtle scale animation on tap
                            .fadeIn(duration: 300.ms),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.black54, Colors.black26],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppConstants.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(context, 'Name', 'Enter your name', (value) {
                  if (value == null || value.isEmpty) return 'Name is required';
                  return null;
                }),
                _buildTextField(context, 'Email', 'Enter your email', (value) {
                  if (value == null || value.isEmpty) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
                    return 'Enter a valid email';
                  return null;
                }),
                _buildTextField(context, 'Phone Number', 'Enter your phone number', (value) {
                  if (value == null || value.isEmpty) return 'Phone number is required';
                  if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value))
                    return 'Enter a valid phone number';
                  return null;
                }),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _buildStyledButton(
                        context,
                        'Cancel',
                        Colors.redAccent,
                            () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStyledButton(
                        context,
                        'Save Changes',
                        AppConstants.primaryBlue,
                        _saveChanges,
                        isLoading: _isSaving,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, String hint, String? Function(String?) validator) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryBlue,
          ),
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppConstants.primaryBlue, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: validator,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildStyledButton(BuildContext context, String text, Color color, VoidCallback onPressed,
      {bool isLoading = false}) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
        elevation: 6,
        shadowColor: color.withOpacity(0.3),
      ),
      child: isLoading
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      )
          : Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppConstants.white,
        ),
      ),
    );
  }
}