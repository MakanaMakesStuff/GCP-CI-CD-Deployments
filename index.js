const express = require("express");
const app = express();
const port = 3000;

// Simple test route
app.get("/", (req, res) => {
  res.send("Hello from My Staging App!");
});

// Listen on 0.0.0.0 so Docker can expose it externally
app.listen(port, "0.0.0.0", () => {
  console.log(`App listening at http://0.0.0.0:${port}`);
});