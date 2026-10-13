const express = require('express');
const router = express.Router();

const db = require('../db');

// ==========================================
// GET: Retrieve all residents
// GET /api/admin/residents
// ==========================================

router.get('/admin/residents', (req, res) => {
  const sql = `
    SELECT
      id,
      name,
      email,
      phone,
      apartment_number,
      block,
      role
    FROM users
    WHERE LOWER(role) = 'resident'
    ORDER BY id DESC
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Residents API error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Unable to retrieve residents.'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Residents retrieved successfully.',
      total: results.length,
      residents: results
    });
  });
});

// ==========================================
// GET: Retrieve one resident by ID
// GET /api/residents/1
// ==========================================

router.get('/residents/:id', (req, res) => {
  const residentId = Number(req.params.id);

  if (!Number.isInteger(residentId) || residentId <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid resident ID.'
    });
  }

  const sql = `
    SELECT
      id,
      name,
      email,
      phone,
      apartment_number,
      block,
      role
    FROM users
    WHERE id = ?
      AND LOWER(role) = 'resident'
    LIMIT 1
  `;

  db.query(sql, [residentId], (err, results) => {
    if (err) {
      console.error('Resident lookup error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Unable to retrieve resident details.'
      });
    }

    if (results.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Resident not found.'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Resident retrieved successfully.',
      resident: results[0]
    });
  });
});

// ==========================================
// PUT: Update resident profile
// PUT /api/residents/1
// ==========================================

router.put('/residents/:id', (req, res) => {
  const residentId = Number(req.params.id);

  const name = String(req.body.name || '').trim();
  const apartmentNumber =
      String(req.body.apartment_number || '').trim();
  const block = String(req.body.block || '').trim();

  if (!Number.isInteger(residentId) || residentId <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid resident ID.'
    });
  }

  if (!name || !apartmentNumber || !block) {
    return res.status(400).json({
      success: false,
      message: 'Name, apartment number and block are required.'
    });
  }

  const sql = `
    UPDATE users
    SET
      name = ?,
      apartment_number = ?,
      block = ?
    WHERE id = ?
      AND LOWER(role) = 'resident'
  `;

  db.query(
    sql,
    [name, apartmentNumber, block, residentId],
    (err, result) => {
      if (err) {
        console.error('Resident update error:', err.message);

        return res.status(500).json({
          success: false,
          message: 'Unable to update resident profile.'
        });
      }

      if (result.affectedRows === 0) {
        return res.status(404).json({
          success: false,
          message: 'Resident not found or no changes were made.'
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Resident profile updated successfully.',
        resident: {
          id: residentId,
          name: name,
          apartment_number: apartmentNumber,
          block: block
        }
      });
    }
  );
});

module.exports = router;