import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Dall extends StatefulWidget {
  @override
  _DallState createState() => _DallState();
}

class _DallState extends State<Dall> {
  final TextEditingController _textController = TextEditingController();
  String _generatedImageUrl = '';

  Future<void> generateImage() async {
    final String apiKey = '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'; // Replace with your OpenAI API key
    final String prompt = _textController.text.toString();

    // Make a POST request to OpenAI API to generate image
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'prompt': prompt,
        "n": 1,
        "size": "512x512"
      }),
    );

    if (response.statusCode == 200) {
      // Parse the API response and update the generated image URL
      final responseData = jsonDecode(response.body);
      setState(() {
        _generatedImageUrl = responseData['data'][0]['url'];
      });
    } else {
      // Handle API error
      print('Error generating image: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Generation '),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text input field for entering the prompt
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter text prompt',
              ),
            ),
            SizedBox(height: 16),
            // Button to trigger image generation
            ElevatedButton(
              onPressed: generateImage,
              child: Text('Generate Image'),
            ),
            SizedBox(height: 16),
            // Display the generated image if available
            if (_generatedImageUrl.isNotEmpty)
              Image.network(_generatedImageUrl),
          ],
        ),
      ),
    );
  }
}
