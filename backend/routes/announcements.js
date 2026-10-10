const express = require('express');
const router = express.Router();
const db = require('../db');

// ==========================================
// GET ALL ANNOUNCEMENTS
// GET /api/admin/announcements
// ==========================================

router.get('/admin/announcements', (req, res) => {
  const sql = `
    SELECT id, title, description, date, admin_id
    FROM announcements
    ORDER BY id DESC
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Get announcements error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Unable to retrieve announcements.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Announcements retrieved successfully.',
      total: results.length,
      announcements: results,
    });
  });
});

// ==========================================
// CREATE ANNOUNCEMENT
// POST /api/admin/announcements
// ==========================================

router.post('/admin/announcements', (req, res) => {
  const { title, description, date, admin_id } = req.body;

  if (
    typeof title !== 'string' ||
    !title.trim() ||
    typeof description !== 'string' ||
    !description.trim()
  ) {
    return res.status(400).json({
      success: false,
      message: 'Title and description are required.',
    });
  }

  const sql = `
    INSERT INTO announcements
      (title, description, date, admin_id)
    VALUES (?, ?, ?, ?)
  `;

  db.query(
    sql,
    [
      title.trim(),
      description.trim(),
      date || new Date().toISOString().slice(0, 10),
      admin_id || null,
    ],
    (err, result) => {
      if (err) {
        console.error('Create announcement error:', err.message);

        return res.status(500).json({
          success: false,
          message: 'Unable to create announcement.',
        });
      }

      return res.status(201).json({
        success: true,
        message: 'Announcement created successfully.',
        announcementId: result.insertId,
      });
    }
  );
});

// ==========================================
// DELETE ANNOUNCEMENT
// DELETE /api/admin/announcements/:id
// ==========================================

router.delete('/admin/announcements/:id', (req, res) => {
  const announcementId = Number(req.params.id);

  if (!Number.isInteger(announcementId) || announcementId <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid announcement ID.',
    });
  }

  db.query(
    'DELETE FROM announcements WHERE id = ?',
    [announcementId],
    (err, result) => {
      if (err) {
        console.error('Delete announcement error:', err.message);

        return res.status(500).json({
          success: false,
          message: 'Unable to delete announcement.',
        });
      }

      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: 'Announcement not found.',
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Announcement deleted successfully.',
      });
    }
  );
});

module.exports = router;