import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  runApp(MyApp());
}

List<String> ids_dis = [];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PatientDataPage(),
    );
  }
}

class PatientDataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Data'),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchPatientIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No patient data found."));
          } else {
            List<String>? patientIds = snapshot.data;
            return ListView.builder(
              itemCount: patientIds?.length,
              itemBuilder: (context, index) {
                String patientId = patientIds![index];
                return ListTile(
                  title: Text('Patient: $patientId'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PatientDetailsPage(patientId: patientId),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
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
            ids.add(patientId);
          }
        }
        return ids;
      }
    }
    return [];
  }
}

class PatientDetailsPage extends StatelessWidget {
  final String patientId;

  PatientDetailsPage({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Appointments'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentsPage(patientId: patientId),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Daily Data'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DailyDataPage(patientId: patientId),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('General Information'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GeneralInfoPage(patientId: patientId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AppointmentsPage extends StatelessWidget {
  final String patientId;

  AppointmentsPage({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
      ),
      body: FutureBuilder<List>(
        future: fetchAppointments(patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No appointments found."));
          } else {
            List<Map<dynamic, dynamic>>? appointments =
                snapshot.data?.cast<Map>();
            return ListView.builder(
              itemCount: appointments?.length,
              itemBuilder: (context, index) {
                Map<dynamic, dynamic>? appointment = appointments?[index];
                String date = appointment?['date'];
                String doctor = appointment?['doctor'];
                String speciality = appointment?['speciality'];
                List<dynamic>? prescription = appointment?['prescription'];

                // Build a string representation of the prescription.
                String prescriptionText = prescription != null
                    ? prescription.join("\n")
                    : "Prescription not available";

                return Column(
                  children: [
                    ListTile(
                      title: Text('Appointment Date: $date'),
                      subtitle: Text(
                          'Doctor: Doctor Name $doctor\nSpeciality: $speciality'),
                      onTap: () {
                        // Show a dialog with the prescription details.
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Prescription'),
                              content: Text(prescriptionText),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    Divider(),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List> fetchAppointments(String patientId) async {
    final ref = FirebaseDatabase.instance.ref();
    DataSnapshot snapshot =
        await ref.child("patient/$patientId/appointments").get();
    if (snapshot.value != null) {
      List appointments = [];
      if (snapshot.value is List) {
        var snval = snapshot.value;
        if (snval != null) {
          if (snval is List<dynamic>) {
            for (var value in snval) {
              if (value != null && value is Map) {
                appointments.add(value);
              }
            }
          }
        }
      }
      return appointments;
    }
    return [];
  }
}

class DailyDataPage extends StatelessWidget {
  final String patientId;

  DailyDataPage({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Data'),
      ),
      body: FutureBuilder<Map<dynamic, dynamic>>(
        future: fetchDailyData(patientId),
        builder: (context, snapshot) {
          print(snapshot.data);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No daily data found."));
          } else {
            Map<dynamic, dynamic> dailyData = snapshot.data!;
            return ListView.builder(
              itemCount: dailyData.length,
              itemBuilder: (context, index) {
                String date = dailyData.keys.elementAt(index);
                Map<dynamic, dynamic> data = dailyData[date] as Map<dynamic, dynamic>;

                Map<String, num> maxValues = {};

                data.forEach((category, values) {
                  if (values is List) {
                    // Explicitly cast values to List<num>
                    List<num> numericValues = values.cast<num>();
                    num maxValue = numericValues.reduce((value, element) => value > element ? value : element);
                    maxValues[category] = maxValue;
                  }
                });

                // String maxValuesText = "Max Values:\n";
                String maxValuesText = "";

                print("max vals");

                maxValues.forEach((category, maxValue) {
                  maxValuesText += "$category: $maxValue\n";
                });

                return Column(
                  children: [
                    ListTile(
                      title: Text('Date: $date'),
                      subtitle: Text("Click here to see all values."),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Recorded Data'),
                              content: Text(maxValuesText),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    Divider(),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

Future<Map<dynamic, dynamic>> fetchDailyData(String patientId) async {
  final ref = FirebaseDatabase.instance.ref();
  DataSnapshot snapshot = await ref.child("patient/$patientId/dailydata").get();
  if (snapshot.value != null) {
    Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return data;
  }
  return {};
}






class GeneralInfoPage extends StatelessWidget {
  final String patientId;

  GeneralInfoPage({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('General Information'),
      ),
      body: FutureBuilder<Map<dynamic, dynamic>>(
        future: fetchGeneralInfo(patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No general information found."));
          } else {
            Map<dynamic, dynamic>? generalInfo = snapshot.data;
            return ListView(
              children: [
                ListTile(
                  title: Text('First Name'),
                  subtitle: Text(generalInfo?['FirstName']),
                ),
                Divider(),
                ListTile(
                  title: Text('Last Name'),
                  subtitle: Text(generalInfo?['LastName']),
                ),
                Divider(),
                ListTile(
                  title: Text('Gender'),
                  subtitle: Text(generalInfo?['Gender']),
                ),
                Divider(),
                ListTile(
                  title: Text('Height'),
                  subtitle: Text(generalInfo?['Height']),
                ),
                Divider(),
                ListTile(
                  title: Text('Weight'),
                  subtitle: Text(generalInfo?['Weight']),
                ),
                Divider(),
                ListTile(
                  title: Text('Blood Type'),
                  subtitle: Text(generalInfo?['BloodType']),
                ),
                Divider(),
                ListTile(
                  title: Text('Blood Pressure'),
                  subtitle: Text(generalInfo?['BP']),
                ),
                Divider(),
                ListTile(
                  title: Text('DOB'),
                  subtitle: Text(generalInfo?['DOB']),
                ),
                Divider(),
                ListTile(
                  title: Text('Contact Information'),
                  subtitle: Text(
                    'Address: ${generalInfo?['ContactInformation']['Address']}\n' +
                        'Phone Number: ${generalInfo?['ContactInformation']['PhoneNumber']}\n' +
                        'Email Address: ${generalInfo?['ContactInformation']['EmailAddress']}',
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('Emergency Contact'),
                  subtitle: Text(
                    'Name: ${generalInfo?['EmergencyContact']['Name']}\n' +
                        'Relationship: ${generalInfo?['EmergencyContact']['Relationship']}\n' +
                        'Contact Information: ${generalInfo?['EmergencyContact']['ContactInformation']['Address']}\n' +
                        'Phone Number: ${generalInfo?['EmergencyContact']['ContactInformation']['PhoneNumber']}',
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<Map<dynamic, dynamic>> fetchGeneralInfo(String patientId) async {
    final ref = FirebaseDatabase.instance.ref();
    DataSnapshot snapshot = await ref.child("patient/$patientId/general").get();
    if (snapshot.value != null) {

      return snapshot.value as Map<dynamic, dynamic>;
    }
    return {};
  }
}
