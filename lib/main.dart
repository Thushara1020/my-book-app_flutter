import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';

void main() => runApp(const MySocialApp());

class MySocialApp extends StatelessWidget {
  const MySocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  List<Map<String, dynamic>> _allPosts = [];
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  void _refreshPosts() async {
    final data = await DatabaseHelper.instance.queryAllPosts();
    setState(() {
      _allPosts = data.reversed.toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _addPost() async {
    // නම සහ පෝස්ට් එක හෝ පින්තූරය තියෙන්න ඕනේ
    if (_nameController.text.isNotEmpty && (_postController.text.isNotEmpty || _selectedImage != null)) {
      
      // දැනට පවතින වෙලාව සහ දිනය ලබා ගැනීම
      String formattedTime = DateTime.now().toString().substring(0, 16); 

      await DatabaseHelper.instance.createPost({
        'userName': _nameController.text, // TextField එකේ නම මෙතනට යනවා
        'postContent': _postController.text,
        'imagePath': _selectedImage?.path,
        'createdAt': formattedTime, 
        'likes': 0
      });

      _postController.clear();
      setState(() {
        _selectedImage = null;
      });
      _refreshPosts();
      FocusScope.of(context).unfocus(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and some content!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Post Entry Section ---
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Your Name",
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _postController,
                        decoration: const InputDecoration(hintText: "What's on your mind?", border: InputBorder.none),
                      ),
                    ),
                    IconButton(onPressed: _pickImage, icon: const Icon(Icons.image, color: Colors.green)),
                    IconButton(
                      onPressed: _addPost,
                      icon: const Icon(Icons.send_rounded, color: Colors.blueAccent),
                    ),
                  ],
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.file(_selectedImage!, height: 100, width: 100, fit: BoxFit.cover),
                  ),
              ],
            ),
          ),

          // --- Feed Section (ඔබ ඉල්ලූ Card එක සහිතව) ---
          Expanded(
            child: ListView.builder(
              itemCount: _allPosts.length,
              itemBuilder: (context, index) {
                final post = _allPosts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          child: Text(post['userName']?[0].toUpperCase() ?? 'U'),
                        ),
                        title: Text(post['userName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                        // මෙන්න මෙතන වෙලාව පෙන්වනවා
                        subtitle: Text(post['createdAt'] ?? ""), 
                      ),
                      
                      if (post['postContent'] != null && post['postContent'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(post['postContent'], style: const TextStyle(fontSize: 15)),
                        ),

                      if (post['imagePath'] != null)
                        Image.file(
                          File(post['imagePath']),
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_border, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 5),
                            Text("${post['likes'] ?? 0} Likes"),
                            const SizedBox(width: 20),
                            const Icon(Icons.chat_bubble_outline, size: 20),
                            const SizedBox(width: 5),
                            const Text("Comment"),
                          ],
                        ),
                      ),
                    ],
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