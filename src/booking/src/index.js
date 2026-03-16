const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');

const app = express();
const PORT = process.env.PORT || 4001;
const NOTIFIER_URL = process.env.NOTIFIER_URL || 'http://gym-notifier:4003';

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

// ── Helper: send notification ─────────────────────────────────────────
async function sendNotification(type, message, data) {
    try {
        await fetch(`${NOTIFIER_URL}/api/notify`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ type, message, data }),
        });
    } catch (err) {
        console.error('Failed to send notification:', err.message);
    }
}

// ── Health check ──────────────────────────────────────────────────────
app.get('/health', async (_req, res) => {
    try {
        await pool.query('SELECT 1');
        res.json({ status: 'ok', service: 'gym-booking', db: 'connected' });
    } catch {
        res.json({ status: 'ok', service: 'gym-booking', db: 'disconnected' });
    }
});

// ── GET /api/classes — list all available classes ─────────────────────
app.get('/api/classes', async (_req, res) => {
    try {
        const [classes] = await pool.query('SELECT * FROM classes');
        const [bookings] = await pool.query('SELECT class_id, COUNT(*) as cnt FROM bookings GROUP BY class_id');
        const bookingMap = {};
        bookings.forEach(b => { bookingMap[b.class_id] = b.cnt; });

        const enriched = classes.map(cls => ({
            ...cls,
            spotsLeft: cls.capacity - (bookingMap[cls.id] || 0),
        }));
        res.json(enriched);
    } catch (err) {
        console.error('DB error:', err.message);
        res.status(500).json({ error: 'Failed to fetch classes' });
    }
});

// ── GET /api/classes/:id — single class details ──────────────────────
app.get('/api/classes/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM classes WHERE id = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Class not found' });
        const cls = rows[0];
        const [bookings] = await pool.query('SELECT COUNT(*) as cnt FROM bookings WHERE class_id = ?', [cls.id]);
        res.json({ ...cls, spotsLeft: cls.capacity - bookings[0].cnt });
    } catch (err) {
        console.error('DB error:', err.message);
        res.status(500).json({ error: 'Failed to fetch class' });
    }
});

// ── POST /api/bookings — book a class ─────────────────────────────────
app.post('/api/bookings', async (req, res) => {
    const { classId, memberName, memberEmail } = req.body;

    if (!classId || !memberName) {
        return res.status(400).json({ error: 'classId and memberName are required' });
    }

    try {
        const [classes] = await pool.query('SELECT * FROM classes WHERE id = ?', [classId]);
        if (classes.length === 0) return res.status(404).json({ error: 'Class not found' });
        const cls = classes[0];

        const [bookingCount] = await pool.query('SELECT COUNT(*) as cnt FROM bookings WHERE class_id = ?', [classId]);
        if (bookingCount[0].cnt >= cls.capacity) {
            return res.status(409).json({ error: 'Class is fully booked' });
        }

        const [result] = await pool.query(
            'INSERT INTO bookings (class_id, class_name, instructor, time, day, member_name, member_email) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [classId, cls.name, cls.instructor, cls.time, cls.day, memberName, memberEmail || '']
        );

        const [rows] = await pool.query('SELECT * FROM bookings WHERE id = ?', [result.insertId]);
        const booking = {
            id: rows[0].id,
            classId: rows[0].class_id,
            className: rows[0].class_name,
            instructor: rows[0].instructor,
            time: rows[0].time,
            day: rows[0].day,
            memberName: rows[0].member_name,
            memberEmail: rows[0].member_email,
            createdAt: rows[0].created_at,
        };

        await sendNotification('booking_confirmed', `${memberName} booked ${cls.name} (${cls.day} ${cls.time})`, booking);
        console.log(`✅ Booking #${booking.id}: ${memberName} → ${cls.name}`);
        res.status(201).json(booking);
    } catch (err) {
        console.error('DB error:', err.message);
        res.status(500).json({ error: 'Failed to create booking' });
    }
});

// ── GET /api/bookings — list all bookings ─────────────────────────────
app.get('/api/bookings', async (_req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM bookings ORDER BY created_at DESC');
        res.json(rows.map(r => ({
            id: r.id,
            classId: r.class_id,
            className: r.class_name,
            instructor: r.instructor,
            time: r.time,
            day: r.day,
            memberName: r.member_name,
            memberEmail: r.member_email,
            createdAt: r.created_at,
        })));
    } catch (err) {
        console.error('DB error:', err.message);
        res.status(500).json({ error: 'Failed to fetch bookings' });
    }
});

// ── DELETE /api/bookings/:id — cancel a booking ──────────────────────
app.delete('/api/bookings/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM bookings WHERE id = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Booking did not found' });

        const cancelled = {
            id: rows[0].id,
            className: rows[0].class_name,
            memberName: rows[0].member_name,
        };

        await pool.query('DELETE FROM bookings WHERE id = ?', [req.params.id]);

        await sendNotification('booking_cancelled', `${cancelled.memberName} cancelled ${cancelled.className}`, cancelled);
        console.log(`❌ Booking #${cancelled.id} cancelled`);
        res.json({ message: 'Booking cancelled', booking: cancelled });
    } catch (err) {
        console.error('DB error:', err.message);
        res.status(500).json({ error: 'Failed to cancel booking' });
    }
});

// ── Start server ──────────────────────────────────────────────────────
app.listen(PORT, '0.0.0.0', () => {
    console.log(`📅 gym-booking running on port ${PORT}`);
});
