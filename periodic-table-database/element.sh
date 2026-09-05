#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

MAIN() {
  # Exit if no argument is provided
  if [[ -z $1 ]]
  then
    echo "Please provide an element as an argument."
    exit
  fi

  # Base query for retrieving element details
  JOIN_TABLE="SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type FROM elements e JOIN properties p USING(atomic_number) JOIN types t USING(type_id)"

  # check if argument is a number or text
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # if number, search by atomic_number
    SEARCH_RESULT=$($PSQL "$JOIN_TABLE WHERE e.atomic_number = $1")
  else
    # if text, search by symbol or name
    SEARCH_RESULT=$($PSQL "$JOIN_TABLE WHERE e.symbol = '$1' OR e.name = '$1'")
  fi

  # Exit if element is not found
  if [[ -z $SEARCH_RESULT ]]
  then
    echo "I could not find that element in the database."
    exit
  fi

  # display element details
  echo "$SEARCH_RESULT" | while IFS="|" read ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MPC BPC TYPE
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MPC celsius and a boiling point of $BPC celsius."
  done
}

MAIN "$1"