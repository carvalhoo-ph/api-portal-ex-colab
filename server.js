const express = require('express');
const cors = require('cors');
const app = express();

// ...existing code...

app.use(cors());

// ...existing code...

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});
