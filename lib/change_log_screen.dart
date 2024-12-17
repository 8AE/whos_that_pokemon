import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChangeLogScreen extends StatefulWidget {
  ChangeLogScreen({super.key});

  @override
  State<ChangeLogScreen> createState() => _ChangeLogScreenMainState();
}

class _ChangeLogScreenMainState extends State<ChangeLogScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Changelog', style: GoogleFonts.inter(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: DefaultAssetBundle.of(context).loadString('assets/changelog.md'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading changelog'));
            } else {
              final String markdownData = snapshot.data ?? '';
              return Markdown(data: markdownData);
            }
          },
        ),
      ),
    );
  }
}
