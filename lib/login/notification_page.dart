import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _searchController = TextEditingController();
  String _searchText = '';
  String _filterOption = 'None';
  String _selectedTypeFilter = '';

  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('bracelet-sensors');

  List<Map<String, String>> _notifications = [];
  Map<String, bool> _previousStates = {
    'fall_detected': false,
    'fire_detected': false,
    'touch_detected': false,
    'button_pressed': false,
  };

  @override
  void initState() {
    super.initState();
    _listenToSensorChanges();
  }

  void _listenToSensorChanges() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final now = DateFormat('MMMM d, yyyy – h:mm a').format(DateTime.now());

      final alertTypes = {
        'fall_detected': {
          'title': 'Fall Detected',
          'info': 'Maybe the patient has fallen! Please check him/her',
          'type': 'Fall'
        },
        'fire_detected': {
          'title': 'Fire Detected',
          'info': 'Possible fire near patient!',
          'type': 'Fire'
        },
        'touch_detected': {
          'title': 'Touch Detected',
          'info': 'Touch alert triggered.',
          'type': 'Touch'
        },
        'button_pressed': {
          'title': 'Emergency Button Pressed',
          'info': 'Patient pressed the emergency button.',
          'type': 'Button'
        },
      };

      alertTypes.forEach((key, value) {
        bool current = data[key] == true;
        bool previous = _previousStates[key] ?? false;

        if (!previous && current) {
          setState(() {
            _notifications.insert(0, {
              'title': value['title']!,
              'info': value['info']!,
              'type': value['type']!,
              'date': now,
            });
          });
        }

        _previousStates[key] = current;
      });
    });
  }

  List<Map<String, String>> get _filteredNotifications {
    return _notifications.where((item) {
      final matchesSearch = item['title']!.toLowerCase().contains(_searchText.toLowerCase()) ||
          item['info']!.toLowerCase().contains(_searchText.toLowerCase());

      final matchesType = _filterOption != 'Type' || _selectedTypeFilter.isEmpty
          ? true
          : item['type'] == _selectedTypeFilter;

      return matchesSearch && matchesType;
    }).toList();
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
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
              child: Text("Filter Options",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Filter by Type"),
              onTap: () {
                Navigator.pop(context);
                _showTypeFilterOptions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text("Clear Filter"),
              onTap: () {
                setState(() {
                  _filterOption = 'None';
                  _selectedTypeFilter = '';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeFilterOptions() {
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
              child: Text("Select Alert Type",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ...['Fall', 'Fire', 'Touch', 'Button'].map((type) {
              return ListTile(
                leading: Icon(_getTypeIcon(type)),
                title: Text(type),
                onTap: () {
                  setState(() {
                    _filterOption = 'Type';
                    _selectedTypeFilter = type;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text("Clear Type Filter"),
              onTap: () {
                setState(() {
                  _filterOption = 'None';
                  _selectedTypeFilter = '';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Fall':
        return Icons.warning;
      case 'Fire':
        return Icons.local_fire_department;
      case 'Touch':
        return Icons.touch_app;
      case 'Button':
        return Icons.emergency;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Fall':
        return Colors.orange.shade100;
      case 'Fire':
        return Colors.red.shade100;
      case 'Touch':
        return Colors.green.shade100;
      case 'Button':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
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
                    onChanged: (value) => setState(() => _searchText = value),
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
              itemCount: _filteredNotifications.length,
              itemBuilder: (context, index) {
                final item = _filteredNotifications[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          child: Icon(_getTypeIcon(item['type']!),
                              color: const Color(0xFF1E3A8A)),
                        ),
                        title: Text(item['title']!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['info']!),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item['date']!,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
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
