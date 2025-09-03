import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Readify/controller/Bookcontroller.dart';
import 'package:Readify/models/bookmodel.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  final String _adminEmail = 'modinitish905@gmail.com';
  late TabController _tabController;
  final BookController _bookController = Get.find<BookController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkAdminAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkAdminAccess() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.email != _adminEmail) {
      Get.back();
      Get.snackbar(
        'Access Denied',
        'You do not have admin privileges',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildModernAppBar(),
          SliverFillRemaining(
            child: Column(
              children: [
                _buildStatsCards(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTabBar(),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildDashboardTab(),
                              _buildBooksManagementTab(),
                              _buildUsersTab(),
                              _buildAnalyticsTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1E293B),
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF475569)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _refreshAllData,
          tooltip: 'Refresh Data',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildGlassCard(
              Icons.library_books_rounded,
              'Total Books',
              '${_bookController.bookData.length}',
              const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildGlassCard(
              Icons.people_rounded,
              'Active Users',
              '1,234',
              const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildGlassCard(
              Icons.trending_up_rounded,
              'Downloads',
              '5.2K',
              const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(
      IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        tabs: const [
          Tab(text: 'Dashboard'),
          Tab(text: 'Books'),
          Tab(text: 'Users'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            'New book uploaded',
            'Romance novel by Jane Doe',
            Icons.upload_file_rounded,
            const Color(0xFF3B82F6),
          ),
          _buildActivityCard(
            'User registered',
            'john.doe@example.com joined',
            Icons.person_add_rounded,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Backup Data',
                  Icons.backup_rounded,
                  const Color(0xFF8B5CF6),
                  () => _showSnackbar('Backup initiated'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Clear Cache',
                  Icons.clear_all_rounded,
                  const Color(0xFFF59E0B),
                  _clearCache,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksManagementTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Text(
                'Books Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showSnackbar('Export feature coming soon'),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _bookController.bookData.length,
                itemBuilder: (context, index) {
                  final book = _bookController.bookData[index];
                  return _buildModernBookCard(book);
                },
              )),
        ),
      ],
    );
  }

  Widget _buildModernBookCard(Bookmodel book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 80,
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
                  ? Icon(Icons.book, color: Colors.grey[400], size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${book.auther ?? 'Unknown Author'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          book.category ?? 'Uncategorized',
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (book.ratings != null)
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              book.ratings!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<String>(
                    future: _getBookUploaderEmail(book.id),
                    builder: (context, snapshot) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person,
                                size: 12, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Text(
                              'Uploaded by: ${snapshot.data ?? 'Loading...'}',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.more_vert, size: 18),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteBook(book);
                } else if (value == 'edit') {
                  _editBook(book);
                } else if (value == 'view') {
                  _viewBookDetails(book);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility,
                          size: 18, color: Color(0xFF3B82F6)),
                      SizedBox(width: 12),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: Color(0xFFF59E0B)),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)),
                      SizedBox(width: 12),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getBookUploaderEmail(String? bookId) async {
    if (bookId == null) return 'Unknown';

    try {
      // First check main books collection using uploaderId
      final bookDoc =
          await FirebaseFirestore.instance.collection('Book').doc(bookId).get();

      if (bookDoc.exists) {
        final bookData = bookDoc.data();
        print('Book data for $bookId: $bookData'); // Debug log

        final uploaderId = bookData?['uploaderId'];
        print('UploaderId: $uploaderId'); // Debug log

        if (uploaderId != null && uploaderId.isNotEmpty) {
          // Get user details using uploaderId
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uploaderId)
              .get();

          print('User doc exists: ${userDoc.exists}'); // Debug log
          if (userDoc.exists) {
            final userData = userDoc.data();
            print('User data: $userData'); // Debug log
            final email = userData?['email'];
            if (email != null && email.isNotEmpty) {
              return email;
            }
          }
        }

        // Try alternative field names that might be used
        final directEmail = bookData?['uploaderEmail'] ??
            bookData?['userEmail'] ??
            bookData?['email'];
        if (directEmail != null && directEmail.isNotEmpty) {
          return directEmail;
        }
      }

      return 'No uploader found';
    } catch (e) {
      print('Error fetching uploader email: $e');
      return 'Error: ${e.toString()}';
    }
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Text(
                'Users Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _refreshUserData(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final userDoc = snapshot.data!.docs[index];
                  final userData = userDoc.data() as Map<String, dynamic>;
                  return _buildModernUserCard(userData, userDoc.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernUserCard(Map<String, dynamic> userData, String userId) {
    final isAdmin = userData['email'] == 'modinitish905@gmail.com';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
              backgroundImage: userData['photoURL'] != null
                  ? NetworkImage(userData['photoURL'])
                  : null,
              child: userData['photoURL'] == null
                  ? Text(
                      (userData['name'] ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        userData['name'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['email'] ?? 'No email',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time,
                                size: 12, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Text(
                              'Joined: ${_formatDate(userData['createdAt'])}',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isAdmin)
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.more_vert, size: 18),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'view') {
                    _viewUserDetails(userData, userId);
                  } else if (value == 'books') {
                    _viewUserBooks(userId, userData['name'] ?? 'User');
                  } else if (value == 'disable') {
                    _disableUser(userId, userData['name'] ?? 'User');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility,
                            size: 18, color: Color(0xFF3B82F6)),
                        SizedBox(width: 12),
                        Text('View Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'books',
                    child: Row(
                      children: [
                        Icon(Icons.book, size: 18, color: Color(0xFF10B981)),
                        SizedBox(width: 12),
                        Text('View Books'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'disable',
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 18, color: Color(0xFFEF4444)),
                        SizedBox(width: 12),
                        Text('Disable User'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'Unknown';
      }

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _refreshUserData() {
    Get.snackbar(
      'Success',
      'User data refreshed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _viewUserDetails(Map<String, dynamic> userData, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          userData['name'] ?? 'User Details',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (userData['photoURL'] != null)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userData['photoURL']),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Name', userData['name'] ?? 'N/A'),
              _buildDetailRow('Email', userData['email'] ?? 'N/A'),
              _buildDetailRow('User ID', userId),
              _buildDetailRow('Joined', _formatDate(userData['createdAt'])),
              _buildDetailRow('Last Login', _formatDate(userData['lastLogin'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewUserBooks(String userId, String userName) {
    Get.snackbar(
      'Info',
      'Showing books uploaded by $userName',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _disableUser(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Disable User'),
        content: Text('Are you sure you want to disable $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Info',
                'User disable functionality coming soon',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            child: const Text('Disable', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Text(
                'Analytics Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _viewBookRequests(),
                icon: const Icon(Icons.request_page, size: 18),
                label: const Text('Book Requests'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildAnalyticsCard(
                        'Total Books',
                        '${_bookController.bookData.length}',
                        Icons.book,
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .snapshots(),
                        builder: (context, snapshot) {
                          final userCount =
                              snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return _buildAnalyticsCard(
                            'Total Users',
                            '$userCount',
                            Icons.people,
                            const Color(0xFF10B981),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('isOnline', isEqualTo: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final onlineCount =
                              snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return GestureDetector(
                            onTap: () => _showOnlineUsers(),
                            child: _buildAnalyticsCard(
                              'Online Users',
                              '$onlineCount',
                              Icons.circle,
                              const Color(0xFF10B981),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showAllUsers(),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .snapshots(),
                          builder: (context, snapshot) {
                            final userCount = snapshot.hasData
                                ? snapshot.data!.docs.length
                                : 0;
                            return _buildAnalyticsCard(
                              'All Registered',
                              '$userCount',
                              Icons.person_outline,
                              const Color(0xFF8B5CF6),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bookRequests')
                            .snapshots(),
                        builder: (context, snapshot) {
                          final requestCount =
                              snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return _buildAnalyticsCard(
                            'Book Requests',
                            '$requestCount',
                            Icons.request_page,
                            const Color(0xFFEF4444),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAnalyticsCard(
                        'Avg Rating',
                        _getAverageRating(),
                        Icons.star,
                        const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAnalyticsCard(
                        'Most Popular Category',
                        _getMostPopularCategory(),
                        Icons.category,
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: const Text(
                          'More analytics coming soon...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildRecentActivitySection(),
                const SizedBox(height: 24),
                _buildCategoryBreakdownSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) {
            final activities = [
              {
                'action': 'New book uploaded',
                'time': '2 hours ago',
                'icon': Icons.upload_file
              },
              {
                'action': 'User registered',
                'time': '5 hours ago',
                'icon': Icons.person_add
              },
              {
                'action': 'Book deleted',
                'time': '1 day ago',
                'icon': Icons.delete
              },
            ];
            final activity = activities[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      activity['icon'] as IconData,
                      size: 16,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity['action'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Text(
                    activity['time'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownSection() {
    final categoryCount = <String, int>{};
    for (final book in _bookController.bookData) {
      final category = book.category ?? 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (categoryCount.isEmpty)
            const Text(
              'No books available',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...categoryCount.entries.map((entry) {
              final total = _bookController.bookData.length;
              final percentage =
                  total > 0 ? (entry.value / total * 100).round() : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '${entry.value} books ($percentage%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: total > 0 ? entry.value / total : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF3B82F6)),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  String _getMostPopularCategory() {
    if (_bookController.bookData.isEmpty) return 'N/A';

    final categoryCount = <String, int>{};
    for (final book in _bookController.bookData) {
      final category = book.category ?? 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    if (categoryCount.isEmpty) return 'N/A';

    final mostPopular =
        categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    return mostPopular.key;
  }

  String _getAverageRating() {
    if (_bookController.bookData.isEmpty) return 'N/A';

    final ratingsWithValues = _bookController.bookData
        .where((book) => book.ratings != null && book.ratings!.isNotEmpty)
        .map((book) => double.tryParse(book.ratings!) ?? 0)
        .where((rating) => rating > 0)
        .toList();

    if (ratingsWithValues.isEmpty) return 'N/A';

    final average =
        ratingsWithValues.reduce((a, b) => a + b) / ratingsWithValues.length;
    return average.toStringAsFixed(1);
  }

  void _refreshAllData() async {
    try {
      await _bookController.fetchBooks();
      await _bookController.fetchUserBooks();
      Get.snackbar(
        'Success',
        'Data refreshed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _clearCache() {
    Get.snackbar(
      'Success',
      'Cache cleared successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _deleteBook(Bookmodel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (book.id != null) {
                await _bookController.deleteUserBook(book.id!);
              }
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Book deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editBook(Bookmodel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Book',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: book.title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => book.title = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: book.auther,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => book.auther = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: book.category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => book.category = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: book.descriptions,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => book.descriptions = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: book.ratings,
                decoration: const InputDecoration(
                  labelText: 'Rating',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => book.ratings = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                if (book.id != null) {
                  await _bookController.editUserBook(
                    book.id!,
                    newTitle: book.title,
                    newDescription: book.descriptions,
                    newAuthorName: book.auther,
                    newAboutAuthor: book.aboutAuthor,
                  );
                  Navigator.pop(context);
                  Get.snackbar(
                    'Success',
                    'Book updated successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update book',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _viewBookDetails(Bookmodel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          book.title ?? 'Book Details',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (book.imageUrl != null && book.imageUrl!.isNotEmpty)
                Center(
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(book.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Title', book.title ?? 'N/A'),
              _buildDetailRow('Author', book.auther ?? 'N/A'),
              _buildDetailRow('Category', book.category ?? 'N/A'),
              _buildDetailRow('Rating', book.ratings ?? 'N/A'),
              _buildDetailRow('Description',
                  book.descriptions ?? 'No description available'),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: _getBookUploaderEmail(book.id),
                builder: (context, snapshot) {
                  return _buildDetailRow(
                      'Uploaded by', snapshot.data ?? 'Loading...');
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  void _viewBookRequests() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Book Requests',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookRequests')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No book requests found',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final requestData =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  final requestId = snapshot.data!.docs[index].id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                requestData['bookTitle'] ?? 'Unknown Book',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                requestData['status'] ?? 'Pending',
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Requested by: ${requestData['userEmail'] ?? requestData['userName'] ?? 'Unknown User'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date: ${_formatRequestDate(requestData['timestamp'])}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _markRequestAsCompleted(requestId),
                              child: const Text('Mark Complete'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => _deleteRequest(requestId),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatRequestDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'Unknown';
      }

      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _markRequestAsCompleted(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookRequests')
          .doc(requestId)
          .update({'status': 'Completed'});

      Get.snackbar(
        'Success',
        'Request marked as completed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _deleteRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookRequests')
          .doc(requestId)
          .delete();

      Get.snackbar(
        'Success',
        'Request deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showOnlineUsers() {
    Get.snackbar(
      'Info',
      'Showing online users',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _showAllUsers() {
    Get.snackbar(
      'Info',
      'Showing all registered users',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
