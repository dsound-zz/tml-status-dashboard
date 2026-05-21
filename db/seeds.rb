puts "Seeding states..."

STATE_DATA = [
  {
    name: "Alabama", abbreviation: "AL",
    department_name: "Alabama Law Enforcement Agency — Driver License Division",
    contact_name: "Marcus Treadwell", contact_email: "m.treadwell@alea.gov", contact_phone: "(334) 242-4239",
    api_type: "SOAP", api_version: "1.2", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "Uses a SOAP 1.2 endpoint wrapped in a state-managed security envelope. Each session requires a two-phase handshake: initial credentials exchange returns a 15-minute bearer token, after which XML payloads must include a signed timestamp header. Responses are synchronous but throttled to 120 requests/minute."
  },
  {
    name: "Alaska", abbreviation: "AK",
    department_name: "Alaska Division of Motor Vehicles — Records & Licensing Bureau",
    contact_name: "Denise Halvorsen", contact_email: "d.halvorsen@alaska.gov", contact_phone: "(907) 269-5551",
    api_type: "REST", api_version: "v1.4", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "REST API with JSON responses, but requires a state-issued API key embedded in both the HTTP header and a custom X-AK-RequestSignature field derived from a SHA-256 HMAC of the request timestamp. Quota: 500 records/day. Data refresh lag averages 18 hours due to upstream batch processing."
  },
  {
    name: "Arizona", abbreviation: "AZ",
    department_name: "Arizona Department of Transportation — Motor Vehicle Division",
    contact_name: "Ricardo Fuentes", contact_email: "r.fuentes@azdot.gov", contact_phone: "(602) 255-0072",
    api_type: "REST", api_version: "v3.1", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "Full OAuth 2.0 client credentials flow with a 1-hour token TTL. The API enforces strict rate limiting (200 RPM) and uses a cursor-based pagination model for batch queries. Arizona is one of the few states supporting real-time record status via a webhook subscription endpoint."
  },
  {
    name: "Arkansas", abbreviation: "AR",
    department_name: "Arkansas Department of Finance & Administration — Office of Driver Services",
    contact_name: "Jolene Bassett", contact_email: "jbassett@dfa.arkansas.gov", contact_phone: "(501) 682-7060",
    api_type: "XML-RPC", api_version: "2.0", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "Legacy XML-RPC interface over HTTPS. Requests must include a procedural call to `mvr.getRecord` with username and password in the payload body (not headers). The state maintains a backup SFTP drop for high-volume batch requests exceeding 1,000 records, which are fulfilled within 4 business hours."
  },
  {
    name: "California", abbreviation: "CA",
    department_name: "California Department of Motor Vehicles — Enterprise Information Services",
    contact_name: "Priya Nair", contact_email: "p.nair@dmv.ca.gov", contact_phone: "(916) 657-6525",
    api_type: "REST", api_version: "v4.2", data_format: "JSON",
    auth_method: "Mutual TLS",
    protocol_notes: "Mutual TLS authentication with state-issued client certificates that must be renewed annually. California enforces the strictest SLA on record freshness (max 4-hour lag) but also has the most complex consent verification layer — each query triggers an async consent check against the DPPA authorization registry before data is released."
  },
  {
    name: "Colorado", abbreviation: "CO",
    department_name: "Colorado Department of Revenue — Division of Motor Vehicles",
    contact_name: "Tyler Whitmore", contact_email: "tyler.whitmore@state.co.us", contact_phone: "(303) 205-5600",
    api_type: "REST", api_version: "v2.0", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "OAuth 2.0 with PKCE flow. Colorado's MVR API is notable for its verbose error envelope — all errors return a 200 OK with an `error` field nested inside the response body, a quirk inherited from the original 2009 implementation. Supports async batch mode for queries over 50 records."
  },
  {
    name: "Connecticut", abbreviation: "CT",
    department_name: "Connecticut Department of Motor Vehicles — Data Services Unit",
    contact_name: "Sandra Fournier", contact_email: "sandra.fournier@ct.gov", contact_phone: "(860) 263-5700",
    api_type: "SOAP", api_version: "1.1", data_format: "XML",
    auth_method: "API Key",
    protocol_notes: "SOAP 1.1 with API key passed via a custom WS-Security UsernameToken header. Connecticut requires all integration partners to maintain a registered static IP whitelist, updated quarterly through the state's vendor portal. Planned maintenance windows occur every third Sunday from 2:00–6:00 AM EST."
  },
  {
    name: "Delaware", abbreviation: "DE",
    department_name: "Delaware Division of Motor Vehicles — MVR Records Center",
    contact_name: "Howard Kimball", contact_email: "h.kimball@dmv.delaware.gov", contact_phone: "(302) 744-2500",
    api_type: "Proprietary FTP", api_version: "N/A", data_format: "Flat File (pipe-delimited)",
    auth_method: "Username/Password",
    protocol_notes: "Delaware does not have an API in the traditional sense. Records are delivered via a nightly SFTP batch to a state-managed file server. Files arrive by 3:00 AM ET in a pipe-delimited flat file format with a proprietary 22-field layout. A confirmation receipt file must be uploaded within 2 hours of download or the batch is flagged as failed."
  },
  {
    name: "Florida", abbreviation: "FL",
    department_name: "Florida Department of Highway Safety and Motor Vehicles — MVR Unit",
    contact_name: "Carmen Delgado", contact_email: "c.delgado@flhsmv.gov", contact_phone: "(850) 617-2000",
    api_type: "SOAP", api_version: "1.2", data_format: "XML",
    auth_method: "Mutual TLS",
    protocol_notes: "Florida uses a proprietary SOAP 1.2 endpoint over a state-managed VPN tunnel. Each query requires a session token obtained from a separate authentication service that expires every 15 minutes. The VPN certificate must be renewed every 90 days and a 48-hour notice is required before the renewal window to avoid service interruption."
  },
  {
    name: "Georgia", abbreviation: "GA",
    department_name: "Georgia Department of Driver Services — Records Management Division",
    contact_name: "Lamont Jefferson", contact_email: "l.jefferson@dds.ga.gov", contact_phone: "(678) 413-8400",
    api_type: "REST", api_version: "v2.3", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "OAuth 2.0 with a custom scope system (`mvr:read`, `mvr:batch`). Georgia's API includes a real-time status field on each record indicating whether the data is from cache or live pull. Cache TTL is 6 hours. Batch endpoints support up to 500 records per call but require a separate billing pre-authorization header."
  },
  {
    name: "Hawaii", abbreviation: "HI",
    department_name: "Hawaii Department of Transportation — Highways Division, Driver Licensing",
    contact_name: "Kealoha Makoa", contact_email: "k.makoa@hawaii.gov", contact_phone: "(808) 832-5000",
    api_type: "REST", api_version: "v1.0", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "Simple REST API with static API key auth, but Hawaii enforces a strict 50 RPM rate limit with exponential backoff requirements. The state processes inter-island record discrepancies manually, so records flagged `jurisdiction: INTER_ISLAND` may be delayed up to 72 hours. The API returns ISO 8601 timestamps in HST without UTC offset, which must be handled in the client."
  },
  {
    name: "Idaho", abbreviation: "ID",
    department_name: "Idaho Transportation Department — Driver Services Bureau",
    contact_name: "Brett Halverson", contact_email: "bhalverson@itd.idaho.gov", contact_phone: "(208) 334-8000",
    api_type: "XML-RPC", api_version: "1.5", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "XML-RPC over HTTPS with credentials embedded in the payload. Idaho is one of the last states using this protocol due to a long-running procurement dispute with their legacy vendor. The state processes violation codes using a proprietary 3-character scheme (e.g., `SPD`, `DUI`, `REV`) that must be mapped client-side to standard AAMVA codes."
  },
  {
    name: "Illinois", abbreviation: "IL",
    department_name: "Illinois Secretary of State — Driver Services Department",
    contact_name: "Renata Kowalski", contact_email: "r.kowalski@ilsos.gov", contact_phone: "(217) 785-3000",
    api_type: "REST", api_version: "v3.0", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "OAuth 2.0 with mandatory IP-based allowlisting in addition to token auth. Illinois imposes a consent log requirement — every record query is logged against the requesting party's DPPA purpose code, and quarterly audit reports are sent to the registered contact. The API includes a `data_age_hours` field on every response indicating record staleness."
  },
  {
    name: "Indiana", abbreviation: "IN",
    department_name: "Indiana Bureau of Motor Vehicles — MVR Records Division",
    contact_name: "Cynthia Moorefield", contact_email: "cmoorefield@bmv.in.gov", contact_phone: "(317) 232-2798",
    api_type: "REST", api_version: "v2.1", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "Standard REST with API key, but Indiana routes all requests through a state-managed API gateway that enforces a secondary user-agent validation. Requests must declare a registered `X-Partner-ID` header. Indiana's gateway returns HTTP 429 for rate limit violations with a `Retry-After` header, but this value is often inaccurate due to a known gateway bug (acknowledged since Q3 2021)."
  },
  {
    name: "Iowa", abbreviation: "IA",
    department_name: "Iowa Department of Transportation — Office of Driver Services",
    contact_name: "Douglas Petersen", contact_email: "d.petersen@iowadot.us", contact_phone: "(515) 244-8725",
    api_type: "SOAP", api_version: "1.2", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "SOAP 1.2 with WS-Security. Iowa requires all partners to maintain a signed data use agreement (DUA) on file, renewed annually. The endpoint validates the DUA expiration date on every request and returns a `DUA_EXPIRED` fault code if renewal is overdue. Iowa also enforces a 10-second minimum interval between sequential record pulls for the same license number."
  },
  {
    name: "Kansas", abbreviation: "KS",
    department_name: "Kansas Department of Revenue — Driver Control Bureau",
    contact_name: "Patricia Holloway", contact_email: "pholloway@kdor.ks.gov", contact_phone: "(785) 296-3671",
    api_type: "REST", api_version: "v2.3", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "REST API with API key authentication. Kansas routes its MVR data through the AAMVA DSDL network, adding an additional verification layer before data is returned. Responses include a `source_verified` boolean field. The state has a published SLA of 99.5% uptime with a 4-hour RTO. Batch requests above 100 records are queued and returned via webhook callback."
  },
  {
    name: "Kentucky", abbreviation: "KY",
    department_name: "Kentucky Transportation Cabinet — Division of Driver Licensing",
    contact_name: "Angela Rutherford", contact_email: "angela.rutherford@ky.gov", contact_phone: "(502) 564-6800",
    api_type: "SOAP", api_version: "1.1", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "SOAP 1.1 with a non-standard envelope prefix (`<kysoap:Envelope>` instead of `<soapenv:Envelope>`). This quirk causes failures with several off-the-shelf SOAP clients and requires manual namespace mapping. Kentucky also returns race and gender fields as numeric codes (0-9 scale) using a state-specific lookup table not published in the public AAMVA spec."
  },
  {
    name: "Louisiana", abbreviation: "LA",
    department_name: "Louisiana Office of Motor Vehicles — Records Management Section",
    contact_name: "Beau Thibodaux", contact_email: "b.thibodaux@omv.la.gov", contact_phone: "(225) 925-6146",
    api_type: "REST", api_version: "v1.8", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "OAuth 2.0 client credentials with a unique challenge: Louisiana's auth server requires the client secret to be base64-encoded before inclusion in the Basic auth header (double-encoded). This undocumented behavior is a legacy artifact from a 2017 migration and is noted only in the partner onboarding packet. Throttle limit: 300 RPM."
  },
  {
    name: "Maine", abbreviation: "ME",
    department_name: "Maine Bureau of Motor Vehicles — Driver Records Unit",
    contact_name: "Heather Voisine", contact_email: "h.voisine@maine.gov", contact_phone: "(207) 624-9000",
    api_type: "REST", api_version: "v1.2", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "Lightweight REST API with API key auth, but Maine imposes a mandatory 24-hour data retention embargo — records pulled before 24 hours of an update event will still return the previous version. The state publishes a separate `/updates` endpoint that returns a changelog of recently modified records, intended to support cache invalidation workflows."
  },
  {
    name: "Maryland", abbreviation: "MD",
    department_name: "Maryland Motor Vehicle Administration — MVR Division",
    contact_name: "Gerald Okonkwo", contact_email: "g.okonkwo@mva.maryland.gov", contact_phone: "(410) 768-7000",
    api_type: "REST", api_version: "v3.4", data_format: "JSON",
    auth_method: "Mutual TLS",
    protocol_notes: "Mutual TLS with a hardened certificate pinning requirement — the server certificate must match a SHA-256 fingerprint registered during onboarding. Maryland refreshes this fingerprint quarterly (announced 30 days in advance) and integration partners must update their trust stores before the rotation date or service will fail silently."
  },
  {
    name: "Massachusetts", abbreviation: "MA",
    department_name: "Massachusetts Registry of Motor Vehicles — Data Services",
    contact_name: "Eileen Callahan", contact_email: "eileen.callahan@state.ma.us", contact_phone: "(617) 351-4500",
    api_type: "REST", api_version: "v4.0", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "OAuth 2.0 with a custom multi-factor authorization flow — after standard token issuance, high-sensitivity queries (DUI, revocations) require a secondary scope elevation with a time-limited one-time token. Massachusetts is one of the only states that exposes violation disposition codes in real time; most states lag by 30-90 days."
  },
  {
    name: "Michigan", abbreviation: "MI",
    department_name: "Michigan Department of State — Office of Highway Safety Planning",
    contact_name: "Theodore Vanzandt", contact_email: "t.vanzandt@michigan.gov", contact_phone: "(517) 322-1460",
    api_type: "SOAP", api_version: "1.2", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "SOAP 1.2 with an unusual session model: the state issues a session ID valid for exactly 100 queries or 8 hours (whichever comes first), after which a re-authentication call is required. Michigan's endpoint enforces a sequential query lock — concurrent requests from the same session ID will queue with a 30-second timeout before returning an ENQUEUE_TIMEOUT fault."
  },
  {
    name: "Minnesota", abbreviation: "MN",
    department_name: "Minnesota Department of Public Safety — Driver and Vehicle Services",
    contact_name: "Lisa Lindqvist", contact_email: "l.lindqvist@dps.mn.gov", contact_phone: "(651) 297-3298",
    api_type: "REST", api_version: "v2.5", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "OAuth 2.0 with fine-grained scopes per record type. Minnesota exposes violation data and status data on separate endpoints with different rate limits: 500 RPM for status, 100 RPM for violations. The state runs a staging environment on port 8443 that mirrors production data with a 48-hour delay — available to credentialed partners for integration testing."
  },
  {
    name: "Mississippi", abbreviation: "MS",
    department_name: "Mississippi Department of Public Safety — Driver's License Bureau",
    contact_name: "Wayne Fortenberry", contact_email: "w.fortenberry@dps.ms.gov", contact_phone: "(601) 987-1212",
    api_type: "XML-RPC", api_version: "1.2", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "XML-RPC over HTTP (not HTTPS) — Mississippi is one of the few remaining states using an unencrypted transport layer for non-sensitive lookups. Sensitive fields (SSN partial, medical flags) are transmitted via a secondary encrypted SFTP transfer triggered by the initial query. Partners must poll the SFTP server for the secure payload, typically available within 5 minutes."
  },
  {
    name: "Missouri", abbreviation: "MO",
    department_name: "Missouri Department of Revenue — Driver License Bureau",
    contact_name: "Charlene Busby", contact_email: "c.busby@dor.mo.gov", contact_phone: "(573) 526-2407",
    api_type: "REST", api_version: "v2.0", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "REST API with API key. Missouri's endpoint is notable for its aggressive caching strategy — all responses include a `Cache-Control: max-age=14400` header and the state's CDN may return stale data up to 4 hours old. Partners requiring real-time data must include a `X-MO-Bypass-Cache: true` header, which is rate-limited to 50 calls/day per key."
  },
  {
    name: "Montana", abbreviation: "MT",
    department_name: "Montana Department of Justice — Motor Vehicle Division",
    contact_name: "Garrett Swenson", contact_email: "g.swenson@mt.gov", contact_phone: "(406) 444-3661",
    api_type: "Proprietary FTP", api_version: "N/A", data_format: "Flat File (tab-delimited)",
    auth_method: "Username/Password",
    protocol_notes: "Montana delivers records via a nightly SFTP batch. The file format is tab-delimited with a 31-field proprietary layout. Montana is the only state that includes a `ROAD_CONDITION_FLAG` field in MVR exports, a legacy artifact from a 1998 pilot program. This field is always `N` and exists solely for backward compatibility with a defunct partner system."
  },
  {
    name: "Nebraska", abbreviation: "NE",
    department_name: "Nebraska Department of Motor Vehicles — Driver Records Division",
    contact_name: "Phyllis Lundgren", contact_email: "p.lundgren@dmv.ne.gov", contact_phone: "(402) 471-3985",
    api_type: "SOAP", api_version: "1.2", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "SOAP 1.2 with a state-specific fault schema. Nebraska uses a custom `<NebraskaMVRFault>` element with a 4-digit error code system not documented in the public API spec. Partners receive a closed-access error codebook PDF during onboarding. Common codes include `4401` (record sealed), `4402` (consent validation failed), and `4410` (concurrent session limit exceeded)."
  },
  {
    name: "Nevada", abbreviation: "NV",
    department_name: "Nevada Department of Motor Vehicles — Records and Licensing Services",
    contact_name: "Dominique Reyes", contact_email: "d.reyes@dmvnv.com", contact_phone: "(702) 486-4368",
    api_type: "REST", api_version: "v3.2", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "OAuth 2.0 with JWT-based tokens. Nevada is the only state that includes a `confidence_score` field (0.0–1.0) on each record, representing the system's confidence in the record's accuracy based on cross-reference checks with court data. Scores below 0.85 are flagged for manual verification. The confidence scoring engine runs on a 6-hour cadence."
  },
  {
    name: "New Hampshire", abbreviation: "NH",
    department_name: "New Hampshire Division of Motor Vehicles — Records Bureau",
    contact_name: "Patrick Harrigan", contact_email: "pharrigan@dos.nh.gov", contact_phone: "(603) 227-4000",
    api_type: "REST", api_version: "v1.6", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "Simple REST API with API key auth. New Hampshire is notable for strict concurrency limits — only 3 simultaneous open connections are allowed per API key. Exceeding this returns a `429` with a `Connection-Limit-Exceeded` response body (not standard `Retry-After`). The state does not publish an uptime SLA but historically maintains >99.2% availability."
  },
  {
    name: "New Jersey", abbreviation: "NJ",
    department_name: "New Jersey Motor Vehicle Commission — Driver Abstract Unit",
    contact_name: "Rosa Marchetti", contact_email: "r.marchetti@mvc.nj.gov", contact_phone: "(609) 292-6500",
    api_type: "REST", api_version: "v4.1", data_format: "JSON",
    auth_method: "Mutual TLS",
    protocol_notes: "Mutual TLS with a mandatory per-request audit token. New Jersey requires each API call to include a `X-NJ-AuditToken` header derived from a rotating daily secret distributed via a separate secure channel. The daily secret rotation occurs at midnight ET, and the first 5 minutes after rotation are a grace period where both old and new secrets are accepted."
  },
  {
    name: "New Mexico", abbreviation: "NM",
    department_name: "New Mexico Motor Vehicle Division — Driver Services Bureau",
    contact_name: "Elena Chavez", contact_email: "echavez@mvd.newmexico.gov", contact_phone: "(888) 683-4636",
    api_type: "SOAP", api_version: "1.1", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "SOAP 1.1 with basic auth. New Mexico's endpoint is hosted on aging infrastructure with a known memory leak that causes service degradation every 4–6 hours. The state performs a scheduled restart at 3:00 AM MST, which causes a 3–5 minute outage. This scheduled restart is not classified as a 'planned outage' by the state's internal policy."
  },
  {
    name: "New York", abbreviation: "NY",
    department_name: "New York Department of Motor Vehicles — Abstract Processing Unit",
    contact_name: "Winifred Okafor", contact_email: "w.okafor@dmv.ny.gov", contact_phone: "(518) 473-5595",
    api_type: "REST", api_version: "v5.0", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "The most advanced MVR API in the country. New York uses OAuth 2.0 with resource indicators (RFC 8707) to scope token validity to specific resource types. The API supports long-polling subscriptions for live violation updates. NYC-issued licenses have a separate data tier with additional fields reflecting city-specific ordinances and a 2-hour freshness guarantee."
  },
  {
    name: "North Carolina", abbreviation: "NC",
    department_name: "North Carolina Division of Motor Vehicles — Driver Records Section",
    contact_name: "Bobby Tanner", contact_email: "b.tanner@ncdot.gov", contact_phone: "(919) 715-7000",
    api_type: "REST", api_version: "v2.8", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "REST with API key. North Carolina uses a dual-endpoint architecture: real-time queries hit a primary endpoint, while historical abstracts (3+ years) route to a separate archive endpoint with different rate limits and response times (up to 30 seconds for complex historical queries). Partners must dynamically select the correct endpoint based on the query date range."
  },
  {
    name: "North Dakota", abbreviation: "ND",
    department_name: "North Dakota Department of Transportation — Driver License Division",
    contact_name: "Harvey Baumgartner", contact_email: "h.baumgartner@nd.gov", contact_phone: "(701) 328-4353",
    api_type: "REST", api_version: "v1.3", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "Simple REST API. North Dakota is the only state whose API returns record data in alphabetical order by field name regardless of query parameters, a behavior inherited from their 2015 JSON conversion script. The state's API documentation is only available as a physical binder distributed by request, scanned and hosted internally. No public-facing docs exist."
  },
  {
    name: "Ohio", abbreviation: "OH",
    department_name: "Ohio Bureau of Motor Vehicles — Records and Licensing",
    contact_name: "Deborah Fitzpatrick", contact_email: "d.fitzpatrick@bmv.ohio.gov", contact_phone: "(614) 752-7600",
    api_type: "SOAP", api_version: "1.2", data_format: "XML",
    auth_method: "OAuth 2.0",
    protocol_notes: "Hybrid protocol: OAuth 2.0 for authentication, SOAP 1.2 for the request/response envelope. Ohio is one of the few states to implement this combination, which requires a custom integration layer. The OAuth token is passed as a SOAP header element rather than an HTTP Authorization header. Ohio has a published test harness available at a separate testing subdomain."
  },
  {
    name: "Oklahoma", abbreviation: "OK",
    department_name: "Oklahoma Department of Public Safety — Driver License Services",
    contact_name: "Travis Mackey", contact_email: "t.mackey@dps.ok.gov", contact_phone: "(405) 425-2424",
    api_type: "REST", api_version: "v2.0", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "Standard REST with API key. Oklahoma enforces a strict DPPA purpose code validation on every query — the purpose code must match a pre-registered list for the account, and mismatches result in a permanent account suspension after 3 violations. The state sends automated compliance reports to the registered contact every 90 days."
  },
  {
    name: "Oregon", abbreviation: "OR",
    department_name: "Oregon Department of Transportation — Driver and Motor Vehicle Services",
    contact_name: "Megan Thornberry", contact_email: "m.thornberry@odot.state.or.us", contact_phone: "(503) 945-5000",
    api_type: "REST", api_version: "v3.0", data_format: "JSON",
    auth_method: "Mutual TLS",
    protocol_notes: "Mutual TLS with a client certificate requiring ECC P-384 keys (not RSA). This is stricter than most states, which accept RSA-2048. Oregon also implements idempotency keys — re-submitting the same query within 60 seconds with the same `X-OR-Idempotency-Key` returns a cached response rather than hitting the database, which helps manage their 150 RPM limit."
  },
  {
    name: "Pennsylvania", abbreviation: "PA",
    department_name: "Pennsylvania Department of Transportation — Bureau of Driver Licensing",
    contact_name: "Walter Grabowski", contact_email: "w.grabowski@dot.state.pa.us", contact_phone: "(717) 412-5300",
    api_type: "SOAP", api_version: "1.2", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "SOAP 1.2 with a proprietary versioning handshake: the first call to any session must be a `getServerCapabilities` request that returns a compatibility matrix. Client must confirm compatibility by echoing back a `clientCapabilities` token in the next request. Pennsylvania runs a bi-weekly scheduled maintenance window on Tuesdays 2:00–4:00 AM ET."
  },
  {
    name: "Rhode Island", abbreviation: "RI",
    department_name: "Rhode Island Division of Motor Vehicles — Records Division",
    contact_name: "Maureen Teixeira", contact_email: "m.teixeira@dmv.ri.gov", contact_phone: "(401) 462-4368",
    api_type: "REST", api_version: "v1.5", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "Simple REST API. Rhode Island shares a data center with the Connecticut DMV and both systems experience correlated downtime during shared infrastructure maintenance. The RI API uniquely includes a `compact_eligible` field indicating whether a violation qualifies for reporting under the Driver License Compact, pre-computed server-side."
  },
  {
    name: "South Carolina", abbreviation: "SC",
    department_name: "South Carolina Department of Motor Vehicles — Driver Records",
    contact_name: "Nathaniel Boone", contact_email: "n.boone@scdmv.net", contact_phone: "(803) 896-5000",
    api_type: "REST", api_version: "v2.1", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "OAuth 2.0 with a geofencing restriction — API calls must originate from a US-based IP. South Carolina maintains an IP allowlist that updates automatically via BGP route validation. The API enforces a 200ms minimum processing delay per request, a deliberate design choice intended to prevent bulk scraping. Batch endpoint supports 200 records/call."
  },
  {
    name: "South Dakota", abbreviation: "SD",
    department_name: "South Dakota Department of Public Safety — Office of Driver Licensing",
    contact_name: "Gordon Riesland", contact_email: "g.riesland@state.sd.us", contact_phone: "(605) 773-6883",
    api_type: "REST", api_version: "v1.1", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "Minimal REST API. South Dakota is unique in that their API responds in Mountain Standard Time (not UTC) with no timezone indicator in the timestamp fields. Client-side timezone conversion is required. The state's technical contact is a single-person team and response to integration issues can take 5–7 business days."
  },
  {
    name: "Tennessee", abbreviation: "TN",
    department_name: "Tennessee Department of Safety and Homeland Security — Driver Services",
    contact_name: "Loretta Mullins", contact_email: "l.mullins@tn.gov", contact_phone: "(615) 251-5166",
    api_type: "SOAP", api_version: "1.2", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "SOAP 1.2 with session-based auth. Tennessee requires a mandatory `ReasonCode` element in every request body from a state-defined enumeration of 17 permissible DPPA purposes. The state logs all queries and conducts annual audits. An incorrect `ReasonCode` triggers a compliance review and temporary account hold pending investigation."
  },
  {
    name: "Texas", abbreviation: "TX",
    department_name: "Texas Department of Public Safety — Driver License Division",
    contact_name: "Rafael Morales", contact_email: "r.morales@dps.texas.gov", contact_phone: "(512) 424-2600",
    api_type: "REST", api_version: "v4.3", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "Full OAuth 2.0 with dynamic client registration (RFC 7591). Texas is one of the highest-throughput state APIs, processing over 2 million queries per day from all integration partners combined. The API uses consistent hashing for load distribution across 12 regional data centers. Response times SLA: 500ms at p95, 2s at p99. Texas also provides a GraphQL endpoint in beta."
  },
  {
    name: "Utah", abbreviation: "UT",
    department_name: "Utah Division of Motor Vehicles — Driver Records Bureau",
    contact_name: "Spencer Christensen", contact_email: "s.christensen@utah.gov", contact_phone: "(801) 965-4437",
    api_type: "REST", api_version: "v2.7", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "REST with API key. Utah's API includes a `record_hash` field on every response — a SHA-256 hash of the record contents at time of pull. Partners are expected to store this hash and use a `/changed` endpoint to detect if a record has been modified since last pull, avoiding redundant full fetches. Cache invalidation webhooks are available but require a separate subscription."
  },
  {
    name: "Vermont", abbreviation: "VT",
    department_name: "Vermont Department of Motor Vehicles — Records Section",
    contact_name: "Claire Pellegrino", contact_email: "c.pellegrino@dmv.vermont.gov", contact_phone: "(802) 828-2000",
    api_type: "REST", api_version: "v1.0", data_format: "JSON",
    auth_method: "API Key",
    protocol_notes: "Vermont runs the smallest-volume MVR API in the country. The entire state generates fewer records per day than most county-level queries in Texas. Despite this, Vermont has one of the most complete API responses, returning full disposition data, court reference numbers, and presiding judge information on all violations. The API is hosted on a shared state IT platform with liberal rate limits."
  },
  {
    name: "Virginia", abbreviation: "VA",
    department_name: "Virginia Department of Motor Vehicles — Records and Licensing",
    contact_name: "Alicia Bramblett", contact_email: "a.bramblett@dmv.virginia.gov", contact_phone: "(804) 497-7100",
    api_type: "REST", api_version: "v3.5", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "OAuth 2.0 with token introspection endpoint (RFC 7662). Virginia requires partners to introspect tokens before each batch job — a design intended to enforce real-time revocation. The state enforces a 2-second timeout on introspection calls, after which the query must be aborted and re-queued. Virginia's DevOps team publishes a status page updated in near real-time."
  },
  {
    name: "Washington", abbreviation: "WA",
    department_name: "Washington State Department of Licensing — Driver Records",
    contact_name: "Ingrid Olsen", contact_email: "i.olsen@dol.wa.gov", contact_phone: "(360) 902-3900",
    api_type: "REST", api_version: "v3.8", data_format: "JSON",
    auth_method: "Mutual TLS",
    protocol_notes: "Mutual TLS with short-lived client certificates (90-day TTL). Washington's API is notable for its event-sourced architecture — every violation has a full audit trail of state changes exposed via a `/history` endpoint. The state also exposes a `/stream` Server-Sent Events endpoint for partners who need push notifications on record changes, available under a premium tier SLA."
  },
  {
    name: "West Virginia", abbreviation: "WV",
    department_name: "West Virginia Division of Motor Vehicles — Driver Licensing",
    contact_name: "Carl Pennington", contact_email: "c.pennington@wvdmv.gov", contact_phone: "(304) 558-3900",
    api_type: "SOAP", api_version: "1.1", data_format: "XML",
    auth_method: "Username/Password",
    protocol_notes: "SOAP 1.1 on a legacy system running on-premises hardware managed by the state's internal IT division. West Virginia experiences the highest rate of unplanned outages of any state in the system, typically correlated with severe weather events affecting their Charleston data center. The state has announced a modernization initiative planned for 2027."
  },
  {
    name: "Wisconsin", abbreviation: "WI",
    department_name: "Wisconsin Department of Transportation — Division of Motor Vehicles",
    contact_name: "Katherine Strasser", contact_email: "k.strasser@dot.wi.gov", contact_phone: "(608) 264-7447",
    api_type: "REST", api_version: "v2.4", data_format: "JSON",
    auth_method: "OAuth 2.0",
    protocol_notes: "OAuth 2.0 with a consent-forwarding model — the requesting partner must include a `consent_reference_id` linking to a logged consent event in Wisconsin's central consent registry. This registry is queried synchronously during each API call, adding 80–150ms of latency. Wisconsin's API team publishes a monthly uptime report with p50, p95, and p99 latency breakdowns."
  },
  {
    name: "Wyoming", abbreviation: "WY",
    department_name: "Wyoming Department of Transportation — Driver Services",
    contact_name: "Dale Hoffmann", contact_email: "d.hoffmann@dot.wyo.gov", contact_phone: "(307) 777-4800",
    api_type: "Proprietary FTP", api_version: "N/A", data_format: "Flat File (pipe-delimited)",
    auth_method: "Username/Password",
    protocol_notes: "Wyoming is fully batch-only, delivering records via twice-daily SFTP drops at 6:00 AM and 6:00 PM MST. Wyoming is the last state using a mainframe-generated export format — the file includes EBCDIC-encoded fields for two legacy record types that must be decoded before processing. The state has no API modernization plans currently on file."
  }
].freeze

STATE_DATA.each do |data|
  state = State.find_or_create_by!(abbreviation: data[:abbreviation]) do |s|
    s.name             = data[:name]
    s.department_name  = data[:department_name]
    s.contact_name     = data[:contact_name]
    s.contact_email    = data[:contact_email]
    s.contact_phone    = data[:contact_phone]
    s.api_type         = data[:api_type]
    s.api_version      = data[:api_version]
    s.data_format      = data[:data_format]
    s.auth_method      = data[:auth_method]
    s.protocol_notes   = data[:protocol_notes]
  end

  StateStatus.find_or_create_by!(state: state) do |ss|
    ss.status           = "up"
    ss.response_time_ms = rand(120..850)
    ss.uptime_30d       = (rand * 5 + 95).round(2)
    ss.last_checked_at  = Time.current
  end

  print "."
end

# A few planned outages starting soon
State.where(abbreviation: %w[DE MT WY]).each do |state|
  state.state_status.update!(
    status: "planned_outage",
    planned_outage_start: 2.hours.from_now,
    planned_outage_end: 6.hours.from_now,
    outage_reason: "Scheduled infrastructure maintenance — database migration and certificate rotation"
  )
end

# One state currently down (West Virginia — true to its lore)
State.find_by(abbreviation: "WV")&.state_status&.update!(
  status: "down",
  outage_reason: nil,
  planned_outage_start: nil,
  planned_outage_end: nil
)

puts "\nDone. #{State.count} states, #{StateStatus.count} statuses seeded."
