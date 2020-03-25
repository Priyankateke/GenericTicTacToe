#!/bin/bash -x

echo "Welcome To Generic Tic Tac Toe"

#variables
playerMoves=1

# 2D array for game board
declare -A gameBoard

read -p "Enter Board Size : " BOARD_SIZE
TOTAL_MOVES=$((BOARD_SIZE * BOARD_SIZE))

#Restting game board
function resetBoard()
{
	for((row=0;row<BOARD_SIZE;row++))
	do
		for((column=0;column<BOARD_SIZE;column++))
		do
			gameBoard[$row,$column]="-"
		done
	done
	displayBoard
}

function displayBoard()
{
	for((row=0;row<$BOARD_SIZE;row++))
	do
		echo "  "
		for((column=0;column<$BOARD_SIZE;column++))
		do
			echo -n " " ${gameBoard[$row,$column]} "|" " " 
		done
		echo
	done
	echo " "
}


#Assiging letter X or O to player and decide who play first
function tossForPlay()
{
	if [ $(( RANDOM % 2 )) -eq 0 ]; then
		player="X"
		playerTurn=true
	else
		player="O"
		playerTurn=true
	fi
	echo "player sign $player"
}

#Function for user play
function userPlay()
{
	read -p "Enter row number(row number start from 0) : " row
	read -p "Enter column number(column number start from 0) : " column
	if [[ $row -ge 0 && $row -lt $BOARD_SIZE && $column -ge 0 && $column -lt $BOARD_SIZE ]]; then
		isCellEmpty $row $column
	else
		echo "Invalid Position"
		userPlay
	fi
}

#Running game untill game ends
function playTillGameEnd()
{
	while [ $playerMoves -le $TOTAL_MOVES ]
	do
		userPlay
		displayBoard
	done
}

#checking position is already filled or blank
function isCellEmpty() 
{
	local row=$1 column=$2
	if [[ "${gameBoard[$row,$column]}" != "$player" ]]
	then
		gameBoard[$row,$column]=$player
		((playerMoves++))
	else
		echo "Position is Occupied"
	fi
}

resetBoard
tossForPlay
playTillGameEnd
