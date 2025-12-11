# Talkam Liberia Admin Dashboard

React-based web dashboard for NGOs, government agencies, and administrators.

## Features

- 📊 Analytics dashboard with KPIs and charts
- 📋 Report management with filtering and verification
- 🚨 Alert broadcasting
- 🔐 Role-based access control
- 📱 Responsive design

## Setup

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Configure API endpoint**
   Create `.env`:
   ```
   VITE_API_URL=http://127.0.0.1:8000/v1
   ```

3. **Run development server**
   ```bash
   npm run dev
   ```

4. **Build for production**
   ```bash
   npm run build
   ```

## Usage

1. Login with NGO/Government/Admin credentials
2. View analytics dashboard for KPIs and trends
3. Browse and filter reports
4. Verify reports (confirm/reject)
5. Broadcast alerts to specific counties

## Tech Stack

- React 18
- TypeScript
- Vite
- React Router
- TanStack Query (React Query)
- Recharts
- Axios

## Deployment

Build the app and serve the `dist/` folder with any static hosting:
- Vercel
- Netlify
- AWS S3 + CloudFront
- Nginx

```bash
npm run build
# Deploy dist/ folder
```
