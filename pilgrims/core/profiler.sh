#!/bin/bash
profile_target() {
    local target=$1
    local html=$(curl -k -s -m 5 "$target" 2>/dev/null)
    if echo "$html" | grep -qi "wp-content\|wordpress"; then echo "cms:WordPress"
    elif echo "$html" | grep -qi "joomla"; then echo "cms:Joomla"
    elif echo "$html" | grep -qi "laravel"; then echo "framework:Laravel"
    elif echo "$html" | grep -qi "express\|node"; then echo "runtime:Node.js"
    elif echo "$html" | grep -qi "shopify\|woocommerce"; then echo "ecommerce:Yes"
    else echo "type:generic"
    fi
}
