const express = require('express');
const router = express.Router();
const db = require('../db');

// ==========================================
// RESIDENT: SUBMIT A COMPLAINT
// POST /api/complaints
// ==========================================

router.post('/complaints', (req, res) => {
  const {
    resident_name,
    apartment_number,
    category,
    description,
    date,
    user_id,
  } = req.body;

  if (
    !category ||
    !description ||
    !description.toString().trim()
  ) {
    return res.status(400).json({
      success: false,
      message: 'Category and description are required.',
    });
  }

  const sql = `
    INSERT INTO complaints
    (
      resident_name,
      apartment_number,
      category,
      description,
      date,
      status,
      user_id
    )
    VALUES (?, ?, ?, ?, ?, 'Pending', ?)
  `;

  const values = [
    resident_name || 'Resident',
    apartment_number || 'Not provided',
    category,
    description.toString().trim(),
    date || new Date().toISOString().slice(0, 10),
    user_id || null,
  ];

  db.query(sql, values, (err, result) => {
    if (err) {
      console.error('Submit complaint error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Unable to save complaint.',
      });
    }

    return res.status(201).json({
      success: true,
      message: 'Complaint submitted successfully.',
      complaintId: result.insertId,
    });
  });
});

// ==========================================
// ADMIN: GET ALL COMPLAINTS
// GET /api/admin/complaints
// ==========================================

router.get('/admin/complaints', (req, res) => {
  const sql = `
    SELECT
      id,
      resident_name,
      apartment_number,
      category,
      description,
      date,
      status,
      user_id
    FROM complaints
    ORDER BY id DESC
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Get complaints error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Unable to retrieve complaints.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Complaints retrieved successfully.',
      total: results.length,
      complaints: results,
    });
  });
});

// ==========================================
// ADMIN: UPDATE COMPLAINT STATUS
// PUT /api/admin/complaints/:id/status
// ==========================================

router.put('/admin/complaints/:id/status', (req, res) => {
  const complaintId = Number(req.params.id);
  const { status } = req.body;

  const allowedStatuses = [
    'Pending',
    'In Progress',
    'Resolved',
  ];

  if (!Number.isInteger(complaintId) || complaintId <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid complaint ID.',
    });
  }

  if (
    typeof status !== 'string' ||
    !allowedStatuses.includes(status)
  ) {
    return res.status(400).json({
      success: false,
      message: 'Invalid complaint status.',
    });
  }

  const sql = `
    UPDATE complaints
    SET status = ?
    WHERE id = ?
  `;

  db.query(sql, [status, complaintId], (err, result) => {
    if (err) {
      console.error('Update complaint error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Unable to update complaint status.',
      });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Complaint not found.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Complaint status updated successfully.',
      complaintId: complaintId,
      status: status,
    });
  });
});

module.exports = router;