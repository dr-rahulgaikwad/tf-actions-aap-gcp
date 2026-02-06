#!/bin/bash

AAP_BASE="https://sandbox-aap-dr-rahul-gaikwad-dev.apps.rm2.thpm.p1.openshiftapps.com"

echo "=== Testing AAP Endpoints ==="
echo ""

# Test endpoints
endpoints=(
  "/"
  "/api"
  "/api/"
  "/api/v2"
  "/api/v2/"
  "/api/v2/ping"
  "/api/v2/ping/"
  "/api/controller/v2/ping"
  "/api/controller/v2/ping/"
  "/api/gateway/v1/ping"
  "/api/gateway/v1/ping/"
)

for endpoint in "${endpoints[@]}"; do
  echo "Testing: ${AAP_BASE}${endpoint}"
  response=$(curl -s -o /dev/null -w "%{http_code}" "${AAP_BASE}${endpoint}")
  echo "  HTTP Status: ${response}"
  
  if [ "$response" = "200" ]; then
    echo "  ✅ SUCCESS! This endpoint works!"
    echo "  Full URL: ${AAP_BASE}${endpoint}"
  fi
  echo ""
done

echo "=== Testing Complete ==="

