const express = require("express");
const php = require("node-php");
const path = require("path");
const basicAuth = require("express-basic-auth");
const fs = require("fs");
const app = express();
const PORT = 7878;

const publicDir = path.join(__dirname, "public");

// Read user credentials from file
const userCredentialsFile = path.join(__dirname, "userpasword.config");
const userCredentials = parseUserCredentials(fs.readFileSync(userCredentialsFile, "utf-8"));

// Middleware for basic authentication
app.use(
  basicAuth({
    users: userCredentials,
    challenge: true,
    unauthorizedResponse: "Unauthorized Access!",
  })
);

// Serve index.php when users access the root URL
app.get("/", (req, res) => {
  res.sendFile(path.join(publicDir, "servercontrol"));
});

app.use("/", php.cgi(publicDir));

app.listen(PORT, () => {
  console.info(`Server running on http://localhost:${PORT}`);
});

function parseUserCredentials(fileContent) {
  const lines = fileContent.split("\n");
  const credentials = {};

  lines.forEach((line) => {
    const [username, password] = line.trim().split(":");
    if (username && password) {
      credentials[username] = password;
    }
  });

  return credentials;
}
