const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');

const app = express();
const PORT = process.env.PORT || 4002;
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
        res.json({ status: 'ok', service: 'gym-membership', db: 'connected' });
    } catch {
        res.json({ status: 'ok', service: 'gym-membership', db: 'disconnected' });
    }
});

// ── GET /api/plans — list membership plans ────────────────────────────
app.get('/api/plans', async (_req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM plans');
        res.json(rows.map(p => ({
            ...p,
            features: typeof p.features === 'string' ? JSON.parse(p.features) : p.features,
        })));
    } catch (err) {
        console.error('DB error:', err.message);
        res.status(500).json({ error: 'Failed to fetch plans' });
    }
});

// ── GET /api/plans/:id — single plan ──────────────────────────────────
app.get('/api/plans/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM plans WHERE id = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Plan not found' });
        const p = rows[0];
        res.json({ ...p, features: typeof p.features === 'string' ? JSON.parse(p.features) : p.features });
    } catch (err) {
        console.error('DB error:', err.message);
        res.status(500).json({ error: 'Failed to fetch plan' });
    }
});

// ── POST /api/members — register a new member ────────────────────────
app.post('/api/members', async (req, res) => {
    const { name, email, phone, planId } = req.body;

    if (!name || !email || !planId) {
        return res.status(400).json({ error: 'name, email, and planId are required' });
    }

    try {
        const [plans] = await pool.query('SELECT * FROM plans WHERE id = ?', [planId]);
        if (plans.length === 0) return res.status(404).json({ error: 'Plan not found' });
        const plan = plans[0];

        // Check duplicate email
        const [existing] = await pool.query('SELECT id FROM members WHERE email = ?', [email]);
        if (existing.length > 0) {
            return res.status(409).json({ error: 'A member with this email already exists' });
        }

        const [result] = await pool.query(
            'INSERT INTO members (name, email, phone, plan_id, plan_name, plan_price) VALUES (?, ?, ?, ?, ?, ?)',
            [name, email, phone || '', planId, plan.name, plan.price]
        );

        const [rows] = await pool.query('SELECT * FROM members WHERE id = ?', [result.insertId]);
        const member = {
            id: rows[0].id,
            name: rows[0].name,
            email: rows[0].email,
            phone: rows[0].phone,
            planId: rows[0].plan_id,
            planName: rows[0].plan_name,
            planPrice: parseFloat(rows[0].plan_price),
            status: rows[0].status,
            joinedAt: rows[0].joined_at,
        };

        await sendNotification('member_registered', `New member: ${name} joined with ${plan.name} plan`, member);
        console.log(`🎉 New member #${member.id}: ${name} (${plan.name})`);
        res.status(201).json(member);
    } catch (err) {
        console.error('DB error:', err.message);
        res.status(500).json({ error: 'Failed to register member' });
    }
});

// ── GET /api/members — list all members ───────────────────────────────
app.get('/api/members', async (_req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM members ORDER BY joined_at DESC');
        res.json(rows.map(m => ({
            id: m.id,
            name: m.name,
            email: m.email,
            phone: m.phone,
            planId: m.plan_id,
            planName: m.plan_name,
            planPrice: parseFloat(m.plan_price),
            status: m.status,
            joinedAt: m.joined_at,
        })));
    } catch (err) {
        console.error('DB error:', err.message);
        res.status(500).json({ error: 'Failed to fetch members' });
    }
});

// ── GET /api/members/:id — single member details ─────────────────────
app.get('/api/members/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM members WHERE id = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Member not found' });
        const m = rows[0];
        res.json({
            id: m.id,
            name: m.name,
            email: m.email,
            phone: m.phone,
            planId: m.plan_id,
            planName: m.plan_name,
            planPrice: parseFloat(m.plan_price),
            status: m.status,
            joinedAt: m.joined_at,
        });
    } catch (err) {
        console.error('DB error:', err.message);
        res.status(500).json({ error: 'Failed to fetch member' });
    }
});

// ── GET /api/stats — dashboard stats ──────────────────────────────────
app.get('/api/stats', async (_req, res) => {
    try {
        const [totalRows] = await pool.query('SELECT COUNT(*) as cnt FROM members');
        const [activeRows] = await pool.query("SELECT COUNT(*) as cnt FROM members WHERE status = 'active'");
        const [revenueRows] = await pool.query('SELECT COALESCE(SUM(plan_price), 0) as total FROM members');

        res.json({
            totalMembers: totalRows[0].cnt,
            activeMembers: activeRows[0].cnt,
            totalRevenue: parseFloat(revenueRows[0].total),
        });
    } catch (err) {
        console.error('DB error:', err.message);
        res.status(500).json({ error: 'Failed to fetch stats' });
    }
});

// ── Start server ──────────────────────────────────────────────────────
app.listen(PORT, '0.0.0.0', () => {
    console.log(`💪 gym-membership running on port ${PORT}`);
});
