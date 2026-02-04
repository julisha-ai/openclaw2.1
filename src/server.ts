// src/server.ts
import http from "http";

const PORT = parseInt(process.env.PORT || "8080", 10);

const server = http.createServer((_req, res) => {
  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("OpenClaw backend is alive!\n");
});

server.listen(PORT, () => {
  console.log(`[openclaw] HTTP server running on port ${PORT}`);
});
