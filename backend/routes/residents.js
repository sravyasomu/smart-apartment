const express = require('express');
const router = express.Router();

const db = require('../db');

// GET: Retrieve all residents
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

module.exports = router;