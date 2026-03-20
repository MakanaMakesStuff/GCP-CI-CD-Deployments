const express = require("express");
const os = require('os')
const app = express();
const port = 3000;

// Simple test route
app.get("/", (req, res) => {
  // Docker sets the hostname of each replica to the container id by default
  const containerId = os.hostname(); 
  res.send(`Welcome to GCP CI/CD Demo! Running on container: ${containerId}`);
});

// Listen on 0.0.0.0 so Docker can expose it externally
app.listen(port, "0.0.0.0", () => {
  console.log(`App listening at http://0.0.0.0:${port}`);
});