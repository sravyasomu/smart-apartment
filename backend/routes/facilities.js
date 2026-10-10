const express = require('express');
const router = express.Router();

const db = require('../db');

// ==========================================
// GET ALL FACILITIES
// GET /api/facilities
// ==========================================

router.get('/facilities', (req, res) => {
  const sql = `
    SELECT
      id,
      name,
      description,
      opening_time,
      closing_time,
      icon
    FROM facilities
    ORDER BY id ASC
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Get facilities error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Unable to retrieve facilities.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Facilities retrieved successfully.',
      total: results.length,
      facilities: results,
    });
  });
});

// ==========================================
// GET FACILITY BY ID
// GET /api/facilities/:id
// ==========================================

router.get('/facilities/:id', (req, res) => {
  const facilityId = Number(req.params.id);

  if (!Number.isInteger(facilityId) || facilityId <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid facility ID.',
    });
  }

  const sql = `
    SELECT
      id,
      name,
      description,
      opening_time,
      closing_time,
      icon
    FROM facilities
    WHERE id = ?
  `;

  db.query(sql, [facilityId], (err, results) => {
    if (err) {
      console.error('Get facility error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Unable to retrieve facility.',
      });
    }

    if (results.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Facility not found.',
      });
    }

    return res.status(200).json({
      success: true,
      facility: results[0],
    });
  });
});

// ==========================================
// UPDATE FACILITY
// PUT /api/facilities/:id
// ==========================================

router.put('/facilities/:id', (req, res) => {
  const facilityId = Number(req.params.id);

  const {
    name,
    description,
    opening_time,
    closing_time,
    icon,
  } = req.body;

  if (!Number.isInteger(facilityId) || facilityId <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid facility ID.',
    });
  }

  if (typeof name !== 'string' || !name.trim()) {
    return res.status(400).json({
      success: false,
      message: 'Facility name is required.',
    });
  }

  if (
    name.trim().length > 100 ||
    (description != null && typeof description !== 'string') ||
    (opening_time != null && typeof opening_time !== 'string') ||
    (closing_time != null && typeof closing_time !== 'string') ||
    (icon != null && typeof icon !== 'string')
  ) {
    return res.status(400).json({
      success: false,
      message: 'One or more facility fields are invalid.',
    });
  }

  const sql = `
    UPDATE facilities
    SET
      name = ?,
      description = ?,
      opening_time = ?,
      closing_time = ?,
      icon = ?
    WHERE id = ?
  `;

  db.query(
    sql,
    [
      name.trim(),
      description ?? null,
      opening_time ?? null,
      closing_time ?? null,
      icon ?? null,
      facilityId,
    ],
    (err, result) => {
      if (err) {
        console.error('Update facility error:', err.message);

        return res.status(500).json({
          success: false,
          message: 'Unable to update facility.',
        });
      }

      if (result.affectedRows === 0) {
        return db.query(
          'SELECT id FROM facilities WHERE id = ?',
          [facilityId],
          (checkError, rows) => {
            if (checkError) {
              console.error(checkError.message);

              return res.status(500).json({
                success: false,
                message: 'Unable to verify facility.',
              });
            }

            if (rows.length === 0) {
              return res.status(404).json({
                success: false,
                message: 'Facility not found.',
              });
            }

            return res.status(200).json({
              success: true,
              message: 'Facility information is already up to date.',
            });
          }
        );
      }

      return res.status(200).json({
        success: true,
        message: 'Facility updated successfully.',
      });
    }
  );
});

module.exports = router;