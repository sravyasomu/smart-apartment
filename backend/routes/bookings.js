const express = require('express');
const router = express.Router();

const db = require('../db');

// ==========================================
// GET ALL BOOKINGS
// GET /api/admin/bookings
// ==========================================

router.get('/admin/bookings', (req, res) => {
  const sql = `
    SELECT
      id,
      resident_name,
      apartment_number,
      facility_name,
      booking_date,
      booking_time,
      status,
      user_id,
      facility_id
    FROM bookings
    ORDER BY id DESC
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Get bookings error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Unable to retrieve bookings.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Bookings retrieved successfully.',
      total: results.length,
      bookings: results,
    });
  });
});

// ==========================================
// UPDATE BOOKING STATUS
// PUT /api/admin/bookings/:id/status
// ==========================================

router.put('/admin/bookings/:id/status', (req, res) => {
  const bookingId = Number(req.params.id);
  const { status } = req.body;

  const allowedStatuses = [
    'Booked',
    'Pending',
    'Confirmed',
    'Cancelled',
    'Completed',
  ];

  if (!Number.isInteger(bookingId) || bookingId <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid booking ID.',
    });
  }

  if (
    typeof status !== 'string' ||
    !allowedStatuses.includes(status)
  ) {
    return res.status(400).json({
      success: false,
      message: 'Invalid booking status.',
    });
  }

  const sql = `
    UPDATE bookings
    SET status = ?
    WHERE id = ?
  `;

  db.query(sql, [status, bookingId], (err, result) => {
    if (err) {
      console.error('Update booking error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Unable to update booking status.',
      });
    }

    if (result.affectedRows === 0) {
      return db.query(
        'SELECT id FROM bookings WHERE id = ?',
        [bookingId],
        (checkError, rows) => {
          if (checkError) {
            return res.status(500).json({
              success: false,
              message: 'Unable to verify booking.',
            });
          }

          if (rows.length === 0) {
            return res.status(404).json({
              success: false,
              message: 'Booking not found.',
            });
          }

          return res.status(200).json({
            success: true,
            message: 'Booking status is already up to date.',
          });
        }
      );
    }

    return res.status(200).json({
      success: true,
      message: 'Booking status updated successfully.',
    });
  });
});

module.exports = router;