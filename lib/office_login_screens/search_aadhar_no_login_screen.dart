import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchAadharNoLoginScreen extends StatefulWidget {
  const SearchAadharNoLoginScreen({super.key});

  @override
  State<SearchAadharNoLoginScreen> createState() =>
      _SearchAadharNoLoginScreenState();
}

class _SearchAadharNoLoginScreenState extends State<SearchAadharNoLoginScreen> {
  final TextEditingController _nameController = TextEditingController();

  String _selectedSearchType = ''; // '', 'name', or 'aadhar'
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _searchAadhar() async {
    if (_nameController.text.isEmpty) {
      _showValidationErrorDialog(
          'Please enter a ${_selectedSearchType == 'aadhar' ? 'number' : 'name'}\nकृपया ${_selectedSearchType == 'aadhar' ? 'क्रमांक' : 'नाव'} प्रविष्ट करा.');
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchResults = [];
    });

    try {
      if (_selectedSearchType == 'aadhar') {
        await _searchByAadharNumber();
      } else if (_selectedSearchType == 'name') {
        await _searchByName();
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

  Future<void> _searchByAadharNumber() async {
    final Uri uri = Uri.https(
      'divyangpcmc.altwise.in',
      '/api/aadhar/SearchByAadhaarNumber',
      {'aadhaarNo': _nameController.text.trim()},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        if (responseData['data'] != null && responseData['data'] is List) {
          setState(() {
            _searchResults = List<dynamic>.from(responseData['data']);
          });

          if (_searchResults.isEmpty) {
            _showValidationErrorDialog(
                'No Aadhar records found with that number');
          }
        } else {
          setState(() {
            _searchResults = [];
          });
          _showValidationErrorDialog(
              'No Aadhar records found with that number');
        }
      } else {
        setState(() {
          _searchResults = [];
        });
        _showValidationErrorDialog(
            responseData['message'] ?? 'No Aadhar records found');
      }
    } else {
      setState(() {
        _searchResults = [];
      });
      _showValidationErrorDialog('Note: No Aadhar Number Found');
    }
  }

  Future<void> _searchByName() async {
    final String searchName = _nameController.text.trim();

    // First, try searching by firstName
    final Map<String, String> queryParams = {
      'firstName': searchName,
      'lastName': '',
    };

    final Uri uri = Uri.https(
      'divyangpcmc.altwise.in',
      '/api/aadhar/SearchByName',
      queryParams,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        if (responseData['data'] != null && responseData['data'] is List) {
          List<dynamic> firstNameResults =
              List<dynamic>.from(responseData['data']);

          // If no results found with firstName, try searching by lastName
          if (firstNameResults.isEmpty) {
            await _searchByLastName(searchName);
          } else {
            setState(() {
              _searchResults = firstNameResults;
            });
          }
        } else {
          // Try searching by lastName if firstName search returns no list
          await _searchByLastName(searchName);
        }
      } else {
        // Try searching by lastName if firstName search fails
        await _searchByLastName(searchName);
      }
    } else {
      // Try searching by lastName if firstName search fails
      await _searchByLastName(searchName);
    }
  }

  Future<void> _searchByLastName(String searchName) async {
    final Map<String, String> queryParams = {
      'firstName': '',
      'lastName': searchName,
    };

    final Uri uri = Uri.https(
      'divyangpcmc.altwise.in',
      '/api/aadhar/SearchByName',
      queryParams,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        if (responseData['data'] != null && responseData['data'] is List) {
          setState(() {
            _searchResults = List<dynamic>.from(responseData['data']);
          });

          if (_searchResults.isEmpty) {
            _showValidationErrorDialog(
                'No Aadhar records found with that name');
          }
        } else {
          setState(() {
            _searchResults = [];
          });
          _showValidationErrorDialog('No Aadhar records found with that name');
        }
      } else {
        setState(() {
          _searchResults = [];
        });
        _showValidationErrorDialog(
            responseData['message'] ?? 'No Aadhar records found');
      }
    } else {
      setState(() {
        _searchResults = [];
      });
      _showValidationErrorDialog('Note: No Aadhar Number Found');
    }
  }

  void _selectSearchType(String type) {
    setState(() {
      _selectedSearchType = type;
      _nameController.clear();
      _searchResults = [];
      _hasSearched = false;
    });
  }

  void _goBack() {
    setState(() {
      _selectedSearchType = '';
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
          'Search Aadhar Number',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.yellow,
        centerTitle: true,
        elevation: 4,
        leading: _selectedSearchType.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _goBack,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedSearchType.isEmpty) _buildSearchTypeSelection(),
            if (_selectedSearchType.isNotEmpty) _buildSearchForm(),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_hasSearched && !_isLoading) _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTypeSelection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'Choose how you want to search for Aadhar',
          style: TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        _buildSelectionCard(
          title: 'Search by Aadhar Number',
          subtitle: 'Enter 12-digit Aadhar number',
          icon: Icons.credit_card,
          onTap: () => _selectSearchType('aadhar'),
        ),
        const SizedBox(height: 16),
        _buildSelectionCard(
          title: 'Search by Name',
          subtitle: 'Enter person\'s first name or last name',
          icon: Icons.person_search,
          onTap: () => _selectSearchType('name'),
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
        side: const BorderSide(color: Colors.yellow, width: 1.5),
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
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.black,
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
        side: const BorderSide(color: Colors.yellow, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _selectedSearchType == 'name'
                  ? 'Search by Name'
                  : 'Search by Aadhar Number',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _selectedSearchType == 'name'
                    ? 'Enter Name (First or Last)'
                    : 'Enter Aadhar Number',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_selectedSearchType == 'aadhar'
                    ? Icons.credit_card
                    : Icons.person_search),
              ),
              keyboardType: _selectedSearchType == 'aadhar'
                  ? TextInputType.number
                  : TextInputType.text,
              textCapitalization: _selectedSearchType == 'aadhar'
                  ? TextCapitalization.none
                  : TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchAadhar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedSearchType == 'aadhar'
                      ? 'Search by Aadhar Number'
                      : 'Search Aadhar Number',
                  style: const TextStyle(fontSize: 18, color: Colors.black),
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
    // Handle multiple API response formats
    final String aadharNumber =
        person['AadhaarNumber'] ?? person['AdharCardNo'] ?? 'Not available';
    final String firstName = person['FirstName'] ?? '';
    final String middleName = person['MiddleName'] ?? '';
    final String lastName = person['LastName'] ?? '';
    final String fullName = '$firstName $middleName $lastName'.trim();

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
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Aadhar Number', aadharNumber),
            _buildDetailRow('Full Name', fullName),
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
