#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL"truncate table games, teams")"
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    #Get winner team_id
    WINNER_ID=$($PSQL"select team_id from teams where name='$WINNER'")
    #if not found insert
    if [[ -z $WINNER_ID ]]
    then
      $PSQL"insert into teams (name) values ('$WINNER')"
      #Get team_id
      WINNER_ID=$($PSQL"select team_id from teams where name='$WINNER'")
      echo $WINNER inserted: $WINNER_ID
    else
      echo $WINNER already exists in table
    fi
    #Get opponent team_id
    OPPONENT_ID=$($PSQL"select team_id from teams where name='$OPPONENT'")
    #if not found insert
    if [[ -z $OPPONENT_ID ]]
    then
      $PSQL"insert into teams (name) values ('$OPPONENT')"
      #Get team_id
      OPPONENT_ID=$($PSQL"select team_id from teams where name='$OPPONENT'")
      echo $OPPONENT inserted: $OPPONENT_ID
    else
      echo $OPPONENT already exists in table
    fi
  fi
  #insert into games
  $PSQL"insert into games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"
  
done