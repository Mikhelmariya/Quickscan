import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const OpenAIApp());
}

class OpenAIApp extends StatefulWidget {
  const OpenAIApp({super.key});

  @override
  State<OpenAIApp> createState() => _OpenAIAppState();
}

class _OpenAIAppState extends State<OpenAIApp> {
  TextEditingController _input = TextEditingController();
  String processedText = '';
  String img_url = '';
  String apiKey = "";

  void saveApiKeyToFile() async {
    final file = File('/env.js');
    await file.writeAsString('OPENAI_API_KEY=$apiKey');
  }

  Future<void> makeImage() async {
    const url = 'http://192.168.1.35:4000/processImage';

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'text': _input.text,
      }),
    );
    if (response.statusCode == 200) {
      print("success");
    } else {
      print(
          'image API request  failed with status code ${response.statusCode}');
    }
  }

  Future<void> makeAPIRequest() async {
    const url = 'http://192.168.1.5:3000/processText';
    //  const url = '/processText';

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'text': _input.text,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String? text;
      if (data['processedText'] is String) {
        text = data['processedText'];
      } else if (data['processedText'] is Map) {
        final processedTextResult =
            data['processedText'] as Map<String, dynamic>;
        text = processedTextResult['text'];
      }
      if (text != null) {
        print(text);
        setState(() {
          processedText = text!;
        });
      } else {
        print('Invalid response format');
      }
    } else {
      print('API request failed with status code ${response.statusCode}');
    }
    print(response);
    final data = response.body;
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: Center(child: Text('QuickScan')),
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      apiKey = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.tealAccent),
                    ),
                    labelText: 'Enter API Key',
                    labelStyle: TextStyle(color: Colors.tealAccent),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _input,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.tealAccent),
                    ),
                    labelText: 'Enter the website link',
                    labelStyle: TextStyle(color: Colors.tealAccent),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                if (processedText.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Text(
                      processedText,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () {
                    print("Button pressed");
                    // saveApiKeyToFile();
                    // showDialog(
                    //   context: context,
                    //   builder: (context) => AlertDialog(
                    //     title: Text('API Key Saved'),
                    //     content: Text(
                    //         'Your API key has been saved to the .env file.'),
                    //     actions: [
                    //       ElevatedButton(
                    //         onPressed: () {
                    //           Navigator.pop(context);
                    //         },
                    //         child: Text('OK'),
                    //       ),
                    //     ],
                    //   ),
                    // );
                    //
                    makeAPIRequest();
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Submit', textAlign: TextAlign.center),
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.teal),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    print("clear Button pressed");
                    setState(() {
                      Text(processedText = '');
                    });
                    // saveApiKeyToFile();
                    // showDialog(
                    //   context: context,
                    //   builder: (context) => AlertDialog(
                    //     title: Text('API Key Saved'),
                    //     content: Text(
                    //         'Your API key has been saved to the .env file.'),
                    //     actions: [
                    //       ElevatedButton(
                    //         onPressed: () {
                    //           Navigator.pop(context);
                    //         },
                    //         child: Text('OK'),
                    //       ),
                    //     ],
                    //   ),
                    // );
                    //
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Clear', textAlign: TextAlign.center),
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.teal),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
