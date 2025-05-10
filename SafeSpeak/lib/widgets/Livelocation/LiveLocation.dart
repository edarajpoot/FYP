import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class Livelocation extends StatelessWidget {
  const Livelocation({super.key});

  Future<void> requestContactPermission() async {
  var status = await Permission.contacts.status;
  if (!status.isGranted) {
    await Permission.contacts.request();
  }
}

Future<List<Contact>> getContacts() async {
  await requestContactPermission();
  if (await Permission.contacts.request().isGranted) {
    return await FlutterContacts.getContacts(withProperties: true);
  } else {
    print("Permission denied");
    return [];
  }
}



void showModelLiveLocation(BuildContext context) async {
  List<Contact> contacts = await getContacts();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose contact to send location:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final number = contact.phones.isNotEmpty ? contact.phones.first.number : '';

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(contact.displayName ?? 'No Name'),
                        subtitle: Text(number ?? 'No Number'),
                        trailing: IconButton(
                          icon: const Icon(Icons.send, color: Colors.green),
                          onPressed: () {
                            print('Sending location to $number');
                            // Yahan aap actual location bhejne ka logic lagayenge
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModelLiveLocation(context),
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 180,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Send Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(37, 66, 43, 1),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Image.asset(
                  'assets/images/location.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
