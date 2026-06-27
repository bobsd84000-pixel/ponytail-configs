name: Sync Configs

on:
  workflow_dispatch:
  schedule:
    - cron: '0 9 * * 1'

jobs:
  sync:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Clone ponytail source
        run: |
          git clone https://github.com/DietrichGebert/ponytail.git ponytail-src

      - name: Sync configs
        run: |
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
          
          for folder in "${FOLDERS[@]}"; do
            if [ -d "ponytail-src/$folder" ]; then
              echo "✓ $folder"
              mkdir -p "local-configs/$folder"
              cp -r "ponytail-src/$folder/." "local-configs/$folder/"
            fi
          done

      - name: Commit & Push
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add -A
          git diff --staged --quiet || git commit -m "sync: ponytail configs"
          git push
