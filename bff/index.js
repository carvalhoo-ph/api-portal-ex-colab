const express = require('express');
const axios = require('axios');

const app = express();
const port = 3000;

app.get('/api/data', async (req, res) => {
  try {
    const response1 = await axios.get('https://api.example.com/service1');
    const response2 = await axios.get('https://api.example.com/service2');
    const response3 = await axios.get('https://api.example.com/service3');
    const response4 = await axios.get('https://api.example.com/service4');

    const combinedData = {
      service1: response1.data,
      service2: response2.data,
      service3: response3.data,
      service4: response4.data,
    };

    res.json(combinedData);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch data' });
  }
});

app.listen(port, () => {
  console.log(`BFF API listening at http://localhost:${port}`);
});
