import 'package:flutter/material.dart';

class SearchAadharNumberScreen extends StatefulWidget {
  final String? name;
  final String? aadhaarNumber;
  final String? address;

  const SearchAadharNumberScreen({
    super.key,
    this.name,
    this.aadhaarNumber,
    this.address,
  });

  @override
  State<SearchAadharNumberScreen> createState() =>
      _SearchAadharNumberScreenState();
}

class _SearchAadharNumberScreenState extends State<SearchAadharNumberScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _allRecords = [];
  List<Map<String, String>> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();

    // Pre-populate search if name or aadhaar number is provided
    if (widget.name != null && widget.name!.isNotEmpty) {
      _searchController.text = widget.name!;
      _searchAadhaar(widget.name!);
    } else if (widget.aadhaarNumber != null &&
        widget.aadhaarNumber!.isNotEmpty) {
      _searchController.text = widget.aadhaarNumber!;
      _searchAadhaar(widget.aadhaarNumber!);
    }
  }

  void _loadSampleData() {
    // Sample data - Replace with your actual data source (API, database, etc.)
    _allRecords = [
      {
        'name': 'Rajesh Kumar',
        'aadhaarNumber': '1234 5678 9012',
        'address': 'Mumbai, Maharashtra',
      },
      {
        'name': 'Priya Sharma',
        'aadhaarNumber': '2345 6789 0123',
        'address': 'Delhi, Delhi',
      },
      {
        'name': 'Amit Patel',
        'aadhaarNumber': '3456 7890 1234',
        'address': 'Ahmedabad, Gujarat',
      },
      {
        'name': 'Rajesh Singh',
        'aadhaarNumber': '4567 8901 2345',
        'address': 'Pune, Maharashtra',
      },
      {
        'name': 'Sneha Verma',
        'aadhaarNumber': '5678 9012 3456',
        'address': 'Bangalore, Karnataka',
      },
    ];
    _filteredRecords = _allRecords;
  }

  void _searchAadhaar(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _allRecords;
      } else {
        // Remove spaces from query for number matching
        String cleanQuery = query.replaceAll(' ', '');

        _filteredRecords = _allRecords.where((record) {
          // Search by name (case-insensitive)
          bool matchesName =
              record['name']!.toLowerCase().contains(query.toLowerCase());

          // Search by Aadhaar number (with or without spaces)
          String cleanAadhaar = record['aadhaarNumber']!.replaceAll(' ', '');
          bool matchesAadhaar = cleanAadhaar.contains(cleanQuery);

          // Return true if either name or aadhaar matches
          return matchesName || matchesAadhaar;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size - same as PhotoClickScreen
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Search Aadhar Number',
            style: TextStyle(
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Name or Aadhaar Number',
                hintStyle: TextStyle(fontSize: width * 0.04),
                prefixIcon: Icon(Icons.search, size: width * 0.06),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: width * 0.06),
                        onPressed: () {
                          _searchController.clear();
                          _searchAadhaar('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _searchAadhaar,
            ),
          ),
          Expanded(
            child: _filteredRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: width * 0.16,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          'No records found',
                          style: TextStyle(
                            fontSize: width * 0.045,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredRecords.length,
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    itemBuilder: (context, index) {
                      final record = _filteredRecords[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: height * 0.015),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.03),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(width * 0.04),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            radius: width * 0.06,
                            child: Text(
                              record['name']![0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: width * 0.045,
                              ),
                            ),
                          ),
                          title: Text(
                            record['name']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.04,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: height * 0.01),
                              Row(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    size: width * 0.04,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Text(
                                    record['aadhaarNumber']!,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: width * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.005),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: width * 0.04,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Expanded(
                                    child: Text(
                                      record['address']!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: width * 0.033,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
