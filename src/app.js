import express from 'express';
import logger from '#configs/logger.js';
import helmet from 'helmet';
import morgan from 'morgan';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import authRoutes from '#routes/auth.routes.js';
import userRoutes from '#routes/user.routes.js';
import securityMiddleware from '#middlewares/security.middleware.js';
const app = express();
app.use(helmet()); // middleware for security headers
app.use(express.json()); // middleware for parsing JSON bodies
app.use(express.urlencoded({ extended: true })); // middleware for parsing URL-encoded bodies
app.use(
  morgan('combined', {
    stream: { write: message => logger.info(message.trim()) },
  })
); // HTTP request logging
app.use(cors()); // Enable CORS for all routes
app.use(cookieParser()); // Middleware for parsing cookies
app.use(securityMiddleware); // Custom security middleware
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  logger.info('Received request at /');
  res.status(200).send('Hello from Acquisitions Service');
});

app.get('/health', (req, res) => {
  logger.info('Health check endpoint hit');
  res.status(200).json({ status: 'ok' , timestamp: new Date().toISOString() , uptime: process.uptime() });
});

app.get("/api" , (req,res) => {
    res.send("API is working");
});

app.use("/api/auth" , authRoutes); // Authentication routes
app.use("/api/users" , userRoutes); // User CRUD routes

app.use((req, res) => {
  logger.warn('404 Not Found: %s %s', req.method, req.originalUrl);
  res.status(404).json({ success: false, message: 'Endpoint not found' });
});

app.use((err, req, res, next) => {
  logger.error('Internal Server Error: %o', err);
  res.status(500).json({ success: false, message: 'Internal Server Error' });
});


export default app;
