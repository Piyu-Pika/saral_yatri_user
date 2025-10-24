import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/subsidy_validation_helper.dart';
import '../../../data/models/subsidy_application.dart';
import '../../../data/providers/subsidy_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class SubsidyApplicationFormScreen extends ConsumerStatefulWidget {
  const SubsidyApplicationFormScreen({super.key});

  @override
  ConsumerState<SubsidyApplicationFormScreen> createState() =>
      _SubsidyApplicationFormScreenState();
}

class _SubsidyApplicationFormScreenState
    extends ConsumerState<SubsidyApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Form controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _annualIncomeController = TextEditingController();
  final _incomeSourceController = TextEditingController();
  final _familyMembersController = TextEditingController();
  final _familyIncomeController = TextEditingController();

  // Form data
  SubsidyType? _selectedSubsidyType;
  DateTime? _dateOfBirth;
  Gender? _selectedGender;
  final Map<DocumentType, File?> _selectedDocuments = {};
  final Map<DocumentType, String?> _documentBase64 = {};

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _aadhaarController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _reasonController.dispose();
    _monthlyIncomeController.dispose();
    _annualIncomeController.dispose();
    _incomeSourceController.dispose();
    _familyMembersController.dispose();
    _familyIncomeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subsidyState = ref.watch(subsidyProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Apply for Subsidy'),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSubsidyTypeStep(),
                _buildPersonalInfoStep(),
                _buildAddressStep(),
                _buildIncomeStep(),
                _buildDocumentsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildNavigationButtons(subsidyState.isSubmitting),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(6, (index) {
          final isActive = index <= _currentStep;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 5 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSubsidyTypeStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Subsidy Type',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose the type of subsidy you want to apply for',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: SubsidyType.values.map((type) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<SubsidyType>(
                    value: type,
                    groupValue: _selectedSubsidyType,
                    onChanged: (value) {
                      setState(() {
                        _selectedSubsidyType = value;
                        _selectedDocuments.clear();
                        _documentBase64.clear();
                      });
                    },
                    title: Text(
                      type.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(type.description),
                    activeColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _fullNameController,
              label: 'Full Name',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hintText: '+91-9876543210 or 9876543210',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your phone number';
                }
                // Remove all non-digit characters for validation
                final digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.length < 10) {
                  return 'Phone number must be at least 10 digits';
                }
                if (digits.length > 12) {
                  return 'Phone number is too long';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'example@email.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your email';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value!.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _aadhaarController,
              label: 'Aadhaar Number',
              hintText: '1234-5678-9012 or 123456789012',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your Aadhaar number';
                }
                // Remove all non-digit characters for validation
                final digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.length != 12) {
                  return 'Aadhaar number must be exactly 12 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDateOfBirth(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textHint),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dateOfBirth != null
                          ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                          : 'Select Date of Birth',
                      style: TextStyle(
                        color: _dateOfBirth != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Gender>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: Gender.values.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select your gender';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Address Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _streetController,
            label: 'Street Address',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your street address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _cityController,
            label: 'City',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your city';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _districtController,
            label: 'District',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your district';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _stateController,
            label: 'State',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your state';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _pincodeController,
            label: 'Pincode',
            hintText: 'e.g., 400001',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your pincode';
              }
              final digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
              if (digits.length != 6) {
                return 'Pincode must be exactly 6 digits';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Income Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _monthlyIncomeController,
            label: 'Monthly Income (₹)',
            hintText: 'e.g., 15000',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your monthly income';
              }
              final income = double.tryParse(value!.trim());
              if (income == null) {
                return 'Please enter a valid number';
              }
              if (income < 0) {
                return 'Income cannot be negative';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _annualIncomeController,
            label: 'Annual Income (₹)',
            hintText: 'e.g., 180000',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your annual income';
              }
              final income = double.tryParse(value!.trim());
              if (income == null) {
                return 'Please enter a valid number';
              }
              if (income < 0) {
                return 'Income cannot be negative';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _incomeSourceController,
            label: 'Income Source',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your income source';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _familyMembersController,
            label: 'Number of Family Members',
            hintText: 'e.g., 4',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter number of family members';
              }
              final members = int.tryParse(value!.trim());
              if (members == null) {
                return 'Please enter a valid number';
              }
              if (members < 1) {
                return 'Family members must be at least 1';
              }
              if (members > 50) {
                return 'Please enter a reasonable number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _familyIncomeController,
            label: 'Total Family Income (₹)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter total family income';
              }
              final income = double.tryParse(value!.trim());
              if (income == null) {
                return 'Please enter a valid number';
              }
              if (income < 0) {
                return 'Income cannot be negative';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _reasonController,
            label: 'Application Reason',
            maxLines: 3,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter the reason for application';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    if (_selectedSubsidyType == null) {
      return const Center(child: Text('Please select a subsidy type first'));
    }

    final requiredDocuments = _selectedSubsidyType!.requiredDocuments;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Documents',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please upload all required documents',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: requiredDocuments.length,
              itemBuilder: (context, index) {
                final docType = requiredDocuments[index];
                final isUploaded = _selectedDocuments[docType] != null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      isUploaded ? Icons.check_circle : Icons.upload_file,
                      color: isUploaded
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    title: Text(docType.displayName),
                    subtitle: Text(
                      isUploaded ? 'Uploaded' : 'Tap to upload',
                      style: TextStyle(
                        color: isUploaded
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                    trailing: isUploaded
                        ? IconButton(
                            icon: const Icon(Icons.delete,
                                color: AppColors.error),
                            onPressed: () {
                              setState(() {
                                _selectedDocuments.remove(docType);
                                _documentBase64.remove(docType);
                              });
                            },
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _pickDocument(docType),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Review Application',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildReviewSection(
              'Subsidy Type', _selectedSubsidyType?.displayName ?? ''),
          _buildReviewSection('Full Name', _fullNameController.text),
          _buildReviewSection('Phone', _phoneController.text),
          _buildReviewSection('Email', _emailController.text),
          _buildReviewSection('Aadhaar', _aadhaarController.text),
          _buildReviewSection(
              'Date of Birth',
              _dateOfBirth != null
                  ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                  : ''),
          _buildReviewSection(
              'Gender', _selectedGender?.name.toUpperCase() ?? ''),
          _buildReviewSection('Address',
              '${_streetController.text}, ${_cityController.text}, ${_districtController.text}, ${_stateController.text} - ${_pincodeController.text}'),
          _buildReviewSection(
              'Monthly Income', '₹${_monthlyIncomeController.text}'),
          _buildReviewSection(
              'Annual Income', '₹${_annualIncomeController.text}'),
          _buildReviewSection('Income Source', _incomeSourceController.text),
          _buildReviewSection('Family Members', _familyMembersController.text),
          _buildReviewSection(
              'Family Income', '₹${_familyIncomeController.text}'),
          _buildReviewSection('Reason', _reasonController.text),
          const SizedBox(height: 16),
          const Text(
            'Documents Uploaded',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._selectedDocuments.keys.map((docType) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Text(docType.displayName),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isSubmitting) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                onPressed: _previousStep,
                text: 'Previous',
                type: ButtonType.outline,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              onPressed: isSubmitting ? null : _nextStep,
              text: _currentStep == 5 ? 'Submit Application' : 'Next',
              isLoading: isSubmitting,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedSubsidyType == null) {
      _showSnackBar('Please select a subsidy type');
      return;
    }

    if (_currentStep == 1 && !_validatePersonalInfo()) {
      return;
    }

    if (_currentStep == 2 && !_validateAddress()) {
      return;
    }

    if (_currentStep == 3 && !_validateIncome()) {
      return;
    }

    if (_currentStep == 4 && !_validateDocuments()) {
      return;
    }

    if (_currentStep == 5) {
      _submitApplication();
      return;
    }

    setState(() {
      _currentStep++;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validatePersonalInfo() {
    if (_fullNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _aadhaarController.text.isEmpty ||
        _dateOfBirth == null ||
        _selectedGender == null) {
      _showSnackBar('Please fill all personal information fields');
      return false;
    }
    return true;
  }

  bool _validateAddress() {
    if (_streetController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _districtController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _pincodeController.text.isEmpty) {
      _showSnackBar('Please fill all address fields');
      return false;
    }
    return true;
  }

  bool _validateIncome() {
    if (_monthlyIncomeController.text.isEmpty ||
        _annualIncomeController.text.isEmpty ||
        _incomeSourceController.text.isEmpty ||
        _familyMembersController.text.isEmpty ||
        _familyIncomeController.text.isEmpty ||
        _reasonController.text.isEmpty) {
      _showSnackBar('Please fill all income information fields');
      return false;
    }
    return true;
  }

  bool _validateDocuments() {
    if (_selectedSubsidyType == null) return false;

    final requiredDocuments = _selectedSubsidyType!.requiredDocuments;
    for (final docType in requiredDocuments) {
      if (_selectedDocuments[docType] == null) {
        _showSnackBar('Please upload all required documents');
        return false;
      }
    }
    return true;
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _dateOfBirth = date;
      });
    }
  }

  Future<void> _pickDocument(DocumentType docType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = _getMimeType(pickedFile.path);

      setState(() {
        _selectedDocuments[docType] = file;
        _documentBase64[docType] = 'data:$mimeType;base64,$base64String';
      });
    }
  }

  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _submitApplication() async {
    try {
      // Validate all data before submission
      if (!_validateAllData()) {
        return;
      }

      final documents = _selectedDocuments.keys.map((docType) {
        final file = _selectedDocuments[docType]!;
        return DocumentUpload(
          documentType: docType,
          documentName: file.path.split('/').last,
          base64Data: _documentBase64[docType]!,
          mimeType: _getMimeType(file.path),
          uploadedAt: DateTime.now(),
          fileSize: file.lengthSync(),
        );
      }).toList();

      // Parse and validate numeric values
      double monthlyIncome;
      double annualIncome;
      int familyMembers;
      double familyIncome;

      try {
        monthlyIncome = double.parse(_monthlyIncomeController.text.trim());
        annualIncome = double.parse(_annualIncomeController.text.trim());
        familyMembers = int.parse(_familyMembersController.text.trim());
        familyIncome = double.parse(_familyIncomeController.text.trim());
      } catch (e) {
        _showSnackBar(
            'Please enter valid numeric values for income and family members');
        return;
      }

      // Validate numeric ranges
      if (monthlyIncome < 0 || annualIncome < 0 || familyIncome < 0) {
        _showSnackBar('Income values cannot be negative');
        return;
      }

      if (familyMembers < 1) {
        _showSnackBar('Family members must be at least 1');
        return;
      }

      // Format phone number (ensure it starts with +91 if it's an Indian number)
      String formattedPhone = _phoneController.text.trim();
      if (!formattedPhone.startsWith('+')) {
        if (formattedPhone.startsWith('91') && formattedPhone.length == 12) {
          formattedPhone = '+$formattedPhone';
        } else if (formattedPhone.length == 10) {
          formattedPhone = '+91$formattedPhone';
        } else {
          formattedPhone = '+91-$formattedPhone';
        }
      }

      // Format Aadhaar number (ensure it has dashes)
      String formattedAadhaar = _aadhaarController.text
          .trim()
          .replaceAll(' ', '')
          .replaceAll('-', '');
      if (formattedAadhaar.length == 12) {
        formattedAadhaar =
            '${formattedAadhaar.substring(0, 4)}-${formattedAadhaar.substring(4, 8)}-${formattedAadhaar.substring(8, 12)}';
      }

      final request = SubsidyApplicationRequest(
        subsidyType: _selectedSubsidyType!,
        fullName: _fullNameController.text.trim(),
        phone: formattedPhone,
        email: _emailController.text.trim().toLowerCase(),
        aadhaarNumber: formattedAadhaar,
        dateOfBirth: _dateOfBirth!,
        gender: _selectedGender!,
        address: Address(
          street: _streetController.text.trim(),
          city: _cityController.text.trim(),
          district: _districtController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
        ),
        applicationReason: _reasonController.text.trim(),
        incomeDetails: IncomeDetails(
          monthlyIncome: monthlyIncome,
          annualIncome: annualIncome,
          incomeSource: _incomeSourceController.text.trim(),
          familyMembers: familyMembers,
          familyIncome: familyIncome,
        ),
        documents: documents,
      );

      // Validate and log the request before submission
      SubsidyValidationHelper.validateAndLogRequest(request);

      final success =
          await ref.read(subsidyProvider.notifier).submitApplication(request);

      if (success) {
        _showSnackBar('Application submitted successfully!');
        Navigator.of(context).pop();
      } else {
        final error = ref.read(subsidyProvider).error;
        _showSnackBar(error ?? 'Failed to submit application');
      }
    } catch (e) {
      _showSnackBar('Error preparing application: $e');
    }
  }

  bool _validateAllData() {
    // Validate basic required fields
    if (_selectedSubsidyType == null) {
      _showSnackBar('Please select a subsidy type');
      return false;
    }

    if (_fullNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your full name');
      return false;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('Please enter your phone number');
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email');
      return false;
    }

    // Validate email format
    if (!SubsidyValidationHelper.validateEmail(_emailController.text.trim())) {
      _showSnackBar('Please enter a valid email address');
      return false;
    }

    if (_aadhaarController.text.trim().isEmpty) {
      _showSnackBar('Please enter your Aadhaar number');
      return false;
    }

    // Validate Aadhaar format (12 digits)
    if (!SubsidyValidationHelper.validateAadhaarNumber(
        _aadhaarController.text.trim())) {
      _showSnackBar('Aadhaar number must be 12 digits');
      return false;
    }

    if (_dateOfBirth == null) {
      _showSnackBar('Please select your date of birth');
      return false;
    }

    if (_selectedGender == null) {
      _showSnackBar('Please select your gender');
      return false;
    }

    // Validate address
    if (_streetController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _districtController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _pincodeController.text.trim().isEmpty) {
      _showSnackBar('Please fill all address fields');
      return false;
    }

    // Validate pincode (6 digits)
    if (!SubsidyValidationHelper.validatePincode(
        _pincodeController.text.trim())) {
      _showSnackBar('Pincode must be 6 digits');
      return false;
    }

    // Validate income fields
    if (_monthlyIncomeController.text.trim().isEmpty ||
        _annualIncomeController.text.trim().isEmpty ||
        _incomeSourceController.text.trim().isEmpty ||
        _familyMembersController.text.trim().isEmpty ||
        _familyIncomeController.text.trim().isEmpty) {
      _showSnackBar('Please fill all income information fields');
      return false;
    }

    if (_reasonController.text.trim().isEmpty) {
      _showSnackBar('Please enter the reason for application');
      return false;
    }

    // Validate documents
    if (_selectedSubsidyType != null) {
      final requiredDocuments = _selectedSubsidyType!.requiredDocuments;
      for (final docType in requiredDocuments) {
        if (_selectedDocuments[docType] == null) {
          _showSnackBar('Please upload all required documents');
          return false;
        }
      }
    }

    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
