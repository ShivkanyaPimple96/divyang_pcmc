import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/office_login_screens/divyang_detailes_officelogin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class EnterAadharNumberScreenLogin extends StatefulWidget {
  final String userId;
  const EnterAadharNumberScreenLogin({super.key, required this.userId});

  @override
  State<EnterAadharNumberScreenLogin> createState() =>
      _EnterAadharNumberScreenLoginState();
}

class _EnterAadharNumberScreenLoginState
    extends State<EnterAadharNumberScreenLogin> {
  final TextEditingController _aadharController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _apiResponse;
  String _errorMessage = '';

  // --- Search Section State ---
  final TextEditingController _searchController = TextEditingController();
  String _selectedSearchType = '';
  List<dynamic> _searchResults = [];
  bool _isSearchLoading = false;
  bool _hasSearched = false;

  // ===================== HTTP CLIENT =====================

  /// Creates an HTTP client that accepts self-signed / bad certificates.
  /// Use this for ALL API calls in this screen.
  http.Client _createHttpClient() {
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  // ===================== VALIDATION =====================

  String? _validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Aadhar number';
    }
    if (value.length != 12) {
      return 'Aadhar number must be 12 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Aadhar number must contain only digits';
    }
    return null;
  }

  // ===================== FORM SUBMIT =====================

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _checkKycStatus(_aadharController.text);
    }
  }

  // ===================== STEP 1: KYC STATUS =====================

  Future<void> _checkKycStatus(String aadharNumber) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // FIX: use the custom client that bypasses bad certificates
    final client = _createHttpClient();

    try {
      final url = Uri.parse(
          'https://lc.pcmcdivyang.com/api/aadhar/GetKycStatusUsingAadharNumber?AadharNumber=$aadharNumber');

      final response = await client.get(url).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              'Connection timeout. Please check your internet connection.');
        },
      );

      print('KYC Status Code: ${response.statusCode}');
      print('KYC Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String message = data['Message']?.toString() ?? '';

        if (message == 'KYC is not Completed') {
          await _callAadharAPI(aadharNumber);
        } else if (message == 'KYC is Completed') {
          setState(() => _isLoading = false);
          _showPopupMessage('KYC Status', 'KYC is Completed');
        } else {
          setState(() => _isLoading = false);
          _showPopupMessage(
            'KYC Status',
            message.isNotEmpty
                ? message
                : 'Unable to determine KYC status. Please try again.',
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to check KYC status.';
        });
        _showPopupMessage(
            'Note', 'Failed to check KYC status. Please try again.');
      }
    } on SocketException catch (e) {
      print('KYC SocketException: ${e.toString()}');
      setState(() {
        _isLoading = false;
        _errorMessage = 'No internet connection';
      });
      _showPopupMessage('Network Error',
          'No internet connection. Please check your network settings and try again.');
    } on TimeoutException catch (e) {
      print('KYC TimeoutException: ${e.toString()}');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection timeout';
      });
      _showPopupMessage('Timeout Note',
          'Connection timeout. Please check your internet connection and try again.');
    } on http.ClientException catch (e) {
      print('KYC ClientException: ${e.toString()}');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection failed';
      });
      _showPopupMessage('Connection Note',
          'Failed to connect to server. Please check your internet connection and try again.');
    } on FormatException catch (e) {
      print('KYC FormatException: ${e.toString()}');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid response format';
      });
      _showPopupMessage('Note',
          'Received invalid response from server. Please try again later.');
    } catch (e) {
      print('KYC Exception: ${e.toString()}');
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred';
      });
      _showPopupMessage(
          'Note', 'An unexpected error occurred. Please try again.');
    } finally {
      client.close();
    }
  }

  // ===================== STEP 2: AADHAR API =====================

  // Future<void> _callAadharAPI(String aadharNumber) async {
  //   setState(() {
  //     _isLoading = true;
  //     _apiResponse = null;
  //     _errorMessage = '';
  //   });

  //   // This endpoint is HTTP (not HTTPS), but we still use the same client for consistency
  //   final client = _createHttpClient();

  //   try {
  //     final url = Uri.parse(
  //         'http://103.224.247.133:8085/BSUPN/rest/service/getbyAadharNumber?aadharnumber=$aadharNumber');

  //     final response = await client.get(url).timeout(
  //       const Duration(seconds: 30),
  //       onTimeout: () {
  //         throw TimeoutException(
  //             'Connection timeout. Please check your internet connection.');
  //       },
  //     );

  //     print('Status Code: ${response.statusCode}');
  //     print('Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);
  //       setState(() => _apiResponse = data);

  //       if (data['code'] == "200") {
  //         await _storeAadharData(data);
  //       }
  //       else if (data['code'] == "201") {
  //         _showPopupMessage(
  //           'Note',
  //           'Aadhar Number Not Found. Please contact with this number 9156808105.\n आधार नंबर सापडला नाही. कृपया या नंबर वर संपर्क करा 9156808105.',
  //         );
  //       }
  //     } else {
  //       setState(() => _errorMessage = 'Failed to fetch data.');
  //       _showPopupMessage('Note', 'Failed to fetch data. Please try again.');
  //     }
  //   } on SocketException catch (e) {
  //     print('SocketException: ${e.toString()}');
  //     setState(() => _errorMessage = 'No internet connection');
  //     _showPopupMessage('Network Error',
  //         'No internet connection. Please check your network settings and try again.');
  //   } on TimeoutException catch (e) {
  //     print('TimeoutException: ${e.toString()}');
  //     setState(() => _errorMessage = 'Connection timeout');
  //     _showPopupMessage('Timeout Note',
  //         'Connection timeout. Please check your internet connection and try again.');
  //   } on http.ClientException catch (e) {
  //     print('ClientException: ${e.toString()}');
  //     setState(() => _errorMessage = 'Connection failed');
  //     _showPopupMessage('Connection Note',
  //         'Failed to connect to server. Please check your internet connection and try again.');
  //   } on FormatException catch (e) {
  //     print('FormatException: ${e.toString()}');
  //     setState(() => _errorMessage = 'Invalid response format');
  //     _showPopupMessage('Note',
  //         'Received invalid response from server. Please try again later.');
  //   } catch (e) {
  //     print('Exception: ${e.toString()}');
  //     setState(() => _errorMessage = 'An error occurred');
  //     _showPopupMessage(
  //         'Note', 'An unexpected error occurred. Please try again.');
  //   } finally {
  //     setState(() => _isLoading = false);
  //     client.close();
  //   }
  // }

  Future<void> _callAadharAPI(String aadharNumber) async {
    setState(() {
      _isLoading = true;
      _apiResponse = null;
      _errorMessage = '';
    });

    final client = _createHttpClient();

    try {
      final url = Uri.parse(
          'http://103.224.247.133:8085/BSUPN/rest/service/getbyAadharNumber?aadharnumber=$aadharNumber');

      final response = await client.get(url).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              'Connection timeout. Please check your internet connection.');
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() => _apiResponse = data);

        if (data['code'] == "200") {
          final List<dynamic> dataList =
              data['allData'] is List ? data['allData'] : [];

          if (dataList.isEmpty) {
            _showPopupMessage('Error', 'No data available');
            return;
          }

          final aadharData = dataList.first;

          _navigateToPhotoClickScreen(
            avakNo: aadharData['avakNo']?.toString() ?? '',
            adharNo: aadharData['adharNo']?.toString() ?? '',
            name: aadharData['name']?.toString() ?? '',
            mobileNo: aadharData['mobileNo']?.toString() ?? '',
            uniqueKey: aadharData['uniqueKey']?.toString() ?? '',
          );
        } else if (data['code'] == "201") {
          _showPopupMessage(
            'Note',
            'Aadhar Number Not Found. Please contact with this number 9156808105.\n आधार नंबर सापडला नाही. कृपया या नंबर वर संपर्क करा 9156808105.',
          );
        }
      } else {
        setState(() => _errorMessage = 'Failed to fetch data.');
        _showPopupMessage('Note', 'Failed to fetch data. Please try again.');
      }
    } on SocketException catch (e) {
      print('SocketException: ${e.toString()}');
      setState(() => _errorMessage = 'No internet connection');
      _showPopupMessage('Network Error',
          'No internet connection. Please check your network settings and try again.');
    } on TimeoutException catch (e) {
      print('TimeoutException: ${e.toString()}');
      setState(() => _errorMessage = 'Connection timeout');
      _showPopupMessage('Timeout Note',
          'Connection timeout. Please check your internet connection and try again.');
    } on http.ClientException catch (e) {
      print('ClientException: ${e.toString()}');
      setState(() => _errorMessage = 'Connection failed');
      _showPopupMessage('Connection Note',
          'Failed to connect to server. Please check your internet connection and try again.');
    } on FormatException catch (e) {
      print('FormatException: ${e.toString()}');
      setState(() => _errorMessage = 'Invalid response format');
      _showPopupMessage('Note',
          'Received invalid response from server. Please try again later.');
    } catch (e) {
      print('Exception: ${e.toString()}');
      setState(() => _errorMessage = 'An error occurred');
      _showPopupMessage(
          'Note', 'An unexpected error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
      client.close();
    }
  }
  // ===================== STEP 3: STORE AADHAR DATA =====================

  // Future<void> _storeAadharData(Map<String, dynamic> data) async {
  //   // FIX: use the custom client for the HTTPS Store endpoint too
  //   final client = _createHttpClient();

  //   try {
  //     final List<dynamic> dataList =
  //         data['allData'] is List ? data['allData'] : [];

  //     if (dataList.isEmpty) {
  //       _showPopupMessage('Error', 'No data available to store');
  //       return;
  //     }

  //     final aadharData = dataList.first;

  //     final Map<String, dynamic> postData = {
  //       "avakNo": aadharData['avakNo']?.toString() ?? '',
  //       "adharNo": aadharData['adharNo']?.toString() ?? '',
  //       "name": aadharData['name']?.toString() ?? '',
  //       "mobileNo": aadharData['mobileNo']?.toString() ?? '',
  //       "uniqueKey": aadharData['uniqueKey']?.toString() ?? '',
  //     };

  //     print('POST Data: ${json.encode(postData)}');

  //     final url = Uri.parse('https://lc.pcmcdivyang.com/api/aadhar/Store');
  //     final response = await client.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode(postData),
  //     );

  //     print('POST Status Code: ${response.statusCode}');
  //     print('POST Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       _navigateToPhotoClickScreen(
  //         avakNo: postData['avakNo']!,
  //         adharNo: postData['adharNo']!,
  //         name: postData['name']!,
  //         mobileNo: postData['mobileNo']!,
  //         uniqueKey: postData['uniqueKey']!,
  //       );
  //     } else {
  //       _showPopupMessage('Note', 'Failed to store data. Please try again.');
  //     }
  //   } catch (e) {
  //     print('Store Error: ${e.toString()}');
  //     _showPopupMessage('Exception', 'Failed to store data: Please try again.');
  //   } finally {
  //     client.close();
  //   }
  // }

  // ===================== STEP 4: NAVIGATE =====================

  void _navigateToPhotoClickScreen({
    required String avakNo,
    required String adharNo,
    required String name,
    required String mobileNo,
    required String uniqueKey,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DivyangDetailesOfficeloginScreen(
          userId: widget.userId,
          avakNo: avakNo,
          adharNo: adharNo,
          name: name,
          mobileNo: mobileNo,
          uniqueKey: uniqueKey,
          lastSubmit: '',
        ),
      ),
    );
  }

  // ===================== SEARCH SECTION =====================

  void _selectSearchType(String type) {
    setState(() {
      _selectedSearchType = type;
      _searchController.clear();
      _searchResults = [];
      _hasSearched = false;
    });
  }

  void _resetSearch() {
    setState(() {
      _selectedSearchType = '';
      _searchController.clear();
      _searchResults = [];
      _hasSearched = false;
    });
  }

  Future<void> _searchAadhar() async {
    if (_searchController.text.isEmpty) {
      _showPopupMessage(
        'Note',
        'Please enter a ${_selectedSearchType == 'aadhar' ? 'number\nकृपया क्रमांक प्रविष्ट करा.' : 'name\nकृपया नाव प्रविष्ट करा.'}',
      );
      return;
    }

    setState(() {
      _isSearchLoading = true;
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
      setState(() => _searchResults = []);
      _showPopupMessage('Note', 'Failed to search: ${e.toString()}');
    } finally {
      setState(() => _isSearchLoading = false);
    }
  }

  Future<void> _searchByAadharNumber() async {
    // FIX: use the custom client
    final client = _createHttpClient();
    try {
      final Uri uri = Uri.https(
        'lc.pcmcdivyang.com',
        '/api/aadhar/SearchByAadhaarNumber',
        {'aadhaarNo': _searchController.text.trim()},
      );

      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          if (responseData['data'] != null && responseData['data'] is List) {
            setState(() {
              _searchResults = List<dynamic>.from(responseData['data']);
            });
            if (_searchResults.isEmpty) {
              _showPopupMessage(
                  'Note', 'No Aadhar records found with that number');
            }
          } else {
            setState(() => _searchResults = []);
            _showPopupMessage(
                'Note', 'No Aadhar records found with that number');
          }
        } else {
          setState(() => _searchResults = []);
          _showPopupMessage(
              'Note', responseData['message'] ?? 'No Aadhar records found');
        }
      } else {
        setState(() => _searchResults = []);
        _showPopupMessage('Note', 'Note: No Aadhar Number Found');
      }
    } finally {
      client.close();
    }
  }

  Future<void> _searchByName() async {
    final String searchName = _searchController.text.trim();
    // FIX: use the custom client
    final client = _createHttpClient();

    try {
      final Uri uri = Uri.https(
        'lc.pcmcdivyang.com',
        '/api/aadhar/SearchByName',
        {'firstName': searchName, 'lastName': ''},
      );

      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data'] is List) {
          List<dynamic> firstNameResults =
              List<dynamic>.from(responseData['data']);

          if (firstNameResults.isEmpty) {
            await _searchByLastName(searchName, client);
          } else {
            setState(() => _searchResults = firstNameResults);
          }
        } else {
          await _searchByLastName(searchName, client);
        }
      } else {
        await _searchByLastName(searchName, client);
      }
    } finally {
      client.close();
    }
  }

  Future<void> _searchByLastName(String searchName, http.Client client) async {
    final Uri uri = Uri.https(
      'lc.pcmcdivyang.com',
      '/api/aadhar/SearchByName',
      {'firstName': '', 'lastName': searchName},
    );

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true &&
          responseData['data'] != null &&
          responseData['data'] is List) {
        setState(() {
          _searchResults = List<dynamic>.from(responseData['data']);
        });
        if (_searchResults.isEmpty) {
          _showPopupMessage('Note', 'No Aadhar records found with that name');
        }
      } else {
        setState(() => _searchResults = []);
        _showPopupMessage(
            'Note', responseData['message'] ?? 'No Aadhar records found');
      }
    } else {
      setState(() => _searchResults = []);
      _showPopupMessage('Note', 'Note: No Aadhar Number Found');
    }
  }

  // ===================== POPUP =====================

  void _showPopupMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 28),
              const SizedBox(width: 10),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // ===================== BUILD =====================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Enter Aadhar Number Screen',
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.yellow,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.025),
                  const Text(
                    'Enter Aadhar Number (आधार क्रमांक टाका):',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.025),
                  TextFormField(
                    controller: _aadharController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    decoration: InputDecoration(
                      labelText: 'आधार क्रमांक टाका',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.yellow),
                      ),
                      hintText: 'Enter 12-digit Aadhar number',
                    ),
                    validator: _validateAadhar,
                  ),
                  SizedBox(height: height * 0.012),
                  const Text(
                    'Enter your 12-digit Aadhar number without spaces',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  SizedBox(height: height * 0.038),

                  // ── SUBMIT BUTTON ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: EdgeInsets.symmetric(vertical: height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: width * 0.05,
                              height: width * 0.05,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'SUBMIT AADHAR NUMBER\nआधार क्रमांक सबमिट करा',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),

                  if (!_isLoading && _errorMessage.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.02),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),

                  SizedBox(height: height * 0.03),

                  // ── SEARCH SECTION DIVIDER ──
                  const Row(
                    children: [
                      Expanded(child: Divider(thickness: 1.5)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'OR SEARCH',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(thickness: 1.5)),
                    ],
                  ),

                  SizedBox(height: height * 0.025),

                  Text(
                    'आधार क्रमांक किंवा नाव वापरून आधार क्रमांक शोधा',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.025),

                  if (_selectedSearchType.isEmpty)
                    _buildSearchTypeSelection()
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _resetSearch,
                              child: const Icon(Icons.arrow_back,
                                  color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _selectedSearchType == 'aadhar'
                                  ? 'आधार क्रमांकाने शोधा'
                                  : 'नाव टाकून शोधा',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        _buildSearchForm(),
                        SizedBox(height: height * 0.02),
                        if (_isSearchLoading)
                          const Center(child: CircularProgressIndicator()),
                        if (_hasSearched && !_isSearchLoading)
                          _buildSearchResults(),
                      ],
                    ),

                  SizedBox(height: height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTypeSelection() {
    return Column(
      children: [
        _buildSelectionCard(
          title: 'आधार क्रमांकाने शोधा',
          subtitle: '१२-अंकी आधार क्रमांक टाका',
          icon: Icons.credit_card,
          onTap: () => _selectSearchType('aadhar'),
        ),
        const SizedBox(height: 16),
        _buildSelectionCard(
          title: 'तुमचे नाव किंवा आडनाव टाकून शोधा',
          subtitle: "नाव किंवा आडनाव एंटर करा",
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
                child: Icon(icon, size: 32, color: Colors.black),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
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
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: _selectedSearchType == 'name'
                    ? 'नाव किंवा आडनाव टाका'
                    : 'आधार क्रमांक टाका',
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
                onPressed: _isSearchLoading ? null : _searchAadhar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedSearchType == 'aadhar'
                      ? ' सबमिट करा'
                      : ' सबमिट करा ',
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('No results found',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Found ${_searchResults.length} result(s)',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final person = _searchResults[index];
            return _buildPersonCard(person, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildPersonCard(Map<String, dynamic> person, int index) {
    final String aadharNumber =
        person['AadhaarNumber'] ?? person['AdharCardNo'] ?? 'Not available';
    final String firstName = person['FirstName'] ?? '';
    final String middleName = person['MiddleName'] ?? '';
    final String lastName = person['LastName'] ?? '';
    final String fullName = '$firstName $middleName $lastName'.trim();

    // Map search result fields to navigation fields
    final String avakNo =
        person['AvakNo']?.toString() ?? person['avakNo']?.toString() ?? '';
    final String adharNo = person['AadhaarNumber']?.toString() ??
        person['AdharCardNo']?.toString() ??
        person['adharNo']?.toString() ??
        '';
    final String name =
        fullName.isNotEmpty ? fullName : person['name']?.toString() ?? '';
    final String mobileNo =
        person['MobileNo']?.toString() ?? person['mobileNo']?.toString() ?? '';
    final String uniqueKey = person['UniqueKey']?.toString() ??
        person['uniqueKey']?.toString() ??
        '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext ctx) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.black, size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'व्यक्तीची माहिती',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(thickness: 1.5, height: 24),
                    _buildBottomSheetRow(Icons.badge, 'Aadhar No', adharNo),
                    const SizedBox(height: 12),
                    _buildBottomSheetRow(Icons.person, 'Name / नाव', name),
                    const SizedBox(height: 12),
                    _buildBottomSheetRow(Icons.phone, 'Mobile No', mobileNo),
                    const SizedBox(height: 12),
                    _buildBottomSheetRow(Icons.key, 'Unique Key', uniqueKey),
                    const SizedBox(height: 12),
                    _buildBottomSheetRow(
                        Icons.confirmation_number, 'Avak No', avakNo),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF76048).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Result $index',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  const Spacer(),
                  // Tap hint
                  const Icon(Icons.touch_app, color: Colors.grey, size: 18),
                  const SizedBox(width: 4),
                  const Text('Tap for details',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Aadhar Number', aadharNumber),
              _buildDetailRow('Full Name', fullName),
            ],
          ),
        ),
      ),
    );
  }

// Helper for bottom sheet rows
  Widget _buildBottomSheetRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Not available',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
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
            child: Text('$label:',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

  @override
  void dispose() {
    _aadharController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
