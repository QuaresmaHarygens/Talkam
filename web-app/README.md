# Talkam Liberia - Web Application

Next.js web application for Talkam Liberia social reporting platform.

## Features

- ✅ Landing page with feature overview
- ✅ Public report tracking (no auth required)
- ✅ Responsive, mobile-first design
- ✅ TypeScript for type safety
- ✅ Tailwind CSS for styling

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Backend API running (default: http://127.0.0.1:8000)

### Installation

```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.local.example .env.local
# Edit .env.local with your API URL if different
```

### Development

```bash
# Start development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build

```bash
# Build for production
npm run build

# Start production server
npm start
```

## Project Structure

```
web-app/
├── app/                    # Next.js app directory
│   ├── page.tsx           # Landing page
│   ├── track/             # Tracking pages
│   │   ├── page.tsx      # Track entry page
│   │   └── [reportId]/   # Track results page
│   └── submit/            # Report submission (TODO)
├── components/             # React components
│   └── ui/                # UI components
├── lib/                    # Utilities and services
│   ├── api/               # API client and endpoints
│   ├── encryption/        # Encryption utilities (TODO)
│   ├── offline/           # Offline storage (TODO)
│   └── upload/            # File upload utilities (TODO)
├── types/                 # TypeScript type definitions
└── hooks/                 # React hooks (TODO)
```

## API Integration

The app connects to the FastAPI backend. Configure the API URL in `.env.local`:

```
NEXT_PUBLIC_API_URL=http://127.0.0.1:8000/v1
```

## Features in Progress

- [ ] Report submission form
- [ ] Evidence upload with hash computation
- [ ] Offline draft storage (IndexedDB)
- [ ] Voice reporting
- [ ] Pidgin language support
- [ ] Authentication flow
- [ ] User dashboard

## Tech Stack

- **Framework**: Next.js 16 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **HTTP Client**: Axios
- **State Management**: React Query (TanStack Query)
- **Forms**: React Hook Form + Zod
- **Icons**: Heroicons

## License

Part of the Talkam Liberia project.
