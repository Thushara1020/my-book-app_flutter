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
        primarySwatch: Colors.blue, 
        scaffoldBackgroundColor: Colors.grey[100]
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
      _allPosts = data;
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
    if (_postController.text.isNotEmpty || _selectedImage != null) {
      await DatabaseHelper.instance.createPost({
        'userName': 'User Name', 
        'postContent': _postController.text,
        'imagePath': _selectedImage?.path, 
        'likes': 0
      });
      
      _postController.clear();
      setState(() {
        _selectedImage = null;
      });
      _refreshPosts(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feed'), 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
        elevation: 1
      ),
      body: Column(
        children: [

          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _pickImage, 
                      icon: const Icon(Icons.image, color: Colors.blueAccent)
                    ),
                    Expanded(
                      child: TextField(
                        controller: _postController,
                        decoration: const InputDecoration(
                          hintText: "What's on your mind?",
                          border: InputBorder.none
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _addPost, 
                      icon: const Icon(Icons.send, color: Colors.blue)
                    ),
                  ],
                ),

                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_selectedImage!, height: 100, width: 100, fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          

          Expanded(
            child: ListView.builder(
              itemCount: _allPosts.length,
              itemBuilder: (context, index) {
                final post = _allPosts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  clipBehavior: Clip.antiAlias,
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      if (post['imagePath'] != null)
                        Image.file(
                          File(post['imagePath']),
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,

                          errorBuilder: (context, error, stackTrace) => 
                              const SizedBox.shrink(),
                        ),


                      ListTile(
                        title: Text(
                          post['userName'] ?? 'Unknown User', 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Text(post['postContent'] ?? ''),
                        trailing: const Icon(Icons.favorite_border, color: Colors.redAccent),
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