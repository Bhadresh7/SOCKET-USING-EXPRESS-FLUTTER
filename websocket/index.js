const http = require("http");
const express = require("express");
const { Server } = require("socket.io");
const cors = require("cors");

// Initialize Express app and server
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // Allow any origin for development (restrict in production)
    methods: ["GET", "POST"],
  },
});

// Middleware
app.use(express.json());
app.use(cors());

// Socket.IO events
io.on("connection", (socket) => {
  console.log(`User connected: ${socket.id}`);

  // Notify the user about their connection
  socket.emit("message", "Welcome to the chat!");

  // Notify all other users about the new connection
  socket.broadcast.emit("message", "A new user has joined the chat.");

  // Listen for messages from a user
  socket.on("message", (data) => {
    console.log(`Message received from ${socket.id}: ${data}`);
    // Broadcast the message to all other users except the sender
    socket.broadcast.emit("message", `User ${socket.id}: ${data}`);
  });

  // Handle user disconnection
  socket.on("disconnect", () => {
    console.log(`User disconnected: ${socket.id}`);
    // Notify all other users about the disconnection
    socket.broadcast.emit("message", `User ${socket.id} has left the chat.`);
  });
});


// Test route to verify the server
app.get("/", (req, res) => {
  res.send("Socket.IO Chat Server is running...");
});

// Start the server
const PORT = 3000;
server.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
