/*
 * Public browser configuration for Manifesto Outreach Hub.
 *
 * Paste the Supabase Project URL and Publishable (or legacy anon) key below.
 * These values are intentionally usable in a browser, but RLS in schema.sql is
 * what protects the data. Never place a service_role, secret, database, or
 * personal access token in this file.
 */
window.MANIFESTO_SUPABASE_CONFIG = Object.freeze({
  url: "https://wrdjuifdnpgcdltidjcq.supabase.co",
  publishableKey: "sb_publishable_ozbrtzD1BVAN6lksem7A3Q_iYAeOUeS",
});

window.getManifestoSupabaseConfig = function getManifestoSupabaseConfig() {
  const { url, publishableKey } = window.MANIFESTO_SUPABASE_CONFIG;
  if (!url || !publishableKey) {
    throw new Error(
      "Supabase is not configured. Set the Project URL and publishable key in config.js.",
    );
  }
  if (!/^https:\/\/[a-z0-9-]+\.supabase\.co\/?$/i.test(url)) {
    throw new Error("Supabase URL must be the HTTPS Project URL from the Supabase dashboard.");
  }
  return { url: url.replace(/\/$/, ""), publishableKey };
};
