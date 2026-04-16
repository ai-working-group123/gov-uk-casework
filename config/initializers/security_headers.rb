# Be sure to restart your server when you modify this file.

# Security headers applied to all responses.
# Complements the Content Security Policy defined in content_security_policy.rb.

Rails.application.config.action_dispatch.default_headers.merge!(
  "X-Frame-Options"        => "DENY",
  "X-Content-Type-Options" => "nosniff",
  "X-XSS-Protection"       => "0",
  "Referrer-Policy"         => "strict-origin-when-cross-origin",
  "Permissions-Policy"      => "camera=(), microphone=(), geolocation=(), payment=()"
)
