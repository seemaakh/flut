const path = require("path");
const express = require("express");
const dotenv = require("dotenv");
const morgan = require("morgan");
const colors = require("colors");
const connectDB = require("./config/db");
const cookieParser = require("cookie-parser");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const bodyParser = require("body-parser");
const errorHandler = require("./middleware/errorHandler");
const app = express();

// Load environment variables
dotenv.config({ path: path.join(__dirname, "config", "config.env") });

// Connect to the database
connectDB();

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: "Too many requests from this IP, please try again later.",
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

// Rate limiter for auth routes (stricter)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: process.env.NODE_ENV === "development" ? 100 : 5, // Avoid blocking dev testing
  message: "Too many login attempts, please try again after 15 minutes.",
  skipSuccessfulRequests: true, // Don't count successful requests
});

// Middleware
app.use(express.json());
app.use(morgan("dev")); // Logging middleware
app.use(cookieParser()); // Cookie parser middleware

// Custom security middleware (compatible with Express v5)
app.use((req, res, next) => {
  // Fields that should not be sanitized (emails, URLs, etc.)
  const skipFields = [
    "email",
    "username",
    "password",
    "mediaUrl",
    "profilePicture",
  ];

  const sanitize = (obj, parentKey = "") => {
    if (obj && typeof obj === "object") {
      for (const key in obj) {
        // Skip sanitization for specific fields
        if (skipFields.includes(key)) {
          continue;
        }

        if (typeof obj[key] === "string") {
          // Prevent NoSQL injection - Remove $ from strings (but keep .)
          obj[key] = obj[key].replace(/\$/g, "");

          // Prevent XSS attacks - Only escape HTML in text fields, not emails/URLs
          if (!obj[key].includes("@") && !obj[key].startsWith("http")) {
            obj[key] = obj[key].replace(/</g, "&lt;").replace(/>/g, "&gt;");
          }
        } else if (typeof obj[key] === "object") {
          sanitize(obj[key], key);
        }
      }
    }
    return obj;
  };

  if (req.body) req.body = sanitize(req.body);
  if (req.params) req.params = sanitize(req.params);
  // Note: req.query is read-only in Express v5, so we skip it

  next();
});

app.use(
  helmet({
    crossOriginResourcePolicy: { policy: "cross-origin" },
  })
); // Security middleware
app.use(bodyParser.urlencoded({ extended: true })); // Parse URL-encoded bodies

// CORS (explicit, from scratch)
// - Allows Flutter web dev server origins like http://localhost:<randomPort>
// - Handles OPTIONS preflight before hitting routes
app.use((req, res, next) => {
  const origin = req.headers.origin;
  const requestedHeaders = req.headers["access-control-request-headers"];

  // Allow all origins (dev-friendly). This avoids Flutter web random-port CORS issues.
  // Note: do NOT send Allow-Credentials together with wildcard origin.
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader(
    "Access-Control-Allow-Methods",
    "GET,POST,PUT,PATCH,DELETE,OPTIONS"
  );
  res.setHeader(
    "Access-Control-Allow-Headers",
    requestedHeaders ? requestedHeaders : "Content-Type, Authorization"
  );

  if (process.env.NODE_ENV === "development" && origin && req.method === "OPTIONS") {
    console.log("CORS preflight:", origin, req.originalUrl);
  }

  // Chrome may send this for localhost-to-localhost requests
  if (req.headers["access-control-request-private-network"]) {
    res.setHeader("Access-Control-Allow-Private-Network", "true");
  }

  if (req.method === "OPTIONS") {
    return res.sendStatus(200);
  }

  next();
});

app.use(limiter); // Apply rate limiting to all requests
app.use(express.static(path.join(__dirname, "public"))); // Serve static files

app.get("/api/v1/health", (req, res) => {
  res.status(200).json({ success: true });
});

// Routes
const batchRoutes = require("./routes/batch_route");
app.use("/api/v1/batches", batchRoutes);

const categoryRoutes = require("./routes/category_route");
app.use("/api/v1/categories", categoryRoutes);

// Apply stricter rate limiting to login endpoint
const studentRoutes = require("./routes/student_route");
app.use("/api/v1/students/login", authLimiter);
app.use("/api/v1/students", studentRoutes);

const itemRoutes = require("./routes/item_route");
app.use("/api/v1/items", itemRoutes);

const commentRoutes = require("./routes/comment_route");
app.use("/api/v1/comments", commentRoutes);

// const userRoutes = require("./routes/userRoutes");
// const productRoutes = require("./routes/productRoutes");
// const orderRoutes = require("./routes/orderRoutes");
// const paymentRoutes = require("./routes/paymentRoutes");
// app.use("/api/v1/users", userRoutes);
// app.use("/api/v1/products", productRoutes);
// app.use("/api/v1/orders", orderRoutes);
// app.use("/api/v1/payments", paymentRoutes);

// Error handling middleware
app.use(errorHandler);

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(
    `Server running in ${process.env.NODE_ENV} mode on port ${PORT}`.green.bold
      .underline
  );
  console.log(`Health check: http://localhost:${PORT}/api/v1/health`.green);
});
