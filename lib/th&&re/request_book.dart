import 'package:Readify/controller/Bookcontroller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestBookPage extends StatelessWidget {
  final BookController bookController = Get.find();

  RequestBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Request an eBook')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: bookController.requestController,
              decoration: const InputDecoration(
                labelText: 'Book Title',
                hintText: 'Enter the book you want to read',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (user != null) {
                  bookController.requestBook(
                    user.uid,
                    user.displayName ?? 'Anonymous',
                  );
                }
              },
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
