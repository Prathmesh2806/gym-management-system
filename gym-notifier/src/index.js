const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');

const app = express();
const PORT = process.env.PORT || 4003;

app.use(cors());
app.use(express.json());

// ── MySQL connection pool ─────────────────────────────────────────────
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'gymuser',
  password: process.env.DB_PASSWORD || 'gympass',
  database: process.env.DB_NAME || 'gymapp',
  waitForConnections: true,
  connectionLimit: 10,
});

// ── Health check ──────────────────────────────────────────────────────
app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', service: 'gym-notifier', db: 'connected' });
  } catch {
    res.json({ status: 'ok', service: 'gym-notifier', db: 'disconnected' });
  }
});

// ── POST /api/notify — receive a notification event ───────────────────
app.post('/api/notify', async (req, res) => {
  const { type, message, data } = req.body;

  if (!type || !message) {
    return res.status(400).json({ error: 'type and message are required' });
  }

  try {
    const [result] = await pool.query(
      'INSERT INTO notifications (type, message, data) VALUES (?, ?, ?)',
      [type, message, JSON.stringify(data || {})]
    );

    const [rows] = await pool.query('SELECT * FROM notifications WHERE id = ?', [result.insertId]);
    const notification = rows[0];

    console.log(`📢 [${type}] ${message}`);
    res.status(201).json({
      id: notification.id,
      type: notification.type,
      message: notification.message,
      data: typeof notification.data === 'string' ? JSON.parse(notification.data) : notification.data,
      read: notification.is_read,
      timestamp: notification.created_at,
    });
  } catch (err) {
    console.error('DB error:', err.message);
    res.status(500).json({ error: 'Failed to save notification' });
  }
});

// ── GET /api/notifications — list recent notifications ────────────────
app.get('/api/notifications', async (req, res) => {
  const limit = parseInt(req.query.limit) || 50;
  try {
    const [rows] = await pool.query(
      'SELECT * FROM notifications ORDER BY created_at DESC LIMIT ?',
      [limit]
    );
    res.json(rows.map(n => ({
      id: n.id,
      type: n.type,
      message: n.message,
      data: typeof n.data === 'string' ? JSON.parse(n.data) : n.data,
      read: n.is_read,
      timestamp: n.created_at,
    })));
  } catch (err) {
    console.error('DB error:', err.message);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

// ── GET /api/notifications/:id — get single notification ──────────────
app.get('/api/notifications/:id', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM notifications WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ error: 'Notification not found' });
    const n = rows[0];
    res.json({
      id: n.id,
      type: n.type,
      message: n.message,
      data: typeof n.data === 'string' ? JSON.parse(n.data) : n.data,
      read: n.is_read,
      timestamp: n.created_at,
    });
  } catch (err) {
    console.error('DB error:', err.message);
    res.status(500).json({ error: 'Failed to fetch notification' });
  }
});

// ── Start server ──────────────────────────────────────────────────────
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🔔 gym-notifier running on port ${PORT}`);
});
