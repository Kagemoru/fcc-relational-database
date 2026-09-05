#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN() {
  # input username
  echo "Enter your username:"
  read -r USERNAME
  USERNAME=$(printf '%s' "$USERNAME" | sed "s/'/''/g")

  # check if username input is valid
  if [[ -z $USERNAME || ${#USERNAME} -gt 22 ]]
  then
    echo "Username must contian characters (22 maximum)."
    exit
  fi

  # get user id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

  # if not found
  if [[ -z $USER_ID ]]
  then
    # insert new username
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")

    # get new user id
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

    # display welcome message
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  else
    # get user info
    USER_INFO=$($PSQL "SELECT * FROM users WHERE user_id=$USER_ID")
  
    # welcome back message, display user info
    echo "$USER_INFO" | while IFS="|" read USER_ID USERNAME GAMES_PLAYED BEST_GAME
    do
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
  fi

  # begin number guessing game
  NUMBER_GUESS_GAME

  # update game history (games_played)
  GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE user_id=$USER_ID")

  # update game history (best game)
  BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = CASE WHEN best_game IS NULL OR $NUMBER_OF_GUESSES < best_game THEN $NUMBER_OF_GUESSES ELSE best_game END WHERE user_id=$USER_ID")
}

NUMBER_GUESS_GAME() {
  SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
  NUMBER_OF_GUESSES=0

  echo -e "\nGuess the secret number between 1 and 1000:"
  read -r GUESS_NUMBER

  while true
  do
    # Check if input is an integer
    if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      read -r GUESS_NUMBER
      continue
    fi

    # Count the valid guess
    (( NUMBER_OF_GUESSES++ ))

    if (( GUESS_NUMBER == SECRET_NUMBER ))
    then
      break
    elif (( GUESS_NUMBER > SECRET_NUMBER ))
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi

    read -r GUESS_NUMBER
  done

  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
}

MAIN