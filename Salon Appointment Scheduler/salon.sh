#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "$1"
  fi

  echo "$SERVICE_OPTIONS" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #prompt user for a number
    MAIN_MENU "\nPlease enter a number.\n"
  else
    # if service option DNE
    SERVICE_NAME="$($PSQL"select name from services where service_id=$SERVICE_ID_SELECTED")"
    if [[ -z $SERVICE_NAME ]]
    then
      # prompt user for a viable number
      MAIN_MENU "\nPlease enter a number for a service option.\n"
    else
      # get user phone number
      echo -e "\nPlease enter your phone number.\n"
      read CUSTOMER_PHONE
      # lookup phone number
      CUSTOMER_ID="$($PSQL"select customer_id from customers where phone='$CUSTOMER_PHONE'")"
      # if not in system
      if [[ -z $CUSTOMER_ID ]]
      then
        # get user name
        echo -e "\nPlease enter your name.\n"
        read CUSTOMER_NAME
        # insert customer
        CUSTOMER_INSERT_RESULT="$($PSQL"insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")"
        # get new customer_id
        CUSTOMER_ID="$($PSQL"select customer_id from customers where phone='$CUSTOMER_PHONE'")"
      else
        CUSTOMER_NAME="$($PSQL"select name from customers where customer_id=$CUSTOMER_ID")"
      fi
      echo -e "\nPlease enter an appointment time.\n"
      read SERVICE_TIME
      CREATE_SERVICE_RESULT="$($PSQL"insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")"
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    fi
  fi
}

SERVICE_OPTIONS="$($PSQL"select service_id, name from services")"
if [[ -z $SERVICE_OPTIONS ]]
then
  echo "No services are currently available."
else
  MAIN_MENU "\nWelcome to the salon's scheduling app!\nPlease choose the type of appointment you'd like to schedule.\n"
fi