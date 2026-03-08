import { useState, useEffect, useCallback } from 'react';

// ── API Helpers ───────────────────────────────────────────────────────
const API = {
    async get(url) {
        const res = await fetch(url);
        if (!res.ok) throw new Error(`GET ${url} failed`);
        return res.json();
    },
    async post(url, body) {
        const res = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body),
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Request failed');
        return data;
    },
    async del(url) {
        const res = await fetch(url, { method: 'DELETE' });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Request failed');
        return data;
    },
};

// ── Toast Component ───────────────────────────────────────────────────
function Toast({ message, type, onClose }) {
    useEffect(() => {
        const t = setTimeout(onClose, 3000);
        return () => clearTimeout(t);
    }, [onClose]);
    const icons = { success: '✅', error: '❌', info: 'ℹ️' };
    return (
        <div className={`toast ${type}`}>
            <span>{icons[type] || '📢'}</span>
            <span>{message}</span>
        </div>
    );
}

// ── Dashboard Page ────────────────────────────────────────────────────
function Dashboard({ classes, bookings, members, notifications }) {
    const totalSpots = classes.reduce((a, c) => a + c.capacity, 0);
    const bookedSpots = bookings.length;
    const revenue = members.reduce((a, m) => a + (m.planPrice || 0), 0);

    return (
        <div>
            <div className="page-header">
                <h1>Dashboard</h1>
                <p>Overview of your gym operations</p>
            </div>

            <div className="stats-grid">
                <div className="stat-card">
                    <div className="stat-icon">📅</div>
                    <div className="stat-value">{classes.length}</div>
                    <div className="stat-label">Classes Available</div>
                </div>
                <div className="stat-card">
                    <div className="stat-icon">🎫</div>
                    <div className="stat-value">{bookedSpots}</div>
                    <div className="stat-label">Active Bookings</div>
                </div>
                <div className="stat-card">
                    <div className="stat-icon">👥</div>
                    <div className="stat-value">{members.length}</div>
                    <div className="stat-label">Members</div>
                </div>
                <div className="stat-card">
                    <div className="stat-icon">💰</div>
                    <div className="stat-value">${revenue.toFixed(0)}</div>
                    <div className="stat-label">Total Revenue</div>
                </div>
            </div>

            <div className="section-title">🔔 Recent Activity</div>
            {notifications.length === 0 ? (
                <div className="empty-state">
                    <div className="empty-icon">📭</div>
                    <p>No activity yet. Book a class or register a member to get started!</p>
                </div>
            ) : (
                notifications.slice(0, 5).map((n) => (
                    <div key={n.id} className="notification-item">
                        <div className={`notification-icon ${n.type.includes('booking') ? 'booking' : n.type.includes('cancel') ? 'cancel' : 'member'}`}>
                            {n.type === 'booking_confirmed' ? '📅' : n.type === 'booking_cancelled' ? '❌' : '🎉'}
                        </div>
                        <div className="notification-body">
                            <div className="notif-message">{n.message}</div>
                            <div className="notif-time">{new Date(n.timestamp).toLocaleString()}</div>
                        </div>
                    </div>
                ))
            )}
        </div>
    );
}

// ── Classes Page ──────────────────────────────────────────────────────
function ClassesPage({ classes, onBook }) {
    return (
        <div>
            <div className="page-header">
                <h1>Gym Classes</h1>
                <p>Browse and book available classes</p>
            </div>
            <div className="card-grid">
                {classes.map((cls) => {
                    const spotsLeft = cls.spotsLeft ?? cls.capacity;
                    const spotClass = spotsLeft === 0 ? 'full' : spotsLeft <= 3 ? 'limited' : 'available';
                    return (
                        <div key={cls.id} className="class-card">
                            <div className="class-day">{cls.day}</div>
                            <div className="class-name">{cls.name}</div>
                            <div className="class-meta">
                                <span>🕐 {cls.time} · {cls.duration} min</span>
                                <span>👤 {cls.instructor}</span>
                            </div>
                            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                                <span className={`spots-badge ${spotClass}`}>
                                    {spotsLeft === 0 ? 'Full' : `${spotsLeft} spots left`}
                                </span>
                                <button className="btn btn-primary btn-sm" disabled={spotsLeft === 0} onClick={() => onBook(cls)}>
                                    Book Now
                                </button>
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    );
}

// ── Bookings Page ─────────────────────────────────────────────────────
function BookingsPage({ bookings, onCancel }) {
    return (
        <div>
            <div className="page-header">
                <h1>My Bookings</h1>
                <p>Manage your class reservations</p>
            </div>
            {bookings.length === 0 ? (
                <div className="empty-state">
                    <div className="empty-icon">📋</div>
                    <p>No bookings yet. Head to Classes to book your first session!</p>
                </div>
            ) : (
                bookings.map((b) => (
                    <div key={b.id} className="booking-item">
                        <div className="booking-info">
                            <h4>{b.className}</h4>
                            <span>👤 {b.memberName} · 🕐 {b.day} {b.time}</span>
                        </div>
                        <button className="btn btn-danger btn-sm" onClick={() => onCancel(b.id)}>
                            Cancel
                        </button>
                    </div>
                ))
            )}
        </div>
    );
}

// ── Members Page ──────────────────────────────────────────────────────
function MembersPage({ members, plans, onRegister }) {
    return (
        <div>
            <div className="page-header">
                <h1>Memberships</h1>
                <p>Plans and members</p>
            </div>

            <div className="section-title">💳 Available Plans</div>
            <div className="card-grid" style={{ marginBottom: 32 }}>
                {plans.map((plan, i) => (
                    <div key={plan.id} className={`plan-card ${i === 2 ? 'featured' : ''}`}>
                        <div className="plan-name">{plan.name}</div>
                        <div className="plan-duration">{plan.duration}</div>
                        <div className="plan-price">
                            ${plan.price}<span>/period</span>
                        </div>
                        <ul className="plan-features">
                            {plan.features.map((f, j) => (
                                <li key={j}>✓ {f}</li>
                            ))}
                        </ul>
                        <button className="btn btn-primary btn-block" onClick={() => onRegister(plan)}>
                            Join Now
                        </button>
                    </div>
                ))}
            </div>

            <div className="section-title">👥 Members ({members.length})</div>
            {members.length === 0 ? (
                <div className="empty-state">
                    <div className="empty-icon">👤</div>
                    <p>No members registered yet.</p>
                </div>
            ) : (
                members.map((m) => (
                    <div key={m.id} className="member-item">
                        <div className="member-avatar">{m.name.charAt(0).toUpperCase()}</div>
                        <div className="member-info">
                            <h4>{m.name}</h4>
                            <span>{m.email} · {m.planName}</span>
                        </div>
                    </div>
                ))
            )}
        </div>
    );
}

// ── Notifications Page ────────────────────────────────────────────────
function NotificationsPage({ notifications }) {
    return (
        <div>
            <div className="page-header">
                <h1>Notifications</h1>
                <p>Activity log from all services</p>
            </div>
            {notifications.length === 0 ? (
                <div className="empty-state">
                    <div className="empty-icon">🔔</div>
                    <p>No notifications yet.</p>
                </div>
            ) : (
                notifications.map((n) => (
                    <div key={n.id} className="notification-item">
                        <div className={`notification-icon ${n.type.includes('booking') ? 'booking' : n.type.includes('cancel') ? 'cancel' : 'member'}`}>
                            {n.type === 'booking_confirmed' ? '📅' : n.type === 'booking_cancelled' ? '❌' : '🎉'}
                        </div>
                        <div className="notification-body">
                            <div className="notif-message">{n.message}</div>
                            <div className="notif-time">{new Date(n.timestamp).toLocaleString()}</div>
                        </div>
                    </div>
                ))
            )}
        </div>
    );
}

// ── Book Modal ────────────────────────────────────────────────────────
function BookModal({ cls, onClose, onSubmit }) {
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        await onSubmit({ classId: cls.id, memberName: name, memberEmail: email });
        setLoading(false);
    };

    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal" onClick={(e) => e.stopPropagation()}>
                <h2>Book: {cls.name}</h2>
                <p style={{ color: 'var(--text-secondary)', marginBottom: 20, fontSize: 14 }}>
                    {cls.day} at {cls.time} · {cls.duration} min · {cls.instructor}
                </p>
                <form onSubmit={handleSubmit}>
                    <div className="form-group">
                        <label htmlFor="book-name">Your Name</label>
                        <input id="book-name" type="text" required value={name} onChange={(e) => setName(e.target.value)} placeholder="John Doe" />
                    </div>
                    <div className="form-group">
                        <label htmlFor="book-email">Email (optional)</label>
                        <input id="book-email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="john@example.com" />
                    </div>
                    <div className="modal-actions">
                        <button type="button" className="btn btn-secondary" onClick={onClose}>Cancel</button>
                        <button type="submit" className="btn btn-primary" disabled={!name || loading}>
                            {loading ? 'Booking…' : 'Confirm Booking'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}

// ── Register Modal ────────────────────────────────────────────────────
function RegisterModal({ plan, onClose, onSubmit }) {
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [phone, setPhone] = useState('');
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        await onSubmit({ name, email, phone, planId: plan.id });
        setLoading(false);
    };

    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal" onClick={(e) => e.stopPropagation()}>
                <h2>Join: {plan.name}</h2>
                <p style={{ color: 'var(--text-secondary)', marginBottom: 20, fontSize: 14 }}>
                    ${plan.price} / {plan.duration}
                </p>
                <form onSubmit={handleSubmit}>
                    <div className="form-group">
                        <label htmlFor="reg-name">Full Name</label>
                        <input id="reg-name" type="text" required value={name} onChange={(e) => setName(e.target.value)} placeholder="Jane Smith" />
                    </div>
                    <div className="form-group">
                        <label htmlFor="reg-email">Email</label>
                        <input id="reg-email" type="email" required value={email} onChange={(e) => setEmail(e.target.value)} placeholder="jane@example.com" />
                    </div>
                    <div className="form-group">
                        <label htmlFor="reg-phone">Phone (optional)</label>
                        <input id="reg-phone" type="tel" value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="+1 555-0123" />
                    </div>
                    <div className="modal-actions">
                        <button type="button" className="btn btn-secondary" onClick={onClose}>Cancel</button>
                        <button type="submit" className="btn btn-primary" disabled={!name || !email || loading}>
                            {loading ? 'Registering…' : 'Register'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}

// ── Main App ──────────────────────────────────────────────────────────
export default function App() {
    const [page, setPage] = useState('dashboard');
    const [classes, setClasses] = useState([]);
    const [bookings, setBookings] = useState([]);
    const [members, setMembers] = useState([]);
    const [plans, setPlans] = useState([]);
    const [notifications, setNotifications] = useState([]);
    const [toast, setToast] = useState(null);
    const [bookModal, setBookModal] = useState(null);
    const [registerModal, setRegisterModal] = useState(null);

    const showToast = useCallback((message, type = 'success') => {
        setToast({ message, type });
    }, []);

    // ── Fetch all data ──────────────────────────────────────────────────
    const refresh = useCallback(async () => {
        try {
            const [cls, bk, mem, pl, notif] = await Promise.all([
                API.get('/api/classes'),
                API.get('/api/bookings'),
                API.get('/api/members'),
                API.get('/api/plans'),
                API.get('/api/notifications'),
            ]);
            setClasses(cls);
            setBookings(bk);
            setMembers(mem);
            setPlans(pl);
            setNotifications(notif);
        } catch (err) {
            console.error('Failed to fetch data:', err);
        }
    }, []);

    useEffect(() => {
        refresh();
        const interval = setInterval(refresh, 5000); // auto-refresh
        return () => clearInterval(interval);
    }, [refresh]);

    // ── Actions ─────────────────────────────────────────────────────────
    const handleBook = async (data) => {
        try {
            await API.post('/api/bookings', data);
            showToast('Class booked successfully!');
            setBookModal(null);
            refresh();
        } catch (err) {
            showToast(err.message, 'error');
        }
    };

    const handleCancelBooking = async (id) => {
        try {
            await API.del(`/api/bookings/${id}`);
            showToast('Booking cancelled');
            refresh();
        } catch (err) {
            showToast(err.message, 'error');
        }
    };

    const handleRegister = async (data) => {
        try {
            await API.post('/api/members', data);
            showToast('Member registered successfully!');
            setRegisterModal(null);
            refresh();
        } catch (err) {
            showToast(err.message, 'error');
        }
    };

    // ── Navigation ──────────────────────────────────────────────────────
    const navItems = [
        { id: 'dashboard', icon: '📊', label: 'Dashboard' },
        { id: 'classes', icon: '🏋️', label: 'Classes' },
        { id: 'bookings', icon: '📋', label: 'Bookings' },
        { id: 'members', icon: '👥', label: 'Members' },
        { id: 'notifications', icon: '🔔', label: 'Notifications' },
    ];

    // ── Render Page ─────────────────────────────────────────────────────
    const renderPage = () => {
        switch (page) {
            case 'dashboard':
                return <Dashboard classes={classes} bookings={bookings} members={members} notifications={notifications} />;
            case 'classes':
                return <ClassesPage classes={classes} onBook={(cls) => setBookModal(cls)} />;
            case 'bookings':
                return <BookingsPage bookings={bookings} onCancel={handleCancelBooking} />;
            case 'members':
                return <MembersPage members={members} plans={plans} onRegister={(plan) => setRegisterModal(plan)} />;
            case 'notifications':
                return <NotificationsPage notifications={notifications} />;
            default:
                return <Dashboard classes={classes} bookings={bookings} members={members} notifications={notifications} />;
        }
    };

    return (
        <div className="app">
            {/* Sidebar */}
            <aside className="sidebar">
                <div className="sidebar-brand">
                    <div className="sidebar-brand-icon">💪</div>
                    <div className="sidebar-brand-text">FitZone</div>
                </div>
                <nav className="sidebar-nav">
                    {navItems.map((item) => (
                        <button key={item.id} className={`nav-item ${page === item.id ? 'active' : ''}`} onClick={() => setPage(item.id)}>
                            <span className="nav-icon">{item.icon}</span>
                            {item.label}
                        </button>
                    ))}
                </nav>
            </aside>

            {/* Main Content */}
            <main className="main-content">
                {renderPage()}
            </main>

            {/* Modals */}
            {bookModal && <BookModal cls={bookModal} onClose={() => setBookModal(null)} onSubmit={handleBook} />}
            {registerModal && <RegisterModal plan={registerModal} onClose={() => setRegisterModal(null)} onSubmit={handleRegister} />}

            {/* Toast */}
            {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
        </div>
    );
}
