import http from 'http';
import express from 'express';
import Server from 'socket.io';
import redisAdapter from 'socket.io-redis';

// Logger
import debug from 'debug';
const log = debug('app:ws');

class CreateWebSocketServer {
  private io: SocketIO.Server;

  constructor() {
    const app = express();
    const server = http.createServer(app);
    this.io = Server(server);

    this.createServer();
  }

  private createServer() {
    this.io.adapter(redisAdapter({ host: 'redis', port: 6379 }));
    this.io.on('connection', socket => {
      socket.on('GET_COMMENT', ({videoId}: {videoId?: string}) => {
        if (!videoId) return;

        const oldRoom = Object.keys(socket.rooms).filter(room => {
          return /V:[a-zA-Z0-9_-]{11}/.test(room);
        });
        if (oldRoom.includes(`V:${videoId}`)) return;

        oldRoom.forEach(room => socket.leave(room));
        socket.join(`V:${videoId}`);
      });
    });
    this.io.listen(process.env.WS_PORT || 3000);
    return;
  }

  public sendComment(data: {videoId: string, comments: any}) {
    this.io.to(`V:${data.videoId}`).emit('COMMENT_UPDATE', data);
    return;
  }
}

const createWebSocketServer = new CreateWebSocketServer();
export { createWebSocketServer };
