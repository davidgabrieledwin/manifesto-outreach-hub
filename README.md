# Manifesto Outreach Hub

An authenticated, cloud-synchronised outreach CRM for Manifesto: A Malaysian Policy Tracker.

## Run

Deploy this folder to GitHub Pages. Keep `index.html`, `manifesto-logo.png`, `config.js`, and the `README.md` together in the repository root.

Before opening the site, create a Supabase project, run `schema.sql` in its SQL Editor, then set the Project URL and **publishable** key in `config.js`. Never add a `service_role` key, database password, or personal access token to this repository.

For a public URL, upload the **three files** in this folder to a static hosting service such as GitHub Pages or Cloudflare Pages, following that provider's documentation and eligibility rules. Do not upload private CSV/JSON contact exports.

## What works

- Dashboard with live contact, outreach, meeting-stage, and due-follow-up counts
- Contacts with audiences, objectives, stages, channels, notes and follow-up dates
- Activity log: email, WhatsApp, LinkedIn, calls and meetings
- 12 editable message templates with personalization fields
- Copy personalized messages, including email subjects
- Search and filter contacts, due follow-ups, JSON backups and CSV exports
- Responsive layout for desktop and mobile

## Data and limitations

Users create an email/password account through Supabase and their contacts, templates, activities and sender settings are stored in that account. Row-level security ensures one signed-in user cannot read or modify another user's records. A small local cache keeps the interface responsive, but the cloud copy is the source of truth for cross-device use. Download JSON backups regularly. Do not put contact exports, credentials, or service-role keys into any public Git repository.

All initial contact counts are zero. No outreach or partnerships have been represented as achieved. The templates are starting drafts and should be customized for each recipient.

## Security notes

GitHub Pages publishes the application code only. The Supabase publishable key is expected to be visible in browser code; access control comes from the database RLS policies in `schema.sql`. Configure Supabase Auth redirect URLs for the final GitHub Pages address and keep email confirmation enabled. This build is designed for separate private accounts, not shared team workspaces.
