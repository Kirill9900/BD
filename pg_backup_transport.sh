#!/usr/bin/env bash
set -euo pipefail

# ========== CONFIG ==========
# Папка для бэкапов
OUTDIR="/backups/postgres_transport"
# База данных
DB="transport_monitoring"
# Схема, которую хотим дампить
SCHEMA="transport"
# Сколько дней хранить (integer)
RETENTION_DAYS=14
# Включать ли полный дамп (true/false)
DO_FULL_DUMP=false
# (опционально) удалённое хранение (rsync/scp)
DO_RSYNC=false
REMOTE_USER="backup"
REMOTE_HOST="backup.example.com"
REMOTE_DIR="/backups/postgres_transport"
# ============================

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "${OUTDIR}"
cd "${OUTDIR}"

LOGFILE="${OUTDIR}/backup_${TIMESTAMP}.log"
exec > >(tee -a "${LOGFILE}") 2>&1

echo "===== POSTGRES BACKUP START ${TIMESTAMP} ====="
echo "User: $(whoami)"
echo "DB: ${DB}, SCHEMA: ${SCHEMA}"
echo "Outdir: ${OUTDIR}"

# 1) Dump globals (roles, tablespaces, etc)
echo "[1] Dump globals..."
pg_dumpall --globals-only > "${OUTDIR}/globals_${TIMESTAMP}.sql" || { echo "pg_dumpall failed"; exit 1; }

# 2) Dump schema+data (custom format)
echo "[2] Dump schema ${SCHEMA} (custom format)..."
pg_dump -n "${SCHEMA}" -Fc -f "${OUTDIR}/${SCHEMA}_${TIMESTAMP}.dump" "${DB}" || { echo "pg_dump schema failed"; exit 1; }

# 3) Optional: full DB dump
if [ "${DO_FULL_DUMP}" = true ]; then
  echo "[3] Full DB dump (custom format)..."
  pg_dump -Fc -f "${OUTDIR}/full_${TIMESTAMP}.dump" "${DB}" || { echo "pg_dump full failed"; exit 1; }
fi

# 4) Copy PostgreSQL config files
echo "[4] Copying PostgreSQL config files..."
CONFIG_FILE=$(psql -At -c "SHOW config_file;")
HBA_FILE=$(psql -At -c "SHOW hba_file;") || HBA_FILE=""

echo "config_file: ${CONFIG_FILE}"
echo "hba_file: ${HBA_FILE}"

if [ -n "${CONFIG_FILE}" ]; then
  sudo cp "${CONFIG_FILE}" "${OUTDIR}/postgresql.conf_${TIMESTAMP}" 2>/dev/null || echo "Warning: cannot copy ${CONFIG_FILE}"
fi
if [ -n "${HBA_FILE}" ]; then
  sudo cp "${HBA_FILE}" "${OUTDIR}/pg_hba.conf_${TIMESTAMP}" 2>/dev/null || echo "Warning: cannot copy ${HBA_FILE}"
fi

# 5) Create archive
echo "[5] Creating archive..."
tar -czf "${OUTDIR}/backup_${TIMESTAMP}.tar.gz" -C "${OUTDIR}" "globals_${TIMESTAMP}.sql" "${SCHEMA}_${TIMESTAMP}.dump" --ignore-failed-read || echo "Tar warning"

if [ "${DO_FULL_DUMP}" = true ] && [ -f "${OUTDIR}/full_${TIMESTAMP}.dump" ]; then
  tar --append -f "${OUTDIR}/backup_${TIMESTAMP}.tar.gz" -C "${OUTDIR}" "full_${TIMESTAMP}.dump" || true
fi

# 6) Create manifest
echo "{ \"timestamp\": \"${TIMESTAMP}\", \"db\": \"${DB}\", \"schema\": \"${SCHEMA}\" }" > "${OUTDIR}/manifest_${TIMESTAMP}.json"

# 7) Rotate old backups
echo "[7] Removing backups older than ${RETENTION_DAYS} days..."
find "${OUTDIR}" -type f -mtime +"${RETENTION_DAYS}" -exec rm -f {} \; || true

# 8) Optionally sync to remote
if [ "${DO_RSYNC}" = true ]; then
  echo "[8] Rsync to remote ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"
  rsync -avz --remove-source-files "${OUTDIR}/backup_${TIMESTAMP}.tar.gz" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/" || echo "rsync failed"
fi

echo "===== POSTGRES BACKUP FINISHED ${TIMESTAMP} ====="
echo "Log: ${LOGFILE}"
