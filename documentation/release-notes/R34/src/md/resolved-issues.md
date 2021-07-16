# Resolved issues

## T-56445 Fixed failing sales applications in Safari browser due to an unsupported Javascript feature

The Advanced Pricing Aggregation Javascript library used a Javascript feature that is supported on all other browsers, but not on Safari.
This caused sales applications that use the Advanced Pricing Aggregation library to fail to load and initialize. This is now fixed.