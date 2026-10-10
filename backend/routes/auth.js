const express = require('express');
const router = express.Router();
const db = require('../db');

// ==========================================
// REGISTER RESIDENT
// POST /api/register
// ==========================================

router.post('/register', (req, res) => {
  const {
    name,
    email,
    phone,
    apartment_number,
    block,
    password
  } = req.body;

  if (
    !name ||
    !email ||
    !phone ||
    !apartment_number ||
    !block ||
    !password
  ) {
    return res.status(400).json({
      success: false,
      message: 'Please fill all the fields.'
    });
  }

  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      message: 'Password must contain at least 6 characters.'
    });
  }

  const normalizedEmail = email.trim().toLowerCase();

  const checkEmailSql = `
    SELECT id
    FROM users
    WHERE email = ?
    LIMIT 1
  `;

  db.query(checkEmailSql, [normalizedEmail], (err, results) => {
    if (err) {
      console.error('Email check error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Database error.'
      });
    }

    if (results.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Email is already registered.'
      });
    }

    const insertSql = `
      INSERT INTO users (
        name,
        email,
        phone,
        apartment_number,
        block,
        password,
        role
      )
      VALUES (?, ?, ?, ?, ?, ?, 'resident')
    `;

    db.query(
      insertSql,
      [
        name.trim(),
        normalizedEmail,
        phone.trim(),
        apartment_number.trim(),
        block.trim(),
        password
      ],
      (insertErr, result) => {
        if (insertErr) {
          console.error('Registration error:', insertErr.message);

          return res.status(500).json({
            success: false,
            message: 'Failed to create account.'
          });
        }

        return res.status(201).json({
          success: true,
          message: 'Resident account created successfully.',
          userId: result.insertId
        });
      }
    );
  });
});

// ==========================================
// LOGIN RESIDENT OR ADMIN
// POST /api/login
// ==========================================

router.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (
    typeof email !== 'string' ||
    typeof password !== 'string' ||
    !email.trim() ||
    !password
  ) {
    return res.status(400).json({
      success: false,
      message: 'Please enter your email and password.'
    });
  }

  const normalizedEmail = email.trim().toLowerCase();

  const sql = `
    SELECT
      id,
      name,
      email,
      phone,
      apartment_number,
      block,
      role,
      password
    FROM users
    WHERE email = ?
    LIMIT 1
  `;

  db.query(sql, [normalizedEmail], (err, results) => {
    if (err) {
      console.error('Login database error:', err.message);

      return res.status(500).json({
        success: false,
        message: 'Database error during login.'
      });
    }

    if (results.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Account not found. Please check your email.'
      });
    }

    const user = results[0];

    // Current project uses plain-text passwords.
    // Password hashing should be added before production.
    if (password !== user.password) {
      return res.status(401).json({
        success: false,
        message: 'Incorrect password.'
      });
    }

    const role = String(user.role || 'resident').toLowerCase();

    if (role !== 'admin' && role !== 'resident') {
      return res.status(403).json({
        success: false,
        message: 'Your account role is not recognized.'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Login successful.',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        apartment_number: user.apartment_number,
        block: user.block,
        role: role
      }
    });
  });
});

module.exports = router;