#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


# clean tables
echo $($PSQL "TRUNCATE teams, games")

# insert teams info into teams table
# read games.csv file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINGOALS OPPOGOALS
do
  # skip header line
  if [[ $YEAR != 'year' ]]
  then
    # get winner game
    FIND_WINNER=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER'")
    # if not found, add it to table
    if [[ -z $FIND_WINNER ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      echo $INSERT_WINNER_RESULT $WINNER
    fi
    # get opponent name
    FIND_OPPONENT=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT'")
    # if not found, insert it to teams table
    if [[ -z $FIND_OPPONENT ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      echo $INSERT_WINNER_RESULT $OPPONENT
    fi
  fi
done


# insert games data into games table
# read games.csv file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINGOALS OPPOGOALS
do
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
  # skip header line
  if [[ $YEAR != 'year' ]]
  then
    # find game in games table
    FIND_GAME=$($PSQL "SELECT year, round, winner_id, opponent_id FROM games WHERE year = $YEAR AND round = '$ROUND' AND winner_id = $WINNER_ID AND opponent_id = $OPPONENT_ID")
    # if not found
    if [[ -z $FIND_GAME ]]
    then
      # insert new game
      INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINGOALS, $OPPOGOALS)")
      echo $INSERT_GAME $YEAR $ROUND $WINNER $OPPONENT $WINGOALS $OPPOGOALS
    fi
  fi
done
