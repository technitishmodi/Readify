import 'package:Readify/controller/Bookcontroller.dart';
import 'package:Readify/models/bookmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ThoughtsPage extends StatefulWidget {
  @override
  State<ThoughtsPage> createState() => _ThoughtsPageState();
}

class _ThoughtsPageState extends State<ThoughtsPage> {
  final BookController bookController = Get.find();
  final String inspirationalQuote = 
      "Your thoughts are more than words — they're sparks that inspire, "
      "connect, and shape a community of readers."
      "So share your thought freely";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bookController.fetchThoughts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Thoughts'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Text(
              inspirationalQuote,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          Expanded(
            child: Obx(() {
              if (bookController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (bookController.thoughtPosts.isEmpty) {
                return const Center(
                  child: Text(
                    'No thoughts yet. Be the first to share!',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () => bookController.fetchThoughts(),
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: bookController.thoughtPosts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final thought = bookController.thoughtPosts[index];
                    final currentUser = FirebaseAuth.instance.currentUser;
                    final isOwner = currentUser?.uid == thought.userId;
                    final isLiked = currentUser != null && 
                        thought.likedBy.contains(currentUser.uid);
                    
                    return _buildThoughtCard(
                      context, 
                      thought, 
                      isOwner,
                      isLiked,
                      currentUser?.uid,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
        child: const Icon(Icons.add_comment),
        onPressed: () => _showAddThoughtDialog(context),
      ),
    );
  }

  Widget _buildThoughtCard(
    BuildContext context, 
    ThoughtPost thought, 
    bool isOwner,
    bool isLiked,
    String? userId,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: thought.userPhoto != null 
                      ? NetworkImage(thought.userPhoto!) 
                      : null,
                  child: thought.userPhoto == null 
                      ? const Icon(Icons.person_outline, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thought.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d, y • h:mm a').format(thought.timestamp),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  IconButton(
                    icon: Icon(Icons.delete_outline, 
                      color: Colors.grey.shade500),
                    iconSize: 20,
                    onPressed: () => _showDeleteConfirmation(context, thought.id),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              thought.content,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border, 
                    color: isLiked ? Colors.red : Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: () {
                    if (userId == null) {
                      Get.snackbar(
                        'Login Required',
                        'Please login to like thoughts',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    
                    if (isLiked) {
                      bookController.unlikeThought(thought.id, userId);
                    } else {
                      bookController.likeThought(thought.id, userId);
                    }
                  },
                ),
                Text(
                  thought.likes.toString(),
                  style: TextStyle(
                    color: isLiked ? Colors.red : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.share_outlined, 
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: () {
                    // Share functionality can be added here
                    _shareThought(thought);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareThought(ThoughtPost thought) {
    // Implement your share functionality here
    Get.snackbar(
      'Share',
      'Sharing "${thought.content.substring(0, 20)}..."',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String thoughtId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Thought'),
        content: const Text('Are you sure you want to delete this thought? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (result == true) {
      await bookController.deleteThought(thoughtId);
    }
  }

  void _showAddThoughtDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'Login Required',
        'Please login to share your thoughts',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Share Your Thought',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'What would you like to share with the community?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              Text(
                'Remember to be kind and respectful to others',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final text = textController.text.trim();
                if (text.isEmpty) {
                  Get.snackbar(
                    'Empty Thought',
                    'Please write something to share',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                
                bookController.thoughtController.text = text;
                bookController.postThought(
                  user.uid,
                  user.displayName ?? 'Anonymous',
                  user.photoURL,
                );
                Navigator.pop(context);
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}