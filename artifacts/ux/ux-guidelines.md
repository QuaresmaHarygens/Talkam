# UX & Visual Design Guidelines

## Screen Coverage
- Onboarding & Permissions
- Report Creation (text/media)
- Audio-only reporting
- Feed + Map (heatmap)
- Report detail & evidence timeline
- Verification flow (community + admin)
- Alerts & crisis broadcast
- NGO/Journalist dashboard
- Government response dashboard
- Admin moderation console
- Analytics dashboard
- Settings & Help (offline management, panic delete)

## Low-Bandwidth Patterns
- Lazy load cards, skeleton states.
- Photo compression to 720px long edge, WebP thumbnails.
- Progressive map tiles; fallback to simplified county outlines offline.
- Offline queue indicator + manual sync; SMS fallback button prominent when network fails.

## Component Library
- **Buttons:** Primary (Sunrise Amber), Secondary (Mano River Blue), Tertiary (outline). Includes loading spinner + panic "Hide app" button.
- **Chips:** Category filters with icons; stateful (default, selected, error).
- **Cards:** Feed card (urgency pill + county tag), Verification card (witness meter), Alert banner (Clay Terracotta background).
- **Forms:** Text inputs with privacy hints, severity dial (slider + color-coded), location picker module (GPS + manual search + map pin), media attachment gallery with blur toggles.
- **Modals & Sheets:** 90% height sheet for report creation, confirmation modals with dual CTA.
- **Voice Recorder:** waveform visual, timer, privacy messaging, scramble toggle.
- **Map Pins:** shape-coded by category (e.g., triangle for infrastructure). Cluster states for dense areas.

## Accessibility Checklist
- Minimum 48px tap targets, 4px focus ring with high contrast.
- Dynamic type up to 200%; components wrap gracefully.
- Voice guidance for low literacy: text-to-speech for instructions, microphone icon accessible label.
- Captions & transcripts auto-generated for audio/video attachments; manual edit supported.
- Color contrast verified (WCAG AA). Non-color indicators (icons, labels) for severity.

## Localization Hooks
- Strings managed via JSON (`en-LR`, `kpe-LR`, `bas-LR`, `vai-LR`, `kra-LR`).
- Content uses Liberian English default ("small small", "talkam").
- RTL support reserved for future if needed; layout uses Flutter `Directionality` wrappers.

## Safety UX
- Anonymous toggle pinned near submit CTA with tooltip.
- Panic button double-tap hides app + clears viewport.
- Masked voice indicator stays visible across steps.
- Embargo banner on report detail reminding journalists about sharing rules.

## Hi-Fi Mockups
- Reference PNG: `artifacts/wireframes/hifi/talkam-hifi.png`
- Color tokens: `--color-primary: #f59e0b`, `--color-secondary: #2563eb`, `--color-surface: #f8fafc`.

## Validation Messaging
- Use supportive tone ("We need county name so responders can help").
- Provide offline-friendly fallback messages ("No net? We go hold your report till you get signal.").
