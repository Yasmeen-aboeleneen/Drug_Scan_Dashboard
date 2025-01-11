import 'package:dashboard_drug_scan/Core/colors.dart';
import 'package:dashboard_drug_scan/Views/Print/printing_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<List<Map<String, dynamic>>> _fetchUsersData() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('analysis_results').get();
    return snapshot.docs.map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'];
        return {
          'id': doc.id,
          'name': data['userName'] ?? 'Unknown User',
          'email': data['userEmail'] ?? 'No Email',
          'result': data['result'] ?? 'No Result',
          'detectedDrug': data['detectedDrug'] ?? 'No Drug Detected',
          'timestamp': timestamp is Timestamp
              ? timestamp.toDate().toString()
              : 'No Timestamp',
        };
      } else {
        return {
          'id': '',
          'name': 'Unknown User',
          'email': 'No Data',
          'result': 'No Data',
          'detectedDrug': 'No Data',
          'timestamp': 'No Data',
        };
      }
    }).toList();
  }

  // دالة لحذف مستند من Firestore
  Future<void> _deleteDocument(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('analysis_results')
          .doc(documentId)
          .delete();
      print('Document deleted successfully!');
    } catch (e) {
      print('Failed to delete document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: kPrimary,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PrintingScreen()));
          },
          child: Icon(
            Icons.print_outlined,
            color: kveryWhite,
            size: w * .09,
          )),
      backgroundColor: kveryWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.cairo(
              color: kveryWhite,
              fontSize: w * .06,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimary,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsersData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          } else {
            final usersData = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Result')),
                  DataColumn(label: Text('Detected Drug')),
                  DataColumn(label: Text('Timestamp')),
                  DataColumn(label: Text('Delete')),
                ],
                rows: usersData.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(Text(user['name'])),
                      DataCell(Text(user['email'])),
                      DataCell(Text(user['result'])),
                      DataCell(Text(user['detectedDrug'])),
                      DataCell(Text(user['timestamp'])),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: kRed),
                          onPressed: () async {
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                    'Are you sure you want to delete this record?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmDelete == true) {
                              await _deleteDocument(user['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Record deleted successfully!'),
                                ),
                              );
                              // إعادة بناء الواجهة
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminDashboard(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
