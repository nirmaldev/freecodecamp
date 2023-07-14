#! /bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

USERNAME="freecodecamp"
DBNAME="salon"
if [[ $1 == 'postgres' ]]
then
  PSQL="psql --username=$USERNAME --dbname=postgres -tAc "
else
  PSQL="psql --username=$USERNAME --dbname=$DBNAME -tAc"
fi


while true
do
  echo -e "\n Display Services: \n"
  SERVICES=$($PSQL "SELECT name FROM services")
  echo "$SERVICES" | awk '{print NR")", $0}'
  # Input the service required
  echo -e "\nEnter service_id of service requested for : " 
  read SERVICE_ID_SELECTED
  # Check if the Service ID exists in the column
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_EXISTS=$($PSQL "SELECT EXISTS(SELECT 1 FROM services WHERE service_id = '$SERVICE_ID_SELECTED')")
    if [[ $SERVICE_EXISTS = 't' ]]
    then
      break
    fi
  fi
done


# Input phone of the customer
echo -e "\nEnter the phone number: " 
read CUSTOMER_PHONE

# Check if the customer exists, which is the phone number of the customer
CUSTOMER_EXISTS=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
CUSTOMER_NAME=$(echo $CUSTOMER_EXISTS)

if [[ -z $CUSTOMER_NAME ]]
then
  # Enter new customer name
  echo -e "\nPlease enter the customer's name: " 
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
fi

# Check if the customer exists, which is the phone number of the customer
# CUSTOMER_EXISTS=$($PSQL "SELECT EXISTS (SELECT 1 FROM customers WHERE phone='$CUSTOMER_PHONE')")

# if [[ $CUSTOMER_EXISTS = 'f' ]]
# then
#   # Enter new customer name
#   echo -e "\nPlease enter the customer's name: " 
#   read CUSTOMER_NAME
#   $PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
# fi

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

# Input service time
echo -e "\nEnter the time for $CUSTOMER_NAME's $SERVICE_NAME: " 
read SERVICE_TIME

# Input appointment
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) SELECT customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME' FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Output message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
