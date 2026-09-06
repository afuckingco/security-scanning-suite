#!/bin/bash
# Strict mode guard (errexit + nounset + pipefail)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/core/strict.sh"
echo "🔍 PILGRIMS DIAGNOSTIC TOOL"
echo "═══════════════════════════════════════════════════"
echo ""

echo "📂 Current directory: $(pwd)"
echo "👤 User: $(whoami)"
echo "🐧 Shell: $SHELL"
echo ""

echo "[CHECK 1] File permissions:"
ls -la pilgrims.sh 2>/dev/null || echo "❌ pilgrims.sh NOT FOUND"
echo ""

echo "[CHECK 2] Line endings (should show 'ASCII text'):"
file pilgrims.sh 2>/dev/null
echo ""

echo "[CHECK 3] Shebang line:"
head -1 pilgrims.sh 2>/dev/null
echo ""

echo "[CHECK 4] Syntax check:"
bash -n pilgrims.sh 2>&1 && echo "✓ Syntax OK" || echo "❌ Syntax error"
echo ""

echo "[CHECK 5] Test execution:"
bash pilgrims.sh --help 2>&1 | head -5
echo ""

echo "[CHECK 6] Core files:"
for f in core/ui.sh core/database.sh core/utils.sh; do
    [ -f "$f" ] && echo "   ✓ $f" || echo "   ❌ $f MISSING"
done
echo ""

echo "[CHECK 7] Module files:"
for m in web network email; do
    [ -f "modules/module-$m/pilgrims-$m.sh" ] && echo "   ✓ module-$m" || echo "   ⊘ module-$m not found"
done
echo ""
echo "═══════════════════════════════════════════════════"
