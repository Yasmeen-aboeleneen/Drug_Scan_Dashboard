import 'package:dashboard_drug_scan/Core/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  // دالة لجلب بيانات المستخدمين ونتائج التحليل من Firestore
  Future<List<Map<String, dynamic>>> _fetchUsersData() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('analysis_results').get();
    return snapshot.docs.map((doc) {
      return {
        'name':
            doc['userEmail'], // يمكنك استبدالها باسم المستخدم إذا كان متاحًا
        'email': doc['userEmail'],
        'result': doc['result'],
        'detectedDrug': doc['detectedDrug'],
        'timestamp': doc['timestamp'].toDate().toString(),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
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
                ],
                rows: usersData.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(Text(user['name'])),
                      DataCell(Text(user['email'])),
                      DataCell(Text(user['result'])),
                      DataCell(Text(user['detectedDrug'])),
                      DataCell(Text(user['timestamp'])),
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
