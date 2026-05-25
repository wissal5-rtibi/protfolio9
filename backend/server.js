const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config(); //
const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB Atlas connecté ✔️"))
  .catch(err => console.log("Erreur MongoDB ❌", err));
  
  app.listen(5000, () => {
  console.log("Serveur lancé sur le port 5000");
});

// Schéma
const MessageSchema = new mongoose.Schema({
  name: String,
  email: String,
  phone: String,
  subject: String,
  message: String,
  date: { type: Date, default: Date.now }
});

const Message = mongoose.model("Message", MessageSchema);

// Route POST
app.post("/contact", async (req, res) => {
  try {
    const newMessage = new Message(req.body);
    await newMessage.save();
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

app.listen(5000, () => {
  console.log("Serveur lancé sur le port 5000");
});
app.get("/", (req, res) => {
    res.send("Backend is running 🚀");
});