#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "Enter your username:"
# get username
read NAME
USERNAME=$NAME
# check if exists
NAME=$($PSQL "SELECT username FROM users WHERE username='$NAME'")

# if not
if [[ -z $NAME ]]
then 
  # add user
  ADD_USERNAME=$($PSQL "INSERT INTO users(username, games_played) VALUES ('$USERNAME', 0)")
  echo Welcome, $USERNAME! It looks like this is your first time here.
  echo Guess the secret number between 1 and 1000:
# if exists
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$NAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$NAME'")
  echo Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  echo Guess the secret number between 1 and 1000:
fi

# generate random number
NUMBER=$((RANDOM%1000+1))

# number of guesses
GUESSES=1

NUMBER_GUESS(){

  # take user guess
  read GUESS_NUMBER

  if [[ ! $GUESS_NUMBER =~ ^[0-9]++++$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    NUMBER_GUESS
  
  else
    # check until guess equals number
    until [[ $GUESS_NUMBER == $NUMBER ]]
    do
      
      # increment by 1 for each guess
      ((GUESSES++))
      
      # if guess greater than number
      if [[ $GUESS_NUMBER -gt $NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
        NUMBER_GUESS
      # if guess less than number
      elif [[ $GUESS_NUMBER -lt $NUMBER ]]
      then
        echo -e "\nIt's higher than that, guess again:"
        NUMBER_GUESS
      fi

    done  

  fi

}
NUMBER_GUESS

echo -e "\nYou guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

# update games played
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED+1 WHERE username='$USERNAME'")

# check if best game empty
if [[ -z $BEST_GAME ]]
then
  ADD_BEST_GAME=$($PSQL "UPDATE users SET best_game=$GUESSES WHERE username='$USERNAME'")
else
  if [[ $GUESSES -lt $BEST_GAME ]]
  then 
    ADD_BEST_GAME=$($PSQL "UPDATE users SET best_game=$GUESSES WHERE username='$USERNAME'")
  fi
fi
