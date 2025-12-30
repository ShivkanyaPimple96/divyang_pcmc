import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AadharSearchScreen extends StatefulWidget {
  const AadharSearchScreen({super.key});

  @override
  State<AadharSearchScreen> createState() => _AadharSearchScreenState();
}

class _AadharSearchScreenState extends State<AadharSearchScreen> {
  final TextEditingController _nameController = TextEditingController();

  String _selectedNameType = ''; // '' means no selection, 'first' or 'last'
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _searchAadhar() async {
    if (_nameController.text.isEmpty) {
      _showValidationErrorDialog(
          'Please enter a name\nकृपया नाव प्रविष्ट करा.');
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchResults = [];
    });

    try {
      final Map<String, String> queryParams = {};

      if (_selectedNameType == 'first') {
        queryParams['FirstName'] = _nameController.text.trim();
        queryParams['LastName'] = '';
      } else if (_selectedNameType == 'last') {
        queryParams['LastName'] = _nameController.text.trim();
        queryParams['FirstName'] = '';
      }

      final Uri uri = Uri.https(
        'divyangpcmc.altwise.in',
        '/api/aadhar/KnowYourAadharNumber',
        queryParams,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['Success'] == true) {
          // Handle multiple results (Data as list)
          if (responseData['Data'] != null && responseData['Data'] is List) {
            setState(() {
              _searchResults = List<dynamic>.from(responseData['Data']);
            });
          }
          // Handle Dataa as list (alternative response format)
          else if (responseData['Dataa'] != null &&
              responseData['Dataa'] is List) {
            setState(() {
              _searchResults = List<dynamic>.from(responseData['Dataa']);
            });
          }
          // Handle single result (Data as object)
          else if (responseData['Data'] != null &&
              responseData['Data'] is Map<String, dynamic>) {
            final Map<String, dynamic> data = responseData['Data'];

            // Check if we have valid data
            if (data['AadhaarNumber'] != null ||
                data['FirstName'] != null ||
                data['LastName'] != null) {
              setState(() {
                _searchResults = [data];
              });
            } else {
              setState(() {
                _searchResults = [];
              });
              _showValidationErrorDialog('No valid Aadhar records found');
            }
          } else {
            setState(() {
              _searchResults = [];
            });
            _showValidationErrorDialog(
                'No Aadhar records found with that name');
          }

          if (_searchResults.isEmpty) {
            _showValidationErrorDialog(
                'No Aadhar records found with that name');
          }
        } else {
          setState(() {
            _searchResults = [];
          });
          _showValidationErrorDialog(
              responseData['Message'] ?? 'No Aadhar records found');
        }
      } else {
        setState(() {
          _searchResults = [];
        });
        _showValidationErrorDialog('Note: No Aadhar Number Found');
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
      _showValidationErrorDialog('Failed to search: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectNameType(String type) {
    setState(() {
      _selectedNameType = type;
      _nameController.clear();
      _searchResults = [];
      _hasSearched = false;
    });
  }

  void _goBack() {
    setState(() {
      _selectedNameType = '';
      _nameController.clear();
      _searchResults = [];
      _hasSearched = false;
    });
  }

  Future<void> _showValidationErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Row(
            children: [
              SizedBox(width: 10),
              Text(
                'Note',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(thickness: 2.5),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Aadhar Number by Name',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF76048),
        centerTitle: true,
        elevation: 4,
        leading: _selectedNameType.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _goBack,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedNameType.isEmpty) _buildNameTypeSelection(),
            if (_selectedNameType.isNotEmpty) _buildSearchForm(),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_hasSearched && !_isLoading) _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameTypeSelection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'Choose how you want to search for Aadhar Number',
          style: TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildSelectionCard(
          title: 'Search by First Name',
          subtitle: 'Enter person\'s first name',
          icon: Icons.person,
          onTap: () => _selectNameType('first'),
        ),
        const SizedBox(height: 20),
        _buildSelectionCard(
          title: 'Search by Last Name',
          subtitle: 'Enter person\'s last name',
          icon: Icons.person_outline,
          onTap: () => _selectNameType('last'),
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: Color(0xFFF76048), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF76048).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFFF76048),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: Color(0xFFF76048), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _selectedNameType == 'first'
                  ? 'Search by First Name'
                  : 'Search by Last Name',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF76048),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _selectedNameType == 'first'
                    ? 'Enter First Name'
                    : 'Enter Last Name',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person_search),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchAadhar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF76048),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Search Aadhar Number',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No results found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Found ${_searchResults.length} result(s)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final person = _searchResults[index];
                return _buildPersonCard(person, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(Map<String, dynamic> person, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF76048).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Result $index',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF76048),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Aadhar Number', person['AadhaarNumber']),
            _buildDetailRow(
              'Full Name',
              '${person['FirstName'] ?? ''} ${person['MiddleName'] ?? ''} ${person['LastName'] ?? ''}'
                  .trim(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not available',
              style: const TextStyle(fontSize: 15),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
