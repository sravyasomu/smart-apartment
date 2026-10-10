const express = require('express');
const router = express.Router();

const db = require('../db');

// ==========================================
// GET ADMIN DASHBOARD SUMMARY
// GET /api/admin/dashboard
// ==========================================

router.get('/admin/dashboard', (req, res) => {
  const queries = {
    residents: `
      SELECT COUNT(*) AS total
      FROM users
      WHERE LOWER(role) = 'resident'
    `,

    facilities: `
      SELECT COUNT(*) AS total
      FROM facilities
    `,

    bookings: `
      SELECT COUNT(*) AS total
      FROM bookings
    `,

    pendingBookings: `
      SELECT COUNT(*) AS total
      FROM bookings
      WHERE LOWER(COALESCE(status, 'booked'))
      IN ('pending', 'booked')
    `,

    complaints: `
      SELECT COUNT(*) AS total
      FROM complaints
    `,

    pendingComplaints: `
      SELECT COUNT(*) AS total
      FROM complaints
      WHERE LOWER(COALESCE(status, 'pending'))
      IN ('pending', 'in progress')
    `,

    reminders: `
      SELECT COUNT(*) AS total
      FROM reminders
      WHERE completed = 0 OR completed IS NULL
    `,

    announcements: `
      SELECT COUNT(*) AS total
      FROM announcements
    `
  };

  const results = {};
  const entries = Object.entries(queries);

  let completedQueries = 0;
  let hasError = false;

  entries.forEach(([key, sql]) => {
    db.query(sql, (err, rows) => {
      if (hasError) {
        return;
      }

      if (err) {
        hasError = true;

        console.error(
          `Dashboard query error (${key}):`,
          err.message
        );

        return res.status(500).json({
          success: false,
          message: 'Unable to load dashboard information.'
        });
      }

      results[key] = Number(rows[0].total);

      completedQueries++;

      if (completedQueries === entries.length) {
        return res.status(200).json({
          success: true,
          message: 'Dashboard information retrieved successfully.',
          dashboard: results
        });
      }
    });
  });
});

module.exports = router;