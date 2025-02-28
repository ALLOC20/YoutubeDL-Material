#!/bin/sh
cat << EOF > /app/backend/appdata/default.json
{
  "YoutubeDLMaterial": {
    "Host": {
      "url": "http://example.com",
      "port": ${PORT}
    },
    "Downloader": {
      "path-audio": "audio/",
      "path-video": "video/",
      "default_file_output": "",
      "use_youtubedl_archive": false,
      "custom_args": "",
      "safe_download_override": false,
      "include_thumbnail": true,
      "include_metadata": true,
      "download_rate_limit": ""
    },
    "Extra": {
      "title_top": "YoutubeDL-Material",
      "file_manager_enabled": true,
      "allow_quality_select": true,
      "download_only_mode": false,
      "allow_multi_download_mode": true,
      "enable_downloads_manager": true,
      "allow_playlist_categorization": true
    },
    "API": {
      "use_API_key": false,
      "API_key": "",
      "use_youtube_API": false,
      "youtube_API_key": "",
      "use_twitch_API": false,
      "twitch_API_key": "",
      "twitch_auto_download_chat": false,
      "use_sponsorblock_API": false
    },
    "Themes": {
      "default_theme": "default",
      "allow_theme_change": true
    },
    "Subscriptions": {
      "allow_subscriptions": true,
      "subscriptions_base_path": "subscriptions/",
      "subscriptions_check_interval": "300",
      "redownload_fresh_uploads": false,
      "download_delay": ""
    },
    "Users": {
      "base_path": "users/",
      "allow_registration": true,
      "auth_method": "internal",
      "ldap_config": {
        "url": "ldap://localhost:389",
        "bindDN": "cn=root",
        "bindCredentials": "secret",
        "searchBase": "ou=passport-ldapauth",
        "searchFilter": "(uid={{username}})"
      }
    },
    "Database": {
      "use_local_db": true,
      "mongodb_connection_string": "mongodb://127.0.0.1:27017/?compressors=zlib"
    },
    "Advanced": {
      "default_downloader": "youtube-dl",
      "use_default_downloading_agent": true,
      "custom_downloading_agent": "",
      "multi_user_mode": false,
      "allow_advanced_download": false,
      "use_cookies": false,
      "jwt_expiration": 86400, 
      "logger_level": "info"
    }
  }
}
EOF

set -eu

CMD="forever app.js"

# if the first arg starts with "-" pass it to program
if [ "${1#-}" != "$1" ]; then
  set -- "$CMD" "$@"
fi

# chown current working directory to current user
if [ "$*" = "$CMD" ] && [ "$(id -u)" = "0" ]; then
  find . \! -user "$UID" -exec chown "$UID:$GID" -R '{}' + || echo "WARNING! Could not change directory ownership. If you manage permissions externally this is fine, otherwise you may experience issues when downloading or deleting videos."
  exec su-exec "$UID:$GID" "$0" "$@"
fi

exec "$@"
