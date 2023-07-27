import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // Import the web_socket_channel package.

void main() {
  runApp(const OpenAIApp());
}

class OpenAIApp extends StatefulWidget {
  const OpenAIApp({super.key});

  @override
  State<OpenAIApp> createState() => _OpenAIAppState();
}

class _OpenAIAppState extends State<OpenAIApp> {
  final TextEditingController _input = TextEditingController();
  final TextEditingController _apiKey = TextEditingController();
  String processedText = '';
  String img_url = '';
  String apiKey = "";

  Future<void> makeAPIRequest(String text, String apiKey) async {
    WebSocketChannel? channel;
    // We use a try - catch statement, because the connection might fail.
    try {
      // Connect to our backend.
      channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));
    } catch (e) {
      // If there is any error that might be because you need to use another connection.
      print("Error on connecting to websocket: " + e.toString());
    }
    // Send message to backend
    final jsonMessage = {'text': text, 'apiKey': apiKey};
    channel?.sink.add(jsonEncode(jsonMessage));

    // Listen for any message from backend
    channel?.stream.listen((event) {
      // Just making sure it is not empty
      if (event != null && event!.isNotEmpty) {
        print(event);
        //event = event.replaceAll("\\n", "\n");
        setState(() {
          final jsonResponse = jsonDecode(event);
          processedText = jsonResponse[
              'processedText']; // Update the processedText state with the received text.
        });
        // Now only close the connection and we are done here!
        channel!.sink.close();
      }
    });
  }

  void copyTextToClipboard(processedText) {
    Clipboard.setData(ClipboardData(text: processedText));
    // Show a toast or any other feedback to the user that the text is copied.
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Text copied to clipboard')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Center(child: Text('QuickScan')),
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                TextField(
                  controller: _apiKey,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.tealAccent),
                    ),
                    labelText: 'Enter API Key',
                    labelStyle: const TextStyle(color: Colors.tealAccent),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _input,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.tealAccent),
                    ),
                    labelText: 'Enter the website link',
                    labelStyle: const TextStyle(color: Colors.tealAccent),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                if (processedText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Text(
                      processedText,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                const SizedBox(height: 100),
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
                    makeAPIRequest(_input.text, _apiKey.text);
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.teal),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Summarize', textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    print("clear Button pressed");
                    setState(() {
                      Text(processedText = '');
                      _input.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.teal),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Clear Response',
                        textAlign: TextAlign.center),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    print("copy Button pressed");
                    setState(() {
                      copyTextToClipboard(processedText);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.teal),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Copy', textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
