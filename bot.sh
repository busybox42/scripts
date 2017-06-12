#!/bin/bash

# PokemonGo Bot Tmux Script

SESSION='bot'
DIR='/home/alan/repos/PokemonGo-Bot'
PMUX=`ps -ef |grep tmux|grep bot|grep -v grep|awk '{print $2}'`
PKPID=`ps -ef |grep pokecli.py|grep -v grep|awk '{print$2}'`
HTTPPID=`ps -ef |grep SimpleHTTPServer|grep -v grep|awk '{print$2}'`
RAND=`ls $DIR/configs/ |grep "auth.json." |sort -R |tail -n1`
NME=`echo $RAND|awk -F "." '{print $3}'`

case $1 in
  start)
    echo "Starting PokemonGo Bot."
    tmux -2 new-session -d -s $SESSION
    # Setup Windows
    tmux new-window -t $SESSION -n 'bot'
    tmux split-window -v
    tmux split-window -h
    tmux select-pane -t 1
    tmux select-pane -t 1
    tmux send-keys "cd $DIR && ./run.sh" C-m
    tmux select-pane -t 2
    tmux send-keys "cd $DIR/web" C-m
    tmux send-keys "python2 -m SimpleHTTPServer" C-m
    #tmux select-pane -t 3
    #tmux send-keys "cd $DIR/map-chat" C-m
    #tmux send-keys "python2 -m SimpleHTTPServer 8080" C-m
    tmux select-pane -t 1
    ;;
  random)
    echo "Starting Random PokemonGo Bot - $NME."
    cp $DIR/configs/$RAND $DIR/configs/auth.json
    #cp $DIR/web/config/userdata.js.$NME $DIR/web/config/userdata.js
    tmux -2 new-session -d -s $SESSION
    # Setup Windows
    tmux new-window -t $SESSION -n 'bot'
    tmux split-window -v
    tmux split-window -h
    tmux select-pane -t 1
    tmux select-pane -t 1
    tmux send-keys "cd $DIR && ./run.sh" C-m
    tmux select-pane -t 2
    tmux send-keys "cd $DIR/web" C-m
    tmux send-keys "python2 -m SimpleHTTPServer" C-m
    #tmux select-pane -t 3
    #tmux send-keys "cd $DIR/map-chat" C-m
    #tmux send-keys "python2 -m SimpleHTTPServer 8080" C-m
    tmux select-pane -t 1
    ;;
  stop)
    if [ -n "$PMUX" ];
    then
      echo "Stopping PokemonGo Bot. PID ${PMUX}"
      tmux kill-session -t $SESSION
    else
      echo "PokemonGo Bot not running."
    fi
    ;;
  status)
    if [ -n "$PMUX" ];
    then
      echo "PokemonGo Bot tmux session.   PID: ${PKPID}"
      if [ -n "$PKPID" ];
      then
        echo "PokemonGo Bot is running.     PID: ${PKPID}"
      else
        echo "PokemonGo Bot is dead."
      fi
      if [ -n "$HTTPPID" ];
      then
        echo "PokemonGo Bot Web is running. PID ${HTTPPID}"
      else
        echo "PokemonGo Bot Web is dead."
      fi
    else
      echo "PokemonGo Bot not running."
    fi
    ;;
  attach)
    tmux a -t $SESSION
    ;;
  account)
    if [ "$2" == "list" ]
    then
      LST=`ls $DIR/configs/ |grep "auth.json." |awk -F "." '{print $3}'`
      for i in $LST
      do
        echo $i
      done
    else
      if [ ! -f $DIR/configs/auth.json.$2 ]
      then
        echo "$2 does not exist!"
      else
        echo "Starting PokemonGo Bot - $2."
        cp $DIR/configs/auth.json.$2 $DIR/configs/auth.json
        #cp $DIR/web/config/userdata.js.$NME $DIR/web/config/userdata.js
        tmux -2 new-session -d -s $SESSION
        # Setup Windows
        tmux new-window -t $SESSION -n 'bot'
        tmux split-window -v
        tmux split-window -h
        tmux select-pane -t 1
        tmux select-pane -t 1
        tmux send-keys "cd $DIR && ./run.sh" C-m
        tmux select-pane -t 2
        tmux send-keys "cd $DIR/web" C-m
        tmux send-keys "python2 -m SimpleHTTPServer" C-m
        #tmux select-pane -t 3
        #tmux send-keys "cd $DIR/map-chat" C-m
        #tmux send-keys "python2 -m SimpleHTTPServer 8080" C-m
        tmux select-pane -t 1
      fi
    fi
    ;;

  *)
    echo "  -=< PokemonGo Bot Tmux Session>=-"
    echo "-------------------------------------"
    echo "| Options:                          |"
    echo "-------------------------------------"
    echo "| start  - Starts pokicly and http  |"
    echo "|          web server in tmux.      |"
    echo "| random - Start a random bot.      |"
    echo "| stop   - Stop PokemonGo Bot.      |"
    echo "| status - Show running status.     |"
    echo "| attach - Attach to tmux session.  |"    
    echo "-------------------------------------"
    ;;
esac
