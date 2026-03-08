import express from 'express';
import bodyParser from 'body-parser';
import userRoutes from './routes-ts/user';

const app = express();
const PORT = process.env.PORT || 4000;

app.use(bodyParser.json());

app.use('/api/user', userRoutes);

app.get('/', (req, res) => {
  res.send('SathiAI Node.js backend is running!');
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
