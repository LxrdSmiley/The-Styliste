# Vector Container Restart Loop - Fix Instructions

## Problem
The `supabase_vector_The-Styliste` container is stuck in a restart loop (332+ restarts) due to:
1. **Inaccessible Docker daemon**: The container couldn't connect to Docker daemon via `DOCKER_HOST=http://host.docker.internal:2375`
2. **Missing Docker socket**: The Vector container needs direct access to `/var/run/docker.sock` to read container logs
3. **Blocking startup script**: The `until` loop waiting for analytics can hang Docker

## Solution
Recreate the Vector container with proper Docker socket mounting and a timeout-aware startup script.

## Steps to Fix

### 1. Stop and remove the broken container
```powershell
docker rm -f supabase_vector_The-Styliste
```

### 2. Recreate the container with the correct configuration
```powershell
docker run -d `
  --name supabase_vector_The-Styliste `
  --network supabase_network_The-Styliste `
  --restart unless-stopped `
  -v /var/run/docker.sock:/var/run/docker.sock `
  -l com.docker.compose.project=The-Styliste `
  -l com.supabase.cli.project=The-Styliste `
  --health-cmd='wget --no-verbose --tries=1 --spider http://127.0.0.1:9001/health' `
  --health-interval=10s `
  --health-timeout=2s `
  --health-retries=3 `
  --entrypoint /bin/sh `
  public.ecr.aws/supabase/vector:0.53.0-alpine `
  /vector-startup.sh
```

Wait, this requires the script to be baked into the image. Instead, use this simpler inline approach:

```powershell
docker run -d `
  --name supabase_vector_The-Styliste `
  --network supabase_network_The-Styliste `
  --restart unless-stopped `
  -v /var/run/docker.sock:/var/run/docker.sock `
  -l com.docker.compose.project=The-Styliste `
  -l com.supabase.cli.project=The-Styliste `
  --health-cmd='wget --no-verbose --tries=1 --spider http://127.0.0.1:9001/health' `
  --health-interval=10s `
  --health-timeout=2s `
  --health-retries=3 `
  --entrypoint /bin/sh `
  public.ecr.aws/supabase/vector:0.53.0-alpine `
  -c @"
cat > /etc/vector/vector.yaml << 'VECTOR_CONFIG'
api:
  enabled: true
  address: 0.0.0.0:9001

sources:
  docker_host:
    type: docker_logs
    exclude_containers:
      - "supabase_vector_The-Styliste"

transforms:
  project_logs:
    type: remap
    inputs:
      - docker_host
    source: |-
      .project = "default"
      .event_message = del(.message)
      .appname = del(.container_name)
      del(.container_created_at)
      del(.container_id)
      del(.source_type)
      del(.stream)
      del(.label)
      del(.image)
      del(.host)
      del(.stream)
  router:
    type: route
    inputs:
      - project_logs
    route:
      kong: '.appname == "supabase_kong_The-Styliste"'
      auth: '.appname == "supabase_auth_The-Styliste"'
      rest: '.appname == "supabase_rest_The-Styliste"'
      realtime: '.appname == "supabase_realtime_The-Styliste"'
      storage: '.appname == "supabase_storage_The-Styliste"'
      functions: '.appname == "supabase_edge_runtime_The-Styliste"'
      db: '.appname == "supabase_db_The-Styliste"'
  kong_logs:
    type: remap
    inputs:
      - router.kong
    source: |-
      req, err = parse_nginx_log(.event_message, "combined")
      if err == null {
          .timestamp = req.timestamp
          .metadata.request.headers.referer = req.referer
          .metadata.request.headers.user_agent = req.agent
          .metadata.request.headers.cf_connecting_ip = req.client
          .metadata.response.status_code = req.status
          url, split_err = split(req.request, " ")
          if split_err == null {
              .metadata.request.method = url[0]
              .metadata.request.path = url[1]
              .metadata.request.protocol = url[2]
          }
      }
      if err != null {
        abort
      }
  kong_err:
    type: remap
    inputs:
      - router.kong
    source: |-
      .metadata.request.method = "GET"
      .metadata.response.status_code = 200
      parsed, err = parse_nginx_log(.event_message, "error")
      if err == null {
          .timestamp = parsed.timestamp
          .severity = parsed.severity
          .metadata.request.host = parsed.host
          .metadata.request.headers.cf_connecting_ip = parsed.client
          url, err = split(parsed.request, " ")
          if err == null {
              .metadata.request.method = url[0]
              .metadata.request.path = url[1]
              .metadata.request.protocol = url[2]
          }
      }
      if err != null {
        abort
      }
  auth_logs:
    type: remap
    inputs:
      - router.auth
    source: |-
      parsed, err = parse_json(.event_message)
      if err == null {
          .metadata.timestamp = parsed.time
          .metadata = merge!(.metadata, parsed)
      }
  rest_logs:
    type: remap
    inputs:
      - router.rest
    source: |-
      parsed, err = parse_regex(.event_message, r'^(?P<time>.*): (?P<msg>.*)$')
      if err == null {
          .event_message = parsed.msg
          .timestamp = parse_timestamp!(value: parsed.time, format: "%d/%b/%Y:%H:%M:%S %z")
          .metadata.host = .project
      }
  realtime_logs:
    type: remap
    inputs:
      - router.realtime
    source: |-
      .metadata.project = del(.project)
      .metadata.external_id = .metadata.project
      parsed, err = parse_regex(.event_message, r'^(?P<time>\d+:\d+:\d+\.\d+) \[(?P<level>\w+)\] (?P<msg>.*)$')
      if err == null {
          .event_message = parsed.msg
          .metadata.level = parsed.level
      }
  functions_logs:
    type: remap
    inputs:
      - router.functions
    source: |-
      .metadata.project_ref = del(.project)
  storage_logs:
    type: remap
    inputs:
      - router.storage
    source: |-
      .metadata.project = del(.project)
      .metadata.tenantId = .metadata.project
      parsed, err = parse_json(.event_message)
      if err == null {
          .event_message = parsed.msg
          .metadata.level = parsed.level
          .metadata.timestamp = parsed.time
          .metadata.context[0].host = parsed.hostname
          .metadata.context[0].pid = parsed.pid
      }
  db_logs:
    type: remap
    inputs:
      - router.db
    source: |-
      .metadata.host = "db-default"
      .metadata.parsed.timestamp = .timestamp

      parsed, err = parse_regex(.event_message, r'.*(?P<level>INFO|NOTICE|WARNING|ERROR|LOG|FATAL|PANIC?):.*', numeric_groups: true)

      if err != null || parsed == null || parsed.level == null {
        .metadata.parsed.error_severity = "info"
      } else {
        .metadata.parsed.error_severity = parsed.level
      }
      if .metadata.parsed.error_severity == "info" {
          .metadata.parsed.error_severity = "log"
      }
      .metadata.parsed.error_severity = upcase!(.metadata.parsed.error_severity)

sinks:
  logflare_auth:
    type: "http"
    inputs:
      - auth_logs
    encoding:
      codec: "json"
    method: "post"
    request:
      retry_max_duration_secs: 10
      headers:
        x-api-key: "api-key"
    uri: "http://supabase_analytics_The-Styliste:4000/api/logs?source_name=gotrue.logs.prod"
  logflare_realtime:
    type: "http"
    inputs:
      - realtime_logs
    encoding:
      codec: "json"
    method: "post"
    request:
      retry_max_duration_secs: 10
      headers:
        x-api-key: "api-key"
    uri: "http://supabase_analytics_The-Styliste:4000/api/logs?source_name=realtime.logs.prod"
  logflare_rest:
    type: "http"
    inputs:
      - rest_logs
    encoding:
      codec: "json"
    method: "post"
    request:
      retry_max_duration_secs: 10
      headers:
        x-api-key: "api-key"
    uri: "http://supabase_analytics_The-Styliste:4000/api/logs?source_name=postgREST.logs.prod"
  logflare_db:
    type: "http"
    inputs:
      - db_logs
    encoding:
      codec: "json"
    method: "post"
    request:
      retry_max_duration_secs: 10
      headers:
        x-api-key: "api-key"
    uri: "http://supabase_analytics_The-Styliste:4000/api/logs?source_name=postgres.logs"
  logflare_functions:
    type: "http"
    inputs:
      - functions_logs
    encoding:
      codec: "json"
    method: "post"
    request:
      retry_max_duration_secs: 10
      headers:
        x-api-key: "api-key"
    uri: "http://supabase_analytics_The-Styliste:4000/api/logs?source_name=deno-relay-logs"
  logflare_storage:
    type: "http"
    inputs:
      - storage_logs
    encoding:
      codec: "json"
    method: "post"
    request:
      retry_max_duration_secs: 10
      headers:
        x-api-key: "api-key"
    uri: "http://supabase_analytics_The-Styliste:4000/api/logs?source_name=storage.logs.prod.2"
  logflare_kong:
    type: "http"
    inputs:
      - kong_logs
      - kong_err
    encoding:
      codec: "json"
    method: "post"
    request:
      retry_max_duration_secs: 10
      headers:
        x-api-key: "api-key"
    uri: "http://supabase_analytics_The-Styliste:4000/api/logs?source_name=cloudflare.logs.prod"

VECTOR_CONFIG

timeout 120 sh -c 'until wget --no-verbose --tries=1 --spider http://supabase_analytics_The-Styliste:4000/health 2>/dev/null; do sleep 2; done' || true
exec vector --config /etc/vector/vector.yaml
"@
```

### 3. Verify the container is running
```powershell
docker ps --filter "name=supabase_vector_The-Styliste" --format "table {{.Names}}\t{{.Status}}"
```

### 4. Check logs
```powershell
docker logs supabase_vector_The-Styliste --tail 20
```

## Key Changes
- ✅ **Docker socket mounted**: `-v /var/run/docker.sock:/var/run/docker.sock`
- ✅ **Timeout added**: `timeout 120` prevents infinite blocking on analytics health check
- ✅ **DOCKER_HOST removed**: No longer trying to use unreliable HTTP endpoint
- ✅ **Proper entrypoint**: Using `/bin/sh -c` for clean script execution

## If Docker is still hung
1. Restart Docker Desktop: Settings → General → Restart Docker Desktop
2. Or in PowerShell: `& 'C:\Program Files\Docker\Docker\Docker.exe' -Restart`
