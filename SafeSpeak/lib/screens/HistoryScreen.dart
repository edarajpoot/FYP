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
          .orderBy('timeStamp', descending: true)
          .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            debugPrint('No documents found in snapshot');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 48),
                  SizedBox(height: 16),
                  Text('No call history found'),
                ],
              ),
            );
          }

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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.call, color: Colors.blue),
        title: Text(contactName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contactNumber),
            Text(
              DateFormat('MMM dd, yyyy - hh:mm a').format(history.timeStamp),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(history.callStatus.toUpperCase()),
          backgroundColor: history.callStatus == 'accepted'
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
        ),
      ),
    );
  }
}