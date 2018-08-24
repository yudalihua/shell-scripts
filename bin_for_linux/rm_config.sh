#!/bin/bash
cat <<EOF >>$HOME/.bash_profile
unalias cp
unalias rm
alias rm='/bin/newrm'
EOF
mv ./newrm /bin/newrm
. $HOME/.bash_profile
chmod 755 /bin/newrm
