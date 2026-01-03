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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Aadhar Number by Name',
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.05,
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
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          children: [
            if (_selectedNameType.isEmpty)
              _buildNameTypeSelection(width, height),
            if (_selectedNameType.isNotEmpty) _buildSearchForm(width, height),
            SizedBox(height: height * 0.025),
            if (_isLoading) const CircularProgressIndicator(),
            if (_hasSearched && !_isLoading) _buildSearchResults(width, height),
          ],
        ),
      ),
    );
  }

  Widget _buildNameTypeSelection(double width, double height) {
    return Column(
      children: [
        SizedBox(height: height * 0.012),
        Text(
          'Choose how you want to search for Aadhar Number',
          style: TextStyle(fontSize: width * 0.04, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: height * 0.05),
        _buildSelectionCard(
          title: 'Search by First Name',
          subtitle: 'Enter person\'s first name',
          icon: Icons.person,
          onTap: () => _selectNameType('first'),
          width: width,
          height: height,
        ),
        SizedBox(height: height * 0.025),
        _buildSelectionCard(
          title: 'Search by Last Name',
          subtitle: 'Enter person\'s last name',
          icon: Icons.person_outline,
          onTap: () => _selectNameType('last'),
          width: width,
          height: height,
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.04),
        side: const BorderSide(color: Color(0xFFF76048), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(width * 0.04),
        child: Padding(
          padding: EdgeInsets.all(width * 0.05),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(width * 0.03),
                decoration: BoxDecoration(
                  color: const Color(0xFFF76048).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
                child: Icon(
                  icon,
                  size: width * 0.08,
                  color: const Color(0xFFF76048),
                ),
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.005),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: width * 0.035,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: width * 0.05,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchForm(double width, double height) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.04),
        side: const BorderSide(color: Color(0xFFF76048), width: 1.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          children: [
            Text(
              _selectedNameType == 'first'
                  ? 'Search by First Name'
                  : 'Search by Last Name',
              style: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF76048),
              ),
            ),
            SizedBox(height: height * 0.02),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _selectedNameType == 'first'
                    ? 'Enter First Name'
                    : 'Enter Last Name',
                labelStyle: TextStyle(fontSize: width * 0.04),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_search, size: width * 0.06),
              ),
              style: TextStyle(fontSize: width * 0.04),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: height * 0.02),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchAadhar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF76048),
                  padding: EdgeInsets.symmetric(vertical: height * 0.018),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * 0.03),
                  ),
                ),
                child: Text(
                  'Search Aadhar Number',
                  style:
                      TextStyle(fontSize: width * 0.045, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(double width, double height) {
    if (_searchResults.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No results found',
            style: TextStyle(fontSize: width * 0.045, color: Colors.grey),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.01),
            child: Text(
              'Found ${_searchResults.length} result(s)',
              style: TextStyle(
                fontSize: width * 0.04,
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
                return _buildPersonCard(person, index + 1, width, height);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(
      Map<String, dynamic> person, int index, double width, double height) {
    return Card(
      margin: EdgeInsets.only(bottom: height * 0.015),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.03),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.02, vertical: height * 0.005),
              decoration: BoxDecoration(
                color: const Color(0xFFF76048).withOpacity(0.1),
                borderRadius: BorderRadius.circular(width * 0.02),
              ),
              child: Text(
                'Result $index',
                style: TextStyle(
                  fontSize: width * 0.03,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF76048),
                ),
              ),
            ),
            SizedBox(height: height * 0.015),
            _buildDetailRow(
                'Aadhar Number', person['AadhaarNumber'], width, height),
            _buildDetailRow(
              'Full Name',
              '${person['FirstName'] ?? ''} ${person['MiddleName'] ?? ''} ${person['LastName'] ?? ''}'
                  .trim(),
              width,
              height,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label, dynamic value, double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.007),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.35,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: width * 0.0375,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not available',
              style: TextStyle(fontSize: width * 0.0375),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
