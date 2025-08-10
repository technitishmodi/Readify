import 'package:Readify/bookdetails/bookdetail.dart';
import 'package:flutter/material.dart';

class Bookcard123 extends StatelessWidget {
  final String title;
  final String coverUrl;
  final String auther;
  final String price;
  final String rating;
  final String bookUrl;
   final String description;  
  final String aboutAuthor;  
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const Bookcard123({
    super.key,
    required this.title,
    required this.coverUrl,
    required this.auther,
    required this.price,
    required this.rating,
    required this.bookUrl,
    required this.onTap, this.onDelete, required this.description, required this.aboutAuthor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Bookdetail(
                title: title,
                coverUrl: bookUrl,
                imageUrl: coverUrl,
                author: auther,
                description: description,  
                aboutAuthor: aboutAuthor, 
              ),
            ),
          );
        }, 
        child: Container(
          height: 150, 
          width: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary,
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(4, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    coverUrl,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      Container(
                        width: 100,
                        height: 150,
                        color: Colors.grey,
                        child: const Icon(Icons.broken_image),
                      ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "By: $auther",
                      style: Theme.of(context).textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Price: $price",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        Text(rating),
                        const SizedBox(width: 5),
                        Text("($rating)"),
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
  }
}