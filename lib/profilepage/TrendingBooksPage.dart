// import 'package:e_book/bookdetails/bookdetail.dart';
// import 'package:e_book/controller/Bookcontroller.dart';
import 'package:Readify/bookdetails/bookdetail.dart';
import 'package:Readify/controller/Bookcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrendingBooksPage extends StatelessWidget {
  final BookController bookController;

  const TrendingBooksPage({super.key, required this.bookController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Trending Books", 
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          )),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: bookController.bookData.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final book = bookController.bookData[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Get.to(() => Bookdetail(
                    coverUrl: book.bookUrl ?? '',
                    title: book.title ?? '',
                    author: book.auther ?? '',
                    description: book.descriptions ?? '',
                    aboutAuthor: book.aboutAuthor ?? '',
                    imageUrl: book.imageUrl ?? '',
                  ));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover with modern styling
                    Container(
                      width: 90,
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                        image: book.imageUrl != null && book.imageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(book.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: book.imageUrl == null || book.imageUrl!.isEmpty
                          ? const Center(
                              child: Icon(Icons.book, 
                                size: 40, 
                                color: Colors.grey),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Book Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "By ${book.auther ?? 'Unknown Author'}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star,
                                      color: Colors.amber,
                                      size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      (double.tryParse(book.ratings ?? '0')?.toStringAsFixed(1)) ?? '0.0',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "\$${book.price?.toStringAsFixed(2) ?? '0.00'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF4E6EFF),
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
            ),
          );
        },
      )),
    );
  }
}