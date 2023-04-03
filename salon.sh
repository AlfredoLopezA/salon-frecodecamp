#! /bin/bash

#---------------------------------------#
#   Script create by Alfredo López A.   #
#         Date: 29 March, 2023.         #
#---------------------------------------#

SERVICE_ID_SELECTED=0
CUSTOMER_PHONE=""
CUSTOMER_NAME=""
SERVICE_TIME=""

BEGIN_SCRIPT() {
  # Database conection and script run.
  PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
  # echo $($PSQL "TRUNCATE customers, appointments RESTART IDENTITY")
  echo -e "~~~~~ MY SALON ~~~~~\n"
  echo -e "Welcome to my salon, how can I help you?\n"
}

SERVICE_MENU() {
  # List of services.
  CURRENT_SERVICE=$($PSQL "SELECT service_id, name FROM services")
  if [[ -z $CURRENT_SERVICE ]]
  then
    echo -e "\nSorry, Any service available for now."
  else
    echo "$CURRENT_SERVICE" | while read SERV_ID BAR NAME
    do
      echo "$SERV_ID) $NAME"
    done
  fi
}

SERVICE_SELECTED() {
  # Read selected service by the user.
  while true; do
    read SERVICE_ID_SELECTED
    SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    if [[ -z $SERVICE ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      SERVICE_MENU
    else
      break
    fi
  done
}

PHONE_CUSTOMER() {
  # Capture the phone number of customer.
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
}

NAME_CUSTOMER() {
  # Search name of customer with the phone number.
  # If customer is not registered save the data in customers table.
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    CUSTOMERS=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
}

SERVICE_APPOINTMENT_TIME() {
  # Capture of the appointment hour.
  #CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo "What time would you like your$SERVICE_NAME, $COSTUMER_NAME?"
  read SERVICE_TIME
}

SERVICE_APPOINTMENT() {
  # Save the appointment and show the data.
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $APPOINTMENTS == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME.\n"
  fi
}

# Call of the function for run script.
BEGIN_SCRIPT
SERVICE_MENU
SERVICE_SELECTED
PHONE_CUSTOMER
NAME_CUSTOMER
SERVICE_APPOINTMENT_TIME
SERVICE_APPOINTMENT