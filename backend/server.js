const express = require('express');
const cors = require('cors');
require('dotenv').config();

const db = require('./db');

// ==========================================
// IMPORT ROUTES
// ==========================================

const authRoutes = require('./routes/auth');
const facilitiesRoutes = require('./routes/facilities');
const dashboardRoutes = require('./routes/dashboard');
const residentsRoutes = require('./routes/residents');
const bookingsRoutes = require('./routes/bookings');
const complaintsRoutes = require('./routes/complaints');
const announcementsRoutes = require('./routes/announcements');

// ==========================================
// CREATE EXPRESS APP
// ==========================================

const app = express();
const PORT = 3000;

// ==========================================
// CORS CONFIGURATION
// ==========================================

app.use(
  cors({
    origin: '*',
    methods: [
      'GET',
      'POST',
      'PUT',
      'PATCH',
      'DELETE',
      'OPTIONS',
    ],
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'Accept',
    ],
  })
);

// Parse JSON request bodies
app.use(express.json());

// ==========================================
// WELCOME ROUTE
// ==========================================

app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Smart Apartment Backend is running!',
  });
});

// ==========================================
// TEST DATABASE CONNECTION
// ==========================================

app.get('/api/test-db', (req, res) => {
  db.query('SELECT 1 AS result', (err, results) => {
    if (err) {
      console.error('Database connection error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Database connection failed.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Database connected successfully!',
      result: results[0].result,
    });
  });
});

// ==========================================
// REGISTER AND LOGIN ROUTES
// ==========================================

app.use('/api', authRoutes);

// ==========================================
// FACILITIES MANAGEMENT ROUTES
// ==========================================

app.use('/api', facilitiesRoutes);

// ==========================================
// ADMIN DASHBOARD ROUTES
// ==========================================

app.use('/api', dashboardRoutes);

// ==========================================
// RESIDENTS MANAGEMENT ROUTES
// ==========================================

app.use('/api', residentsRoutes);

// ==========================================
// BOOKINGS MANAGEMENT ROUTES
// ==========================================

app.use('/api', bookingsRoutes);

// ==========================================
// COMPLAINTS MANAGEMENT ROUTES
// ==========================================

app.use('/api', complaintsRoutes);

// ==========================================
// ANNOUNCEMENTS MANAGEMENT ROUTES
// ==========================================

app.use('/api', announcementsRoutes);

// ==========================================
// TEST ROUTE REGISTRATION
// ==========================================

app.get('/api/complaints-test', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Complaints route registration is working!',
  });
});

app.get('/api/announcements-test', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Announcements test route is working!',
  });
});

app.get('/api/dashboard-test', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Dashboard test route is working!',
  });
});

// ==========================================
// HANDLE INVALID ROUTES
// ==========================================

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route not found: ${req.method} ${req.originalUrl}`,
  });
});

// ==========================================
// HANDLE UNEXPECTED SERVER ERRORS
// ==========================================

app.use((err, req, res, next) => {
  console.error(
    'Server error:',
    err.stack || err.message
  );

  res.status(500).json({
    success: false,
    message: 'An internal server error occurred.',
  });
});

// ==========================================
// START SERVER
// ==========================================

app.listen(PORT, () => {
  console.log('====================================');
  console.log('Smart Apartment Backend Started');
  console.log(`Server URL: http://localhost:${PORT}`);
  console.log(`API URL: http://localhost:${PORT}/api`);
  console.log('Announcements routes registered.');
  console.log('====================================');
});