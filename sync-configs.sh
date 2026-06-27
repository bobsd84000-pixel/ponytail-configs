#!/bin/bash
# Ponytail Config Sync v1.0
# Synchronise les configs depuis le repo ponytail

set -e

REPO_URL="https://github.com/DietrichGebert/ponytail.git"
REPO_PATH="./ponytail-src"
TARGET_DIR="./local-configs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🚀 Démarrage sync ponytail..."
echo ""

# Clone ou update
if [ -d "$REPO_PATH/.git" ]; then
  echo "♻️  Update du repo ponytail..."
  cd "$REPO_PATH"
  git pull origin main
  cd ..
else
  echo "📥 Clone du repo ponytail..."
  git clone "$REPO_URL" "$REPO_PATH"
fi

# Créer répertoires
mkdir -p "$TARGET_DIR/backup"
echo "📁 Target: $TARGET_DIR"
echo ""

# Backup existant
if [ "$(ls -A $TARGET_DIR 2>/dev/null)" ]; then
  echo "💾 Backup configs existantes..."
  tar -czf "$TARGET_DIR/backup/config-backup-$TIMESTAMP.tar.gz" \
    $(ls -d $TARGET_DIR/.* 2>/dev/null | grep -v "^\.$\|^\.\.$\|backup") \
    2>/dev/null || true
  echo "✓ Backup créé"
  echo ""
fi

# Dossiers à syncer
FOLDERS=(
  ".agents"
  ".claude-plugin"
  ".clinerules"
  ".codex-plugin"
  ".cursor"
  ".devin-plugin"
  ".github"
  ".kiro"
  ".openclaw"
  ".opencode"
  ".windsurf"
)

# Sync
echo "🔄 Synchronisation..."
SYNCED=0
for folder in "${FOLDERS[@]}"; do
  if [ -d "$REPO_PATH/$folder" ]; then
    echo "  ✓ $folder"
    mkdir -p "$TARGET_DIR/$folder"
    cp -r "$REPO_PATH/$folder"/* "$TARGET_DIR/$folder/" 2>/dev/null || true
    ((SYNCED++))
  fi
done
echo ""

# Résumé
echo "📊 Résumé:"
echo "  ✓ $SYNCED dossiers synced"
echo "  📦 Taille: $(du -sh $TARGET_DIR | cut -f1)"
echo "  🕐 Date: $TIMESTAMP"
echo ""

echo "✅ Sync complétée!"
