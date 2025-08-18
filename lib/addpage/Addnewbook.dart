import 'package:Readify/components/MytextformField.dart';
import 'package:Readify/components/multilinetextformfield.dart';
import 'package:Readify/controller/Bookcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNewbook extends StatelessWidget {
  const AddNewbook({super.key});

  @override
  Widget build(BuildContext context) {
    BookController bookController = Get.put(BookController());
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              color: Colors.blueAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Icon(Icons.arrow_back),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Back",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Add new Book",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                        ),
                        SizedBox(height: 100),
                        InkWell(
                          onTap: () {
                            bookController.pickImage();
                          },
                          child: Obx(
                            () => Container(
                              height: 190,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: bookController.isImageUploading.value
                                    ? CircularProgressIndicator(
                                        color: Colors.blueAccent)
                                    : bookController.imageUrl.value == ""
                                        ? Icon(Icons.add_a_photo)
                                        : Image.network(
                                            bookController.imageUrl.value),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            onTap: () {
                              bookController.pickPDF();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_sharp,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "PDF",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                      ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Mytextformfield(
                    hintText: 'BookTitle',
                    icon: Icons.book,
                    controller: bookController.title,
                  ),
                  SizedBox(height: 5),
                  Multilinetextformfield(
                    hintText: "Book Description",
                    controller: bookController.des,
                  ),
                  Mytextformfield(
                    hintText: 'Auther Name',
                    icon: Icons.person,
                    controller: bookController.authorname,
                  ),
                  SizedBox(height: 5),
                  Mytextformfield(
                    hintText: 'About Author',
                    icon: Icons.book,
                    controller: bookController.aboutauthor,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Show visibility selection dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Select Book Visibility"),
                                  content: Text("Who should see this book?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        bookController.createBook(visibility: 'private');
                                        Get.snackbar(
                                          'Success', 
                                          'Book added as private',
                                          duration: Duration(seconds: 2),
                                        );
                                      },
                                      child: Text("Private (Only Me)"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showCategorySelectionDialog(context);
                                      },
                                      child: Text("Public (Everyone)"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.post_add_sharp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "PUBLISH",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySelectionDialog(BuildContext context) {
    final categories = [
      {'name': 'Romance', 'icon': Icons.favorite_outline},
      {'name': 'Travel', 'icon': Icons.travel_explore_outlined},
      {'name': 'Horror', 'icon': Icons.psychology_outlined},
      {'name': 'Document', 'icon': Icons.description_outlined},
      {'name': 'Fiction', 'icon': Icons.auto_stories_outlined},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Book Category"),
          content: Text("Choose a category for your public book:"),
          actions: categories.map((category) {
            return TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                BookController bookController = Get.put(BookController());
                bookController.createBook(
                  visibility: 'public',
                  category: category['name'] as String,
                );
                Get.snackbar(
                  'Success', 
                  'Book added as public in ${category['name']} category',
                  duration: Duration(seconds: 2),
                );
              },
              icon: Icon(category['icon'] as IconData, size: 18),
              label: Text(category['name'] as String),
            );
          }).toList(),
        );
      },
    );
  }
}