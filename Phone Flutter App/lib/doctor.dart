import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:medsync/patientdata.dart';

class DoctorPage extends StatefulWidget {
  @override
  _DoctorPageState createState() => _DoctorPageState();
}
List<String> ids_dis = [];
class _DoctorPageState extends State<DoctorPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  List<String> patientIds = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List<String>> fetchPatientIds() async {
    final ref = FirebaseDatabase.instance.ref();
    DataSnapshot snapshot = await ref.child("patient").get();
    if (snapshot.value != null) {
      Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<String> ids = [];
        ids_dis = [];
        for (var patientId in data.keys) {
          if (patientId is String) {
            DataSnapshot snapshot1 = await ref.child("patient/$patientId/general/FirstName/").get();
            ids.add(snapshot1.value as String);
            ids_dis.add(patientId);
          }
        }
        return ids;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient History'),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchPatientIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No patient data available.'));
          } else {
            return Column(
              children: [
                Divider(height: 10,),
                const Text(
                  "Please select a patient id to view details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                Divider(height: 30,),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final patientId = snapshot.data![index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: ListTile(
                          title: Text('Patient ID: $patientId'),
                          tileColor: Colors.teal,
                          onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PatientDetailsPage(patientId: ids_dis![index]),
                                ),
                              );
                            // Handle tapping a patient ID
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
