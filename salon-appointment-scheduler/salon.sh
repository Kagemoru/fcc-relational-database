#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SALON_MENU() {
  # display message
  echo "Welcome to My Salon, how can i help you?"

  # loops until service id is valid
  while [[ -z $SERVICE_NAME ]]
  do
    # display services
    DISPLAY_SERVICES

    # customer input (ask for a service)
    read SERVICE_ID_SELECTED

    # input must be a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # if not back to menu
      echo -e "\nI could not find that service. What would you like today?"
      continue
    else
      # get service name
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

      # if not found
      if [[ -z $SERVICE_NAME ]]
      then
        # back to menu
        echo -e "\nI could not find that service. What would you like today?"
        continue
      fi
    fi
  done

  # get customer phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_PHONE_ESC=$(ESCAPE_QUOTES "$CUSTOMER_PHONE")

  # get customer name by phone number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE_ESC'")

  # if customer name not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    CUSTOMER_NAME_ESC=$(ESCAPE_QUOTES "$CUSTOMER_NAME")

    # insert new customer (phone & name)
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE_ESC', '$CUSTOMER_NAME_ESC')")
  fi

  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE_ESC'")

  # get appointment time
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME), $(echo $CUSTOMER_NAME)?"
  read SERVICE_TIME

  # insert customer appointment to appointments table
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME) at $SERVICE_TIME, $(echo $CUSTOMER_NAME)."
}

DISPLAY_SERVICES() {
  # get available service
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # display available service
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

ESCAPE_QUOTES() {
  printf "%s" "$1" | sed "s/'/''/g"
}

SALON_MENU