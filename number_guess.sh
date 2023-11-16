#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"

# generate a random number
NUM=$((RANDOM % 1000 + 1))

# ask user for username
echo -e "Enter your username:"
read INPUT

USERNAME=$($PSQL "SELECT username FROM users WHERE username='$INPUT'")
# if user isnt in database
if [[ -z $USERNAME ]]; then
  echo "Welcome, $INPUT! It looks like this is your first time here."
  # insert user into database
  USER_INSERT=$($PSQL "INSERT INTO users(username) VALUES('$INPUT')")
  # if user wasn't inserted
  if [[ -z $USER_INSERT ]]; then
    echo Please add a valid username.
    ./number_guess.sh
  fi
else
  # get games played
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games FULL JOIN users USING(user_id) WHERE username='$INPUT'")
  # find best game guesses
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games FULL JOIN users USING(user_id) WHERE username='$INPUT'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
# get user id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$INPUT'")

echo -e "\nGuess the secret number between 1 and 1000:\n"

# initialize tries
TRIES=0
# initialize loop flag
FOUND=false
while ! $FOUND; do
  read GUESS
  # if guess is an integer
  if [[ $GUESS =~ ^[0-9]+$ ]]; then
    let "TRIES++"
    if (( $GUESS > $NUM )); then
      echo "It's lower than that, guess again:"
    elif (( $GUESS < $NUM )); then
      echo "It's higher than that, guess again:"
    else
      echo "You guessed it in $TRIES tries. The secret number was $NUM. Nice job!"
      # insert game into database
      GAME_INSERT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $TRIES)")
      # set found to true to exit the loop
      FOUND=true
    fi
  # if guess is not an integer
  else
    echo That is not an integer, guess again:
  fi
done