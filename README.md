# SaathiAI

## Vision
SathiAI is the "Village Sathi" platform that gives every rural Indian a cultural, multilingual AI companion to discover government schemes, skill paths and market signals through a resilient, offline-first experience.

## What It Does
- **Multilingual Voice Interface:** Hindi plus regional languages, with code-switching and accent awareness, powered by Amazon Lex and Polly.
- **Cultural AI Persona:** A patient, idiom-rich “Village Sathi” that explains complex processes with familiar analogies and adapts to literacy levels.
- **Predictive Recommendations:** Scheme-matching, skill suggestions, and market timing tailored to the user profile, location, and seasonality.
- **Gamified Learning:** Points, badges, and leaderboards such as the "Sakhi Learner" rewards to encourage repeated engagement.
- **Offline-First Design:** Essential guidance, cached content, and progressive sync allow core features to work even with no connectivity.

## Architecture Highlights
- **Front End:** React Native mobile client with a voice-first UI, offline cache, and lightweight dashboard for progress tracking.
- **Backend AWS Stack:** Amazon Bedrock for persona intelligence, Lex for conversational flows, Polly for multilingual TTS, DynamoDB for user profiles, Lambda for orchestration, and S3 for static content distribution.
- **Data Sources:** Government scheme APIs, agritech market feeds, and curated skill program catalogs feed the recommendation engine.
- **Testing Discipline:** Spec-driven development with 15 property-based tests for correctness, cultural appropriateness validation, and performance checks on low-end devices.

## Why It Matters
- **Digital Inclusion:** Bridges language, literacy, and connectivity gaps for the 650+ million rural Indians.
- **Government Impact:** Automates scheme discovery and application assistance while surfacing usage analytics for better targeting.
- **Economic Empowerment:** Accelerates income growth through timely market insights and relevant skill pathways.

## Getting Started
1. Install dependencies (`npm install` / native modules) inside `mobile/` if present.
2. Wire up AWS credentials for Bedrock, Lex, Polly, and Lambda endpoints.
3. Seed DynamoDB tables with scheme metadata and sync strategies for offline data.
4. Run property-based tests (`npm run test:properties` or equivalent) to verify persona and recommendation logic.
