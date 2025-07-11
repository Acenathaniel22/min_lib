const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());

// MongoDB connection URI and DB/Collection names
const uri = 'mongodb://localhost:27017'; // Change if your MongoDB is hosted elsewhere
const dbName = 'minlib';
const collectionName = 'verses';

let db, versesCollection;

// Connect to MongoDB
MongoClient.connect(uri, { useUnifiedTopology: true })
  .then(client => {
    db = client.db(dbName);
    versesCollection = db.collection(collectionName);
    app.listen(port, () => {
      console.log(`Backend (MongoDB) listening at http://localhost:${port}`);
    });
  })
  .catch(err => {
    console.error('Failed to connect to MongoDB', err);
    process.exit(1);
  });

// Get all verses
app.get('/verses', async (req, res) => {
  try {
    const verses = await versesCollection.find({}).toArray();
    res.json(verses.map(v => ({
      id: v._id,
      title: v.title,
      content: v.content
    })));
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch verses' });
  }
});

// Add a new verse
app.post('/verses', async (req, res) => {
  const { title, content } = req.body;
  if (!title || !content) {
    return res.status(400).json({ error: 'Title and content are required.' });
  }
  try {
    const result = await versesCollection.insertOne({ title, content });
    res.status(201).json({ id: result.insertedId, title, content });
  } catch (err) {
    res.status(500).json({ error: 'Failed to add verse' });
  }
});
