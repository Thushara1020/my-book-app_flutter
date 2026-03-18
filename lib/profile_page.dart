import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "";
  String _bio = "";
  String? _img;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final d = await DatabaseHelper.instance.getProfile();
    setState(() {
      _name = d['name'];
      _bio = d['bio'];
      _img = d['profileImage'];
    });
  }

  void _editProfile() {
    final nC = TextEditingController(text: _name);
    final bC = TextEditingController(text: _bio);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nC, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: bC, decoration: const InputDecoration(labelText: "Bio")),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.updateProfile(nC.text, bC.text, _img);
              _loadData();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)], begin: Alignment.topCenter),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white30,
                  backgroundImage: _img != null ? FileImage(File(_img!)) : null,
                  child: _img == null ? const Icon(Icons.person, size: 70, color: Colors.white) : null,
                ),
                const SizedBox(height: 20),
                
                // Glassmorphism Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(_name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 10),
                            Text(_bio, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                            const Divider(color: Colors.white24, height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStat("15", "Posts"),
                                _buildStat("1.2k", "Followers"),
                                _buildStat("250", "Following"),
                              ],
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: _editProfile,
                              icon: const Icon(Icons.edit),
                              label: const Text("Edit Profile"),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}