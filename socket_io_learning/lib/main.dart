import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  final List<String> messages = []; // Store messages
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize the connection
    socket = IO.io(
      'http://192.168.1.7:3000', // Replace with your backend URL
      IO.OptionBuilder()
          .setTransports(['websocket']) // Use WebSocket only
          .disableAutoConnect() // Disable auto-connect
          .build(),
    );

    // Listen for connection events
    socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    // Listen for incoming messages
    socket.on('message', (data) {
      print('Message from server: $data');
      // Ensure the data is cast to String
      setState(() {
        messages.add(data.toString()); // Explicitly convert to String
      });
    });

    // Connect to the server
    socket.connect();
  }

  @override
  void dispose() {
    // Disconnect the socket and clear the controller
    socket.disconnect();
    messageController.dispose();
    super.dispose();
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      // Emit the message to the server
      socket.emit('message', message);
      setState(() {
        messages.add("You: $message"); // Add your own message to the list
      });
      messageController.clear(); // Clear the input field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket.IO Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: messages[index].startsWith("You:")
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: messages[index].startsWith("You:")
                          ? Colors.blue[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      messages[index],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    sendMessage(messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
