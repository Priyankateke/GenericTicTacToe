#!/bin/bash -x

echo "Welcome To Generic Tic Tac Toe"

#variables
playerMoves=1
playerTurn=0

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
		computer="X"
		player="O"
	else
		player="X"
		computer="O"
	fi

	[ $player == X ] && echo "Player play first with X sign" || echo "Computer play first with X sign"
	[ $player == X ] && playerTurn || computerTurn
}

#Switching sign assign to players
function switchPlayer()
{
	#Checking condition using Ternary operators
	[ $playerTurn == 1 ] && computerTurn || playerTurn
}

#Function for user play
function playerTurn()
{
	#FUNCNAME is an array containing all the names of the functions in the call stack
	playerTurn=1
	[ ${FUNCNAME[1]} == switchPlayer ] && echo "Player Turn Sign : $player"
	read -p "Enter row number(row number start from 0) : " row
	read -p "Enter column number(column number start from 0) : " column
	if [[ $row -ge 0 && $row -lt $BOARD_SIZE && $column -ge 0 && $column -lt $BOARD_SIZE ]]; then
		isCellEmpty $row $column $player
	else
		echo "Please Enter Value"
		playerTurn
	fi
}

#Function for computer play
function computerTurn()
{
	[ ${FUNCNAME[1]} == switchPlayer ] && echo " Computer Turn Sign $computer"
	playerTurn=0
	row=$((RANDOM % $BOARD_SIZE))
	col=$((RANDOM % $BOARD_SIZE))
	isCellEmpty $row $col $computer
}

#checking position is already filled or blank
function isCellEmpty() 
{
	local row=$1 column=$2 sign=$3
	if [[ "${gameBoard[$row,$column]}" != "X" && "${gameBoard[$row,$column]}" != "O" ]]
	then
		gameBoard[$row,$column]=$sign
		((playerMoves++))
	else
		[ ${FUNCNAME[1]} == "playerTurn" ] && echo "Position is Occupied"
		${FUNCNAME[1]}
	fi
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

	if [ $playerTurn == 1 ]; then
		sign=$player
	else
		sign=$computer
	fi

	for i in ${cells[@]}
	do
		if [ ${gameBoard[$i]} == $sign ]; then
			((cellCount++))
		fi
	done

	if [ $cellCount == $BOARD_SIZE ]; then 
		[ $sign == $player ] && winner=player || winner=computer
		echo "$winner Win and Have Sign $sign"
		exit
	fi
}

#Running game untill game ends
function playTillGameEnd()
{
	resetBoard
	tossForPlay
	while [ $playerMoves -le $TOTAL_MOVES ]
	do
		displayBoard
		checkWinningCells
		switchPlayer
	done
	displayBoard
	echo "Game Tie"
}

#starting game
playTillGameEnd
