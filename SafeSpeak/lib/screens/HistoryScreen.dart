import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/model/callHistoryModel.dart';
import 'package:intl/intl.dart'; 

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  late Stream<QuerySnapshot> _callHistoryStream;
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _refreshStream();
  }

  void _refreshStream() {
    setState(() {
      _callHistoryStream = FirebaseFirestore.instance
          .collection('CallHistory')
          .where('userID', isEqualTo: userId)
          // .orderBy('timeStamp', descending: true)
          .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: const Text('Call History',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(37, 66, 43, 1),
              fontSize: 25,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStream,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _callHistoryStream,
        builder: (context, snapshot) {
          // Debug output
          debugPrint('StreamBuilder State - Connection: ${snapshot.connectionState}, HasError: ${snapshot.hasError}, HasData: ${snapshot.hasData}');
          
          if (snapshot.hasError) {
            debugPrint('Stream Error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Error loading call history'),
                  Text(snapshot.error.toString()),
                  ElevatedButton(
                    onPressed: _refreshStream,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

//           if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//   return ListView(
//     children: snapshot.data!.docs.map((doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       final time = (data['timeStamp'] as Timestamp).toDate();
//       final formattedTime = DateFormat.yMd().add_jm().format(time);

//       return ListTile(
//         leading: Icon(Icons.phone),
//         title: Text('Contact ID: ${data['contactID']}'),
//         subtitle: Text('Status: ${data['callStatus']}'),
//         trailing: Text(formattedTime),
//       );
//     }).toList(),
//   );
// }

          debugPrint('Documents found: ${snapshot.data!.docs.length}');
          
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              debugPrint('Document $index data: $data');
              
              try {
                final history = CallHistory.fromMap(doc.id, data);
                
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('EmergencyContacts')
                      .doc(history.contactID)
                      .get(),
                  builder: (context, contactSnapshot) {
                    if (contactSnapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingTile(history);
                    }

                    if (contactSnapshot.hasError) {
                      return _buildErrorTile(history);
                    }

                    return _buildCallHistoryTile(history, contactSnapshot.data);
                  },
                );
              } catch (e) {
                debugPrint('Error parsing document: $e');
                return ListTile(
                  title: const Text('Invalid data format'),
                  subtitle: Text('Document ID: ${doc.id}'),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingTile(CallHistory history) {
    return ListTile(
      leading: const CircularProgressIndicator(),
      title: const Text('Loading contact...'),
      subtitle: Text('Called on ${DateFormat('MMM dd, yyyy').format(history.timeStamp)}'),
    );
  }

  Widget _buildErrorTile(CallHistory history) {
    return ListTile(
      leading: const Icon(Icons.error, color: Colors.red),
      title: const Text('Error loading contact'),
      subtitle: Text('Called on ${DateFormat('MMM dd, yyyy').format(history.timeStamp)}'),
    );
  }

  Widget _buildCallHistoryTile(CallHistory history, DocumentSnapshot? contactData) {
  final contact = contactData?.data() as Map<String, dynamic>?;
  final contactName = contact?['contactName'] ?? 'Unknown';
  final contactNumber = contact?['contactNumber'] ?? '';

  final isAccepted = history.callStatus.toLowerCase() == 'accepted';

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.grey[200],
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          const Icon(Icons.call, color: Color.fromRGBO(37, 66, 43, 1)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contactName,
                  style: const TextStyle(fontSize: 18, color: Color.fromRGBO(37, 66, 43, 1)),
                ),
                const SizedBox(height: 4),
                Text(
                  contactNumber,
                  style: const TextStyle(fontSize: 14, color: Color.fromRGBO(37, 66, 43, 0.8)),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(history.timeStamp),
                  style: const TextStyle(fontSize: 12, color: Color.fromRGBO(37, 66, 43, 0.8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isAccepted ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              history.callStatus.toUpperCase(),
              style: TextStyle(
                color: isAccepted ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}