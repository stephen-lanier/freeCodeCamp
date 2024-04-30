#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"
MAX_SCORE=$(( 1000 ))

PLAY_GAME() {
  if [[ $1 ]]
  then
    echo $1
  fi

  read GUESS
  (( GUESS_COUNT++ ))
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    PLAY_GAME "That is not an integer, guess again:"
  else
    if (( GUESS < SECRET_NUMBER ))
    then
      PLAY_GAME "It's higher than that, guess again:"
    elif (( GUESS > SECRET_NUMBER ))
    then
      PLAY_GAME "It's lower than that, guess again:"
    else
      echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    fi
  fi
  
}

GET_USERNAME() {
  echo "Enter your username:"
  read USERNAME
  if [[ ! $USERNAME =~ ^.{1,22}$ ]]
  then
    echo "Usernames can be a maximum of 22 characters."
    GET_USERNAME
  else 
    GET_USER_RESULT="$($PSQL"select user_id, username, num_games, best_score from users where username='$USERNAME'")"
    if [[ -z $GET_USER_RESULT ]]
    then
      INSERT_RESULT="$($PSQL"insert into users (username, best_score) values ('$USERNAME', $MAX_SCORE)")"
      USER_ID="$($PSQL"select user_id from users where username='$USERNAME'")"
      NUM_GAMES=$(( 0 ))
      BEST_SCORE=$(( MAX_SCORE ))
      if [[ $INSERT_RESULT ]]
      then
        echo -e "Welcome, $USERNAME! It looks like this is your first time here.\n"
        PLAY_GAME "Guess the secret number between 1 and 1000:"
      else
        echo -e "Failed to create new user $USERNAME.\n"
      fi
    else
      IFS="|" read USER_ID USERNAME NUM_GAMES BEST_SCORE <<< $GET_USER_RESULT
      echo "Welcome back, $USERNAME! You have played $NUM_GAMES games, and your best game took $BEST_SCORE guesses."
      PLAY_GAME "Guess the secret number between 1 and 1000:"
    fi
  fi
}

SECRET_NUMBER=$(( 1 + RANDOM%1000 ))
GUESS_COUNT=$(( 0 ))
GET_USERNAME

if (( GUESS_COUNT < BEST_SCORE ))
then
BEST_SCORE=$(( GUESS_COUNT ))
fi
(( NUM_GAMES++ ))

UPDATE_RESULT="$($PSQL"update users set num_games=$NUM_GAMES, best_score=$BEST_SCORE where user_id=$USER_ID")"
if [[ -z $UPDATE_RESULT ]]
then
  echo "Failed to update database with most recent game stats. Sorry :("
fi