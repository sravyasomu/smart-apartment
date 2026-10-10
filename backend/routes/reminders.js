const express = require('express');
const router = express.Router();
const db = require('../db');

// ==========================================
// GET ALL REMINDERS
// GET /api/admin/reminders
// ==========================================

router.get('/admin/reminders', (req, res) => {
  const sql = `
    SELECT id, title, description, date, time, completed, admin_id
    FROM reminders
    ORDER BY id DESC
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Get reminders error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Unable to retrieve reminders.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Reminders retrieved successfully.',
      total: results.length,
      reminders: results,
    });
  });
});

// ==========================================
// CREATE REMINDER
// POST /api/admin/reminders
// ==========================================

router.post('/admin/reminders', (req, res) => {
  const { title, description, date, time, admin_id } = req.body;

  if (
    typeof title !== 'string' ||
    !title.trim() ||
    typeof description !== 'string' ||
    !description.trim() ||
    !date ||
    !time
  ) {
    return res.status(400).json({
      success: false,
      message: 'Title, description, date, and time are required.',
    });
  }

  const sql = `
    INSERT INTO reminders
      (title, description, date, time, completed, admin_id)
    VALUES (?, ?, ?, ?, 0, ?)
  `;

  db.query(
    sql,
    [
      title.trim(),
      description.trim(),
      date,
      time,
      admin_id || null,
    ],
    (err, result) => {
      if (err) {
        console.error('Create reminder error:', err.message);

        return res.status(500).json({
          success: false,
          message: 'Unable to create reminder.',
        });
      }

      return res.status(201).json({
        success: true,
        message: 'Reminder created successfully.',
        reminderId: result.insertId,
      });
    }
  );
});

// ==========================================
// MARK REMINDER COMPLETED / INCOMPLETE
// PUT /api/admin/reminders/:id/status
// ==========================================

router.put('/admin/reminders/:id/status', (req, res) => {
  const reminderId = Number(req.params.id);
  const completed = req.body.completed;

  if (
    !Number.isInteger(reminderId) ||
    reminderId <= 0 ||
    typeof completed !== 'boolean'
  ) {
    return res.status(400).json({
      success: false,
      message: 'A valid reminder ID and completed status are required.',
    });
  }

  const sql = `
    UPDATE reminders
    SET completed = ?
    WHERE id = ?
  `;

  db.query(
    sql,
    [completed ? 1 : 0, reminderId],
    (err, result) => {
      if (err) {
        console.error('Update reminder error:', err.message);

        return res.status(500).json({
          success: false,
          message: 'Unable to update reminder.',
        });
      }

      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: 'Reminder not found.',
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Reminder status updated successfully.',
      });
    }
  );
});

// ==========================================
// DELETE REMINDER
// DELETE /api/admin/reminders/:id
// ==========================================

router.delete('/admin/reminders/:id', (req, res) => {
  const reminderId = Number(req.params.id);

  if (!Number.isInteger(reminderId) || reminderId <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid reminder ID.',
    });
  }

  db.query(
    'DELETE FROM reminders WHERE id = ?',
    [reminderId],
    (err, result) => {
      if (err) {
        console.error('Delete reminder error:', err.message);

        return res.status(500).json({
          success: false,
          message: 'Unable to delete reminder.',
        });
      }

      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: 'Reminder not found.',
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Reminder deleted successfully.',
      });
    }
  );
});

module.exports = router;