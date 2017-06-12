#######################################################
# Alan Denniston's .bashrc (Work In Progress)
# 
# Last Modified 02-04-2010
#######################################################

if [ "$PS1" ]; then  # If running interactively, then run till fi at EOF:

PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'

# EXPORTS
#######################################################

PATH=$PATH:/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin ;export PATH
export PS1="[\[\h:\e[1;34m\w\e[0m]\n[\t \u]$ "
export LANG=en_US.UTF-8
export LC_ALL=en_US.utf8
export EDITOR=/bin/vi
export HISTFILESIZE=3000 # the bash history should save 3000 commands
export HISTCONTROL=ignoredups #don't put duplicate lines in the history.
alias hist='history | grep $1' #Requires one input
export TERM=linux

# Define a few Color's
BLACK='\e[0;30m'
BLUE='\e[0;34m'
GREEN='\e[0;32m'
CYAN='\e[0;36m'
RED='\e[0;31m'
PURPLE='\e[0;35m'
BROWN='\e[0;33m'
LIGHTGRAY='\e[0;37m'
DARKGRAY='\e[1;30m'
LIGHTBLUE='\e[1;34m'
LIGHTGREEN='\e[1;32m'
LIGHTCYAN='\e[1;36m'
LIGHTRED='\e[1;31m'
LIGHTPURPLE='\e[1;35m'
YELLOW='\e[1;33m'
WHITE='\e[1;37m'
NC='\e[0m'              # No Color

# SOURCED ALIAS'S AND SCRIPTS
#######################################################

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# ALIAS'S
#######################################################

# Admin Commands
blockip () { sudo /sbin/iptables -I INPUT -s "$*" -j DROP; }
unblockip () { sudo /sbin/iptables -D INPUT -s "$*" -j DROP; }
alias stopsmtp='sudo /sbin/iptables -A INPUT -m state --state NEW -m tcp -p tcp -i bond0 --dport 25 -j REJECT'
alias startsmtp='sudo /etc/init.d/iptables stop'

# Alias's to modified commands
alias ps='ps auxf'
alias pg='ps aux | grep'  #requires an argument
alias mountedinfo='df -hT'
alias ping='ping -c 10'
alias openports='sudo netstat -nape --inet'
alias ns='sudo netstat -alnp --protocol=inet | grep -v CLOSE_WAIT | cut -c-6,21-94'
alias du1='sudo du -h --max-depth=1'
alias da='date "+%Y-%m-%d %A    %T %Z"'

# Alias to multiple ls commands
alias la='ls -Al'               # show hidden files
alias ls='ls -F --color=always' # add colors and file type extensions
alias lx='ls -lXB'              # sort by extension
alias lk='ls -lSr'              # sort by size
alias lc='ls -lcr'      # sort by change time
alias lu='ls -lur'      # sort by access time
alias lr='ls -lR'               # recursive ls
alias lt='ls -ltr'              # sort by date
alias lm='ls -al |more'         # pipe through 'more'

# Alias chmod commands
alias mx='chmod a+x'
alias 000='chmod 000'
alias 644='chmod 644'
alias 755='chmod 755'

# SPECIAL FUNCTIONS
#######################################################

netinfo ()
{
echo "--------------- Network Information ---------------"
/sbin/ifconfig | awk /'inet addr/ {print $2}' |sed 's/addr:127.0.0.1//' |sed 's/addr:/IP Address: /' 
/sbin/ifconfig | awk /'Bcast/ {print $3}' |sed 's/Bcast:/Broadcast: /'
/sbin/ifconfig | awk /'inet addr/ {print $4}' |sed 's/Mask:/Netmask: /'
echo "Name Servers:"
grep nameserver /etc/resolv.conf |sed 's/nameserver //'
echo "---------------------------------------------------"
}

# NOTES
#######################################################

# To temporarily bypass an alias, we preceed the command with a \
# EG:  the ls command is aliased, but to use the normal ls command you would
# type \ls

# WELCOME SCREEN
#######################################################
HOST=`/bin/hostname`
clear
echo -ne "${RED}+++++++++++++++${WHITE} $HOST ${RED}+++++++++++++++${NC} ";echo "";
echo -e ${LIGHTBLUE}`cat /proc/version` ;
echo -e "Kernel Information: " `uname -smr`;
echo -e ${LIGHTBLUE}`bash --version`;echo ""
echo -ne "Hello $USER today is "; date
#echo -e "${WHITE}"; cal ; echo "";
#echo -ne "${CYAN}";netinfo;
#df -hT; echo ""
echo -ne "${LIGHTBLUE}Uptime for this computer is ";uptime | awk /'up/ {print $3,$4}'| sed 's/,/./'
UPDATES=`cat ~/bin/chkupdates.state`
KUP=`cat ~/bin/kup.state`
INSK=`pacman -Q linux |awk '{print $2}'`
RUNK=`uname -r |sed 's/-ARCH//'`
if [ "$UPDATES" -gt "0" ] ;then 
  echo -e "${LIGHTBLUE}There are ${YELLOW}$UPDATES ${LIGHTBLUE}packages ready for updates.";
fi
if [[ "$KUP" == "linux"* ]] ;then 
  echo -e "${LIGHTRED}New ${LIGHTBLUE}kernel update! ${LIGHTRED}$KUP"
fi
if [ "$INSK" != "$RUNK" ] ;then
  echo -e "${LIGHTRED}Please reboot you are running an older kernel than is installed!"
  echo -e "${LIGHTBLUE}Running Kernel: ${LIGHTRED}linux-$RUNK  ${LIGHTBLUE}Installed Kernel: ${LIGHTRED}linux-$INSK"
fi  
echo -ne "${RED}+++++++++++++++${WHITE} $HOST ${RED}+++++++++++++++${NC}";echo ""; echo ""; echo ""

fi #end interactive check
alias sudo='sudo env PATH=$PATH'
export PATH=${PATH}:/home/adenniston/android/platform-tools
