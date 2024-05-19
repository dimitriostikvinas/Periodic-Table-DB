#!/bin/bash
# Query Element Data and Display them script, YEAH
# TESTED
# Define the PSQL command with the appropriate options
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Function to display the main menu and handle input
MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1\n"
  fi

  if [[ -z $INPUT ]]; then
    echo "Please provide an element as an argument."
  else
    CHECK_VALID_INPUT "$INPUT"
  fi
}

# Function to check if the input is a valid element identifier
CHECK_VALID_INPUT() {
  if [[ $1 =~ ^[0-9]+$ ]]; then
    GET_ELEMENT_INFO "atomic_number" "$1"
  elif [[ $1 =~ ^[A-Z][a-z]?$ ]]; then
    GET_ELEMENT_INFO "symbol" "$1"
  elif [[ $1 =~ ^[A-Za-z]+$ ]]; then
    GET_ELEMENT_INFO "name" "$1"
  else
    MAIN_MENU "Invalid input. Please provide a valid atomic number, element symbol (e.g., H, He), or element name."
  fi
}

# Function to get the element information from the database
GET_ELEMENT_INFO() {
  COLUMN=$1
  VALUE=$2
  ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius   
                        FROM elements AS e 
                        INNER JOIN properties AS p USING(atomic_number) 
                        INNER JOIN types AS t USING(type_id) 
                        WHERE e.$COLUMN='$VALUE'")
  
  if [[ -z $ELEMENT_INFO ]]; then
    echo "I could not find that element in the database."
  else
    echo $ELEMENT_INFO | while IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL MASS MELTING_POINT BOILING_POINT; do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a nonmetal, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
}

# Main program execution starts here
INPUT=$1
MAIN_MENU
