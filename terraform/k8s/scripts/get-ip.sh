#!/usr/bin/env bash
set -euo pipefail

echo '{"ip":"'"$(curl ifconfig.me)"'"}'
