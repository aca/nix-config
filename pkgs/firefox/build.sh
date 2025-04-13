#!/usr/bin/env bash
set -euxo pipefail
cat "includes/cascade-config.css" > userChrome.css
cat "includes/cascade-colours.css" >> userChrome.css
cat "includes/cascade-layout.css" >> userChrome.css
cat "includes/cascade-responsive.css" >> userChrome.css
cat "includes/cascade-floating-panel.css" >> userChrome.css
cat "includes/cascade-nav-bar.css" >> userChrome.css
cat "includes/cascade-tabs.css" >> userChrome.css

# cat "includes/tabs_on_bottom.css" >> userChrome.css

cat <<EOF >>userChrome.css
/* Source file https://github.com/MrOtherGuy/firefox-csshacks/tree/master/chrome/numbered_tabs.css made available under Mozilla Public License v. 2.0
See the above repository for updates as well as full license text. */

/* Show a number before tab text*/

.tabbrowser-tab:first-child{ counter-reset: nth-tab 0 } /* Change to -1 for 0-indexing */
.tab-text::before{ content: counter(nth-tab) " "; counter-increment: nth-tab }
EOF


# hide displaybar
cat <<EOF >>userChrome.css
#PersonalToolbar {
    display: none;
}
EOF

echo build

