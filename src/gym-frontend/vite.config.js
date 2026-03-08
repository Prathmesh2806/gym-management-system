import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [react()],
    server: {
        port: 3000,
        proxy: {
            '/api/classes': 'http://localhost:4001',
            '/api/bookings': 'http://localhost:4001',
            '/api/plans': 'http://localhost:4002',
            '/api/members': 'http://localhost:4002',
            '/api/stats': 'http://localhost:4002',
            '/api/notifications': 'http://localhost:4003',
            '/api/notify': 'http://localhost:4003'
        }
    }
});
