import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 1;
  String _searchText = '';
  String _filterOption = 'None';

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> allNotifications = [
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
      'title': 'Update',
      'info': 'Check out the new design layout.',
      'date': 'April 8, 2025',
      'type': 'Update',
    },
    {
      'title': 'Daily Tip',
      'info': 'Take a 5-minute break every hour.',
      'date': 'April 7, 2025',
      'type': 'Tip',
    },
    {
      'title': 'Challenge',
      'info': 'Complete 10,000 steps today.',
      'date': 'April 6, 2025',
      'type': 'Challenge',
    },
    {
      'title': 'Promo',
      'info': 'Get 20% off on Premium Upgrade.',
      'date': 'April 5, 2025',
      'type': 'Promotion',
    },
  ];

  List<Map<String, String>> get filteredNotifications {
    List<Map<String, String>> filtered = allNotifications.where((item) {
      final matchSearch = item['title']!.toLowerCase().contains(_searchText.toLowerCase()) ||
          item['info']!.toLowerCase().contains(_searchText.toLowerCase());

      final matchFilter = _filterOption == 'None' ||
          (_filterOption == 'Date' && item['date'] != null) ||
          (_filterOption == 'Type' && item['type'] != null);

      return matchSearch && matchFilter;
    }).toList();

    return filtered;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Example navigation logic
    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 2) {
      // Navigate to Medication
    } else if (index == 3) {
      // Navigate to Settings
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: const Text(
    'Notifications',
    style: TextStyle(color: Colors.white),
  ),
  backgroundColor: const Color(0xFF1E3A8A),
  iconTheme: const IconThemeData(
    color: Colors.white, // this makes the back button white
  ),
),


      body: Column(
        children: [
          // Search and Filter Row
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

          // Notification List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final item = filteredNotifications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                     leading: const Icon(Icons.notifications, size: 40, color: Color(0xFF1E3A8A)),
                      title: Text(
                        item['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['info']!),
                          const SizedBox(height: 4),
                          Text(
                            item['date']!,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Handle delete
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}
