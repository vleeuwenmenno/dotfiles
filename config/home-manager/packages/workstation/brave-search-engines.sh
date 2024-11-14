#!/usr/bin/env bash

BRAVE_DIR="$HOME/.config/BraveSoftware/Brave-Browser/Default"
MAX_ATTEMPTS=30  # Maximum number of seconds to wait

# Function to kill all Brave processes
kill_brave() {
  # Store whether Brave was running
  if pgrep -x "brave" > /dev/null; then
    echo "Brave was running, will restart after completion"
    export BRAVE_WAS_RUNNING=1
  else
    export BRAVE_WAS_RUNNING=0
  fi

  echo "Closing all Brave browser instances..."
  pkill -x "brave" || true
  sleep 2  # Give it a moment to clean up
  
  # Force kill if any processes remain
  if pgrep -x "brave" > /dev/null; then
    echo "Force closing remaining Brave processes..."
    pkill -9 -x "brave" || true
  fi
}

# Function to check if database is locked
is_db_locked() {
  local db_file="$1"
  if lsof "$db_file" >/dev/null 2>&1; then
    return 0  # true, db is locked
  else
    return 1  # false, db is not locked
  fi
}

# Check if profile exists
if [ ! -d "$BRAVE_DIR" ]; then
  echo "Brave profile directory doesn't exist. Please run Brave at least once."
  exit 1
fi

# Check if Web Data exists
if [ ! -f "$BRAVE_DIR/Web Data" ]; then
  echo "Web Data file doesn't exist. Please run Brave at least once."
  exit 1
fi

# Kill any running Brave instances
kill_brave

# Wait for database to be unlocked
attempts=0
while is_db_locked "$BRAVE_DIR/Web Data" && [ $attempts -lt $MAX_ATTEMPTS ]; do
  echo "Database is locked. Waiting... ($attempts/$MAX_ATTEMPTS)"
  sleep 1
  attempts=$((attempts + 1))
done

if is_db_locked "$BRAVE_DIR/Web Data"; then
  echo "Database is still locked after $MAX_ATTEMPTS seconds. Please ensure Brave is completely closed and try again."
  exit 1
fi

echo "Setting up search engines..."

# Create temporary file for SQL commands
SQLCOMMANDS=$(mktemp)

cat > $SQLCOMMANDS << 'ENDSQL'
DELETE FROM keywords WHERE keyword NOT IN ('@bookmarks', '@history');

INSERT INTO keywords (
  short_name, keyword, favicon_url, url, safe_for_autoreplace, 
  date_created, usage_count, input_encodings, suggest_url, prepopulate_id, 
  sync_guid, alternate_urls, last_visited, is_active
) VALUES 
(
  'Brave', ':br', 
  'https://cdn.search.brave.com/serp/v2/_app/immutable/assets/favicon.acxxetWH.ico',
  'https://search.brave.com/search?q={searchTerms}&source=desktop',
  1, 0, 0, 'UTF-8',
  'https://search.brave.com/api/suggest?q={searchTerms}&rich=true&source=desktop',
  550, '485bf7d3-0215-45af-87dc-538868000550', '[]', 0, 0
),
(
  'Google', ':gg',
  'https://www.google.com/images/branding/product/ico/googleg_alldp.ico',
  '{google:baseURL}search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:language}{google:prefetchSource}{google:searchClient}{google:sourceId}{google:contextualSearchVersion}ie={inputEncoding}',
  1, 0, 0, 'UTF-8',
  '{google:baseSuggestURL}search?{google:searchFieldtrialParameter}client={google:suggestClient}&gs_ri={google:suggestRid}&xssi=t&q={searchTerms}&{google:inputType}{google:omniboxFocusType}{google:cursorPosition}{google:currentPageUrl}{google:pageClassification}{google:clientCacheTimeToLive}{google:searchVersion}{google:sessionToken}{google:prefetchQuery}sugkey={google:suggestAPIKeyParameter}',
  1, '485bf7d3-0215-45af-87dc-538868000001', '[]', 0, 0
),
(
  'DuckDuckGo', ':dd',
  'https://duckduckgo.com/favicon.ico',
  'https://duckduckgo.com/?q={searchTerms}&t=brave',
  1, 0, 0, 'UTF-8',
  'https://ac.duckduckgo.com/ac/?q={searchTerms}&type=list',
  501, '485bf7d3-0215-45af-87dc-538868000501', '[]', 0, 0
),
(
  'NixOS', ':nix',
  'https://search.nixos.org/favicon.png',
  'https://search.nixos.org/packages?query={searchTerms}',
  1, 0, 0, '',
  '',
  0, '485bf7d3-0215-45af-87dc-538868000552', '[]', 0, 1
),
(
  'GoLink', ':go',
  'http://go/favicon.ico',
  'http://go/{searchTerms}',
  1, 0, 0, '',
  '',
  0, '485bf7d3-0215-45af-87dc-538868000551', '[]', 0, 1
);
ENDSQL

# Execute SQL commands
sqlite3 "$BRAVE_DIR/Web Data" < $SQLCOMMANDS

# Cleanup
rm $SQLCOMMANDS

echo "Search engines setup completed successfully!"

# Restart Brave if it was running before
if [ "$BRAVE_WAS_RUNNING" = "1" ]; then
  echo "Restarting Brave..."
  brave &> /dev/null &
fi
