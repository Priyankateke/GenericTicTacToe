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
	count=0
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
	else
		player="O"
	fi
	echo "player sign $player"
}

#Switching sign assign to players
function switchPlayerSign()
{
	#Checking condition using Ternary operators
	[ $player == "X" ] && player="O" || player="X"
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

#checking position is already filled or blank
function isCellEmpty() 
{
	local row=$1 column=$2
	if [[ "${gameBoard[$row,$column]}" != "X" && "${gameBoard[$row,$column]}" != "O" ]]
	then
		gameBoard[$row,$column]=$player
		((playerMoves++))
	else
		echo "Position is Occupied"
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
		checkWinningCells
		switchPlayerSign
	done
	echo "Game Tie"
}

#Checking column, rows and diagonals
function checkWinningCells()
{
	declare -A cellsOfLeftDiagonal
	countForDiagonal=0
	for(( row=0;row<BOARD_SIZE;row++ ))
	do
		countForRowCol=0
		declare -A cellsOfRow
		declare -A cellsOfColumn
		for(( col=0;col<BOARD_SIZE;col++ ))
		do
			cellsOfRow[$countForRowCol]=$row,$col
			cellsOfColumn[$countForRowCol]=$col,$row
			if [[ $row == $col ]]; then 
				cellsOfLeftDiagonal[((countForDiagonal++))]=$row,$col
			fi

			((countForRowCol++))
		done
		checkWinner ${cellsOfRow[@]}
		checkWinner ${cellsOfColumn[@]}
	done
	checkWinner ${cellsOfLeftDiagonal[@]}

	#for right diagonals
	countForDiagonal=0
	for(( row=0,col=$((BOARD_SIZE-1));row<BOARD_SIZE;row++,col--))
	do
		cellsOfRightDiagonal[((countForDiagonal++))]=$row,$col
	done
	checkWinner ${cellsOfRightDiagonal[@]}
}

#Checking winner
function checkWinner()
{
	local cells=("$@")
	local cellCount=0

	for i in ${cells[@]}
	do
		if [ ${gameBoard[$i]} == $player ]; then
			((cellCount++))
		fi
	done
	
	if [ $cellCount == $BOARD_SIZE ]; then
		echo "Player Win and Have Sign $player"
		exit
	fi
}

resetBoard
tossForPlay
playTillGameEnd
