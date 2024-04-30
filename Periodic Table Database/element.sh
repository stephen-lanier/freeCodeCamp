PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    RES_EL="$($PSQL"select * from elements where atomic_number=$1")"
    RES_PROP="$($PSQL"select * from properties where atomic_number=$1")"
  elif [[ $1 =~ ^[A-Za-z]{1,2}$ ]]
  then
    RES_EL="$($PSQL"select * from elements where symbol='$1'")"
    ATOMIC_NUMBER="$($PSQL"select atomic_number from elements where symbol='$1'")"
    RES_PROP="$($PSQL"select * from properties where atomic_number=$ATOMIC_NUMBER")"
  else
    RES_EL="$($PSQL"select * from elements where name='$1'")"
    ATOMIC_NUMBER="$($PSQL"select atomic_number from elements where name='$1'")"
    RES_PROP="$($PSQL"select * from properties where atomic_number=$ATOMIC_NUMBER")"
  fi
  if [[ -z $RES_EL ]]
  then
    echo I could not find that element in the database.
  else
    IFS="|" read ATOMIC_NUMBER SYMBOL NAME <<< $RES_EL
    IFS="|" read ATOMIC_NUMBER ATOMIC_MASS MP BP TYPE_ID <<< $RES_PROP
    TYPE="$($PSQL"select type from types where type_id=$TYPE_ID")"
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."

  fi
fi