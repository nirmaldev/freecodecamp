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
  read -p "Choose service_id of service requested for : " SERVICE_ID_SELECTED
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
read -p "Enter the phone number: " CUSTOMER_PHONE

# Check if the customer exists, which is the phone number of the customer
CUSTOMER_EXISTS=$($PSQL "SELECT EXISTS (SELECT 1 FROM customers WHERE phone='$CUSTOMER_PHONE')")

if [[ $CUSTOMER_EXISTS = 'f' ]]
then
  # Enter new customer name
  read -p "Please enter the customer's name: " CUSTOMER_NAME
  $PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
fi

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

# Input service time
read -p "Enter the time for appointment: " SERVICE_TIME

# Input appointment
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) SELECT customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME' FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Output message
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
