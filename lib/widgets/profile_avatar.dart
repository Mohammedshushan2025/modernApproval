import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileAvatar extends StatefulWidget {
  final String imageUrl;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 28,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  Future<bool>? _imageCheckFuture;

  @override
  void initState() {
    super.initState();
    _imageCheckFuture = _checkIfImageExists();
  }

  @override
  void didUpdateWidget(covariant ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.imageUrl != oldWidget.imageUrl) {
      setState(() {
        _imageCheckFuture = _checkIfImageExists();
      });
    }
  }


  Future<bool> _checkIfImageExists() async {
    try {

      final response = await http.head(Uri.parse(widget.imageUrl));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {

      print("Image check failed: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _imageCheckFuture,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey.shade200,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }


        if (snapshot.hasData && snapshot.data == true) {
          return CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage(widget.imageUrl),
          );
        }


        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: Colors.grey.shade200,
          child: Icon(
            Icons.person,
            size: widget.radius,
            color: Colors.grey.shade400,
          ),
        );
      },
    );
  }
}