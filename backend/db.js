const mysql = require('mysql2');

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'somu22',
  database: 'smart_apartment'
});

db.connect((err) => {
  if (err) {
    console.error('MySQL connection failed:', err.message);
    return;
  }

  console.log('MySQL connected successfully!');
});

module.exports = db;