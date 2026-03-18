import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';
import 'profile_page.dart';

void main() => runApp(const ConnectApp());

class ConnectApp extends StatelessWidget {
  const ConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _postController = TextEditingController();
  List<Map<String, dynamic>> _posts = [];
  String _userName = "User";
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    final p = await DatabaseHelper.instance.queryAllPosts();
    final user = await DatabaseHelper.instance.getProfile();
    setState(() {
      _posts = p;
      _userName = user['name'] ?? "User";
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  void _submitPost() async {
    if (_postController.text.isNotEmpty || _selectedImage != null) {
      await DatabaseHelper.instance.createPost({
        'userName': _userName,
        'postContent': _postController.text,
        'imagePath': _selectedImage?.path,
        'createdAt': "Just now",
        'likes': 0
      });
      _postController.clear();
      setState(() => _selectedImage = null);
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text("Connect", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30, color: Colors.blueAccent),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfilePage())).then((_) => _refreshData()),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [

          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.blue.shade100, child: Text(_userName[0])),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                IconButton(onPressed: _pickImage, icon: const Icon(Icons.photo_library, color: Colors.green)),
                IconButton(onPressed: _submitPost, icon: const Icon(Icons.send, color: Colors.blueAccent)),
              ],
            ),
          ),
          if (_selectedImage != null) Image.file(_selectedImage!, height: 100),
          

          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) => _buildPostCard(_posts[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(post['userName'][0])),
            title: Text(post['userName'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(post['createdAt']),
            trailing: const Icon(Icons.more_horiz),
          ),
          if (post['postContent'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(post['postContent'], style: const TextStyle(fontSize: 16)),
            ),
          if (post['imagePath'] != null)
            Image.file(File(post['imagePath']), width: double.infinity, fit: BoxFit.fitWidth),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await DatabaseHelper.instance.updateLikes(post['id'], post['likes']);
                    _refreshData();
                  },
                  child: Row(children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 22),
                    const SizedBox(width: 5),
                    Text("${post['likes']} Likes"),
                  ]),
                ),
                const Spacer(),
                const Text("1 comment", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.favorite_border), label: const Text("Like")),
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline), label: const Text("Comment")),
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined), label: const Text("Share")),
            ],
          )
        ],
      ),
    );
  }
}