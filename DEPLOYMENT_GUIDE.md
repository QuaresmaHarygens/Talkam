# 🚀 TalkAm Platform - Deployment Guide

## 📋 Pre-Deployment Checklist

### Backend API ✅
- [x] Deployed on Koyeb
- [x] Health check working
- [x] Database migrations applied
- [x] Environment variables configured
- [x] Error handling improved

### Web Frontend
- [x] All pages integrated with real API
- [x] Build compiles successfully
- [ ] Environment variables configured
- [ ] Production build tested
- [ ] Ready for deployment

### Mobile App
- [x] Design system applied
- [x] API connected
- [x] Build errors fixed
- [ ] Production build tested
- [ ] Ready for app store submission

---

## 🌐 Web Frontend Deployment

### Option 1: Vercel (Recommended)

**Prerequisites**:
- GitHub repository connected
- Vercel account

**Steps**:

1. **Install Vercel CLI** (optional):
```bash
npm install -g vercel
```

2. **Deploy from CLI**:
```bash
cd web-app
vercel
```

3. **Or Deploy via Vercel Dashboard**:
   - Go to https://vercel.com
   - Import your GitHub repository
   - Set root directory to `web-app`
   - Configure build settings:
     - Build Command: `npm run build`
     - Output Directory: `.next`
     - Install Command: `npm install`

4. **Environment Variables**:
   Add in Vercel dashboard:
   ```
   NEXT_PUBLIC_API_URL=https://little-amity-talkam-c84a1504.koyeb.app/v1
   ```

5. **Deploy**:
   - Click "Deploy"
   - Wait for build to complete
   - Your app will be live at `your-app.vercel.app`

### Option 2: Netlify

**Steps**:

1. **Install Netlify CLI** (optional):
```bash
npm install -g netlify-cli
```

2. **Deploy from CLI**:
```bash
cd web-app
npm run build
netlify deploy --prod
```

3. **Or Deploy via Netlify Dashboard**:
   - Go to https://netlify.com
   - Import your GitHub repository
   - Build settings:
     - Base directory: `web-app`
     - Build command: `npm run build`
     - Publish directory: `web-app/.next`

4. **Environment Variables**:
   Add in Netlify dashboard:
   ```
   NEXT_PUBLIC_API_URL=https://little-amity-talkam-c84a1504.koyeb.app/v1
   ```

### Option 3: Self-Hosted (Docker)

**Create Dockerfile**:
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY web-app/package*.json ./
RUN npm ci
COPY web-app ./
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV production
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
EXPOSE 3000
ENV PORT 3000
CMD ["node", "server.js"]
```

**Deploy**:
```bash
cd web-app
docker build -t talkam-web .
docker run -p 3000:3000 -e NEXT_PUBLIC_API_URL=https://little-amity-talkam-c84a1504.koyeb.app/v1 talkam-web
```

---

## 📱 Mobile App Deployment

### Android (Google Play Store)

**Prerequisites**:
- Google Play Developer account ($25 one-time fee)
- Android Studio installed
- Java JDK installed

**Steps**:

1. **Build App Bundle**:
```bash
cd mobile
flutter clean
flutter pub get
flutter build appbundle --release
```

2. **Output Location**:
   - File: `mobile/build/app/outputs/bundle/release/app-release.aab`
   - Size: ~20-30 MB

3. **Create Google Play Console Account**:
   - Go to https://play.google.com/console
   - Pay $25 registration fee
   - Complete account setup

4. **Create App**:
   - Click "Create app"
   - Fill in app details:
     - App name: "TalkAm Liberia"
     - Default language: English
     - App type: App
     - Free or paid: Free

5. **Upload App Bundle**:
   - Go to "Production" → "Create new release"
   - Upload `app-release.aab`
   - Add release notes
   - Review and roll out

6. **Complete Store Listing**:
   - App icon (512x512px)
   - Feature graphic (1024x500px)
   - Screenshots (at least 2)
   - Short description (80 chars)
   - Full description (4000 chars)
   - Privacy policy URL

7. **Content Rating**:
   - Complete content rating questionnaire
   - Get rating certificate

8. **Submit for Review**:
   - Complete all required sections
   - Submit app for review
   - Wait 1-7 days for approval

### iOS (App Store)

**Prerequisites**:
- Apple Developer account ($99/year)
- macOS with Xcode
- iOS device for testing

**Steps**:

1. **Open in Xcode**:
```bash
cd mobile
open ios/Runner.xcworkspace
```

2. **Configure Signing**:
   - Select "Runner" target
   - Go to "Signing & Capabilities"
   - Select your team
   - Enable "Automatically manage signing"

3. **Update App Info**:
   - Bundle Identifier: `com.talkam.liberia`
   - Version: `0.1.0`
   - Build: `1`

4. **Archive**:
   - Product → Archive
   - Wait for archive to complete

5. **Distribute**:
   - Click "Distribute App"
   - Select "App Store Connect"
   - Follow upload wizard

6. **App Store Connect**:
   - Go to https://appstoreconnect.apple.com
   - Create new app
   - Fill in app information
   - Upload screenshots and metadata
   - Submit for review

---

## 🔧 Environment Configuration

### Web Frontend

**Create `.env.local`** in `web-app/`:
```env
# API Configuration
NEXT_PUBLIC_API_URL=https://little-amity-talkam-c84a1504.koyeb.app/v1

# Optional: Analytics
NEXT_PUBLIC_GA_ID=your-google-analytics-id

# Optional: Sentry (Error Tracking)
NEXT_PUBLIC_SENTRY_DSN=your-sentry-dsn
```

### Mobile App

**Update `mobile/lib/providers.dart`**:
```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  // Production URL
  baseUrl: 'https://little-amity-talkam-c84a1504.koyeb.app/v1',
  
  // Or use environment variable:
  // baseUrl: const String.fromEnvironment('API_URL', 
  //   defaultValue: 'https://little-amity-talkam-c84a1504.koyeb.app/v1'),
));
```

### Backend (Already Configured)

**Koyeb Environment Variables**:
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `SECRET_KEY` - Application secret
- `JWT_SECRET` - JWT signing secret
- `S3_ENDPOINT` - S3 storage endpoint
- `S3_ACCESS_KEY` - S3 access key
- `S3_SECRET_KEY` - S3 secret key
- `BUCKET_REPORTS` - S3 bucket name

---

## 🧪 Pre-Deployment Testing

### Web Frontend Testing

```bash
cd web-app

# 1. Install dependencies
npm install

# 2. Build production version
npm run build

# 3. Test production build locally
npm start

# 4. Run tests (if available)
npm test

# 5. Check for linting errors
npm run lint
```

**Manual Testing Checklist**:
- [ ] Home page loads
- [ ] Login works
- [ ] Registration works
- [ ] Guest mode works
- [ ] Dashboard loads reports
- [ ] Create report works
- [ ] Verify reports works
- [ ] Challenges list loads
- [ ] Create challenge works
- [ ] Notifications load
- [ ] Profile displays correctly
- [ ] All API calls succeed
- [ ] Error states display properly
- [ ] Loading states work

### Mobile App Testing

```bash
cd mobile

# 1. Clean and get dependencies
flutter clean
flutter pub get

# 2. Analyze code
flutter analyze

# 3. Run tests
flutter test

# 4. Build release APK
flutter build apk --release

# 5. Build app bundle
flutter build appbundle --release

# 6. Test on device
flutter install
```

**Manual Testing Checklist**:
- [ ] App launches
- [ ] Welcome screen displays
- [ ] Login works
- [ ] Registration works
- [ ] Dashboard loads
- [ ] Create report works
- [ ] Map view works
- [ ] Challenges load
- [ ] Notifications work
- [ ] Settings accessible
- [ ] Offline mode works
- [ ] Error handling works

### Backend Testing

```bash
# Health check
curl https://little-amity-talkam-c84a1504.koyeb.app/health

# Expected: {"status":"healthy","service":"talkam-api"}

# Test authentication
curl -X POST https://little-amity-talkam-c84a1504.koyeb.app/v1/auth/anonymous-start \
  -H "Content-Type: application/json" \
  -d '{"device_hash":"test123"}'

# Test reports search
curl https://little-amity-talkam-c84a1504.koyeb.app/v1/reports/search \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📊 Post-Deployment Monitoring

### Recommended Tools

1. **Error Tracking**: Sentry
   - Track errors in production
   - Get alerts for critical issues
   - Monitor error rates

2. **Analytics**: Google Analytics
   - Track user behavior
   - Monitor page views
   - Analyze user flows

3. **Performance**: Lighthouse
   - Monitor web performance
   - Track Core Web Vitals
   - Optimize loading times

4. **Uptime Monitoring**: UptimeRobot
   - Monitor API health
   - Get alerts for downtime
   - Track response times

### Key Metrics to Monitor

- **API Response Times**: Should be < 1 second
- **Error Rates**: Should be < 1%
- **Uptime**: Should be > 99.9%
- **User Registrations**: Track growth
- **Report Submissions**: Track engagement
- **Challenge Participation**: Track community engagement

---

## 🔒 Security Checklist

### Before Production

- [ ] HTTPS enabled everywhere
- [ ] API rate limiting configured
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention verified
- [ ] XSS protection enabled
- [ ] CSRF tokens implemented (if needed)
- [ ] Secure password storage verified
- [ ] JWT token expiration configured
- [ ] Environment variables secured
- [ ] S3 bucket permissions locked
- [ ] CORS configured correctly
- [ ] Security headers set

### Security Headers (Web Frontend)

Add to `next.config.js`:
```javascript
module.exports = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
        ],
      },
    ]
  },
}
```

---

## 🚨 Rollback Procedures

### Web Frontend (Vercel)

1. Go to Vercel dashboard
2. Select your project
3. Go to "Deployments"
4. Find previous working deployment
5. Click "..." → "Promote to Production"

### Mobile App

1. **Android**: Upload previous APK/AAB version
2. **iOS**: Revert to previous build in App Store Connect

### Backend (Koyeb)

1. Go to Koyeb dashboard
2. Select your service
3. Go to "Deployments"
4. Find previous working deployment
5. Click "Redeploy"

---

## 📝 Post-Deployment Tasks

### Immediate (Day 1)
- [ ] Monitor error logs
- [ ] Check API health
- [ ] Verify all features work
- [ ] Test on multiple devices
- [ ] Monitor user registrations

### Short-term (Week 1)
- [ ] Gather user feedback
- [ ] Fix any critical bugs
- [ ] Optimize performance
- [ ] Add analytics tracking
- [ ] Set up monitoring alerts

### Long-term (Month 1)
- [ ] Analyze user behavior
- [ ] Plan feature enhancements
- [ ] Scale infrastructure if needed
- [ ] Optimize costs
- [ ] Plan marketing strategy

---

## 🆘 Troubleshooting

### Web Frontend Issues

**Build Fails**:
- Check Node.js version (should be 18+)
- Clear `.next` folder: `rm -rf .next`
- Reinstall dependencies: `rm -rf node_modules && npm install`

**API Errors**:
- Check `NEXT_PUBLIC_API_URL` environment variable
- Verify backend is running
- Check CORS configuration

### Mobile App Issues

**Build Fails**:
- Run `flutter clean`
- Run `flutter pub get`
- Check Flutter version: `flutter --version`
- Update dependencies if needed

**API Connection Errors**:
- Verify `baseUrl` in `providers.dart`
- Check network permissions in `AndroidManifest.xml`
- Test backend health endpoint

### Backend Issues

**Service Down**:
- Check Koyeb dashboard for errors
- Review application logs
- Verify environment variables
- Check database connection

**Database Errors**:
- Verify `DATABASE_URL` is correct
- Check database is accessible
- Run migrations if needed: `alembic upgrade head`

---

## 📚 Additional Resources

- **Next.js Deployment**: https://nextjs.org/docs/deployment
- **Flutter Deployment**: https://docs.flutter.dev/deployment
- **Vercel Docs**: https://vercel.com/docs
- **Google Play Console**: https://support.google.com/googleplay/android-developer
- **App Store Connect**: https://developer.apple.com/app-store-connect

---

## ✅ Deployment Checklist Summary

### Pre-Deployment
- [x] All code committed to Git
- [x] Build errors fixed
- [x] Tests passing
- [x] Environment variables configured
- [x] Security checklist completed

### Deployment
- [ ] Web frontend deployed
- [ ] Mobile app submitted to stores
- [ ] Monitoring set up
- [ ] Analytics configured
- [ ] Error tracking enabled

### Post-Deployment
- [ ] Health checks passing
- [ ] All features tested
- [ ] User feedback collected
- [ ] Performance optimized
- [ ] Documentation updated

---

**Last Updated**: December 8, 2025  
**Status**: Ready for Deployment 🚀
