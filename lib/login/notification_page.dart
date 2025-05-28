import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 1;
  String _searchText = '';
  String _filterOption = 'None';

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> allNotifications = [
    {
      'title': 'New Message',
      'info': 'You received a new message from John.',
      'date': 'April 12, 2025',
      'type': 'Message',
    },
    {
      'title': 'App Update',
      'info': 'Version 2.0.1 is now available.',
      'date': 'April 10, 2025',
      'type': 'Update',
    },
    {
      'title': 'Reminder',
      'info': 'Drink water and walk for 10 mins.',
      'date': 'April 9, 2025',
      'type': 'Reminder',
    },
    {
      'title': 'Challenge',
      'info': 'Complete 10,000 steps today.',
      'date': 'April 6, 2025',
      'type': 'Challenge',
    },
  ];

  List<Map<String, String>> get filteredNotifications {
    return allNotifications.where((item) {
      final matchSearch = item['title']!.toLowerCase().contains(_searchText.toLowerCase()) ||
          item['info']!.toLowerCase().contains(_searchText.toLowerCase());

      final matchFilter = _filterOption == 'None' ||
          (_filterOption == 'Date' && item['date'] != null) ||
          (_filterOption == 'Type' && item['type'] != null);

      return matchSearch && matchFilter;
    }).toList();
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            const Center(
              child: Text(
                "Filter Options",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text("Filter by Date"),
              onTap: () {
                setState(() {
                  _filterOption = 'Date';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Filter by Type"),
              onTap: () {
                setState(() {
                  _filterOption = 'Type';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text("Clear Filter"),
              onTap: () {
                setState(() {
                  _filterOption = 'None';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteNotification(int index) {
    setState(() {
      allNotifications.removeAt(index);
    });
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Message':
        return Icons.message;
      case 'Update':
        return Icons.system_update;
      case 'Reminder':
        return Icons.alarm;
      case 'Challenge':
        return Icons.flag;
      case 'Tip':
        return Icons.lightbulb;
      case 'Promotion':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Message':
        return Colors.blue.shade100;
      case 'Update':
        return Colors.orange.shade100;
      case 'Reminder':
        return Colors.purple.shade100;
      case 'Challenge':
        return Colors.teal.shade100;
      case 'Tip':
        return Colors.green.shade100;
      case 'Promotion':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search notifications...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  onPressed: _showFilterOptions,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final item = filteredNotifications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Slidable(
                    key: ValueKey(item['title']),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) => _deleteNotification(index),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getTypeColor(item['type']!),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(_getTypeIcon(item['type']!), color: const Color(0xFF1E3A8A)),
                        ),
                        title: Text(
                          item['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['info']!),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item['date']!,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
