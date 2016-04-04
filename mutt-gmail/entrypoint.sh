#!/bin/bash
set -e

# mutt config settings
sed -i "s,%MUTT_LOGIN%,$MUTT_EMAIL,g" "$HOME/.mutt/muttrc"
sed -i "s,%MUTT_NAME%,$MUTT_NAME,g" "$HOME/.mutt/muttrc"
sed -i "s,%MUTT_PASS%,$MUTT_PASS,g" "$HOME/.mutt/muttrc"
sed -i "s,%MUTT_FROM%,$MUTT_EMAIL,g" "$HOME/.mutt/muttrc"

# sending mail
sed -i "s,%MUTT%,$MUTT_EMAIL,g" "$HOME/.msmtprc"
sed -i "s,%MUTT_PASS%,$MUTT_PASS,g" "$HOME/.msmtprc"

exec "$@"
