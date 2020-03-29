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
	playerTurn=1
	#FUNCNAME is an array containing all the names of the functions in the call stack
	[ ${FUNCNAME[1]} == switchPlayer ] && echo "Player Turn Sign : $player"
	read -p "Enter row number(row number start from 0) : " row
	read -p "Enter column number(column number start from 0) : " column
	if [[ $row -ge 0 && $row -lt $BOARD_SIZE && $column -ge 0 && $column -lt $BOARD_SIZE ]]; then
		isCellEmpty $row $column $player
		checkWinningCells
	else
		echo "Please Enter Value"
		playerTurn
	fi
}

#Function for computer play
function computerTurn()
{
	playerTurn=0
	[ ${FUNCNAME[1]} == switchPlayer ] && echo " Computer Turn Sign $computer"

	flag=0
	checkWinningCells $computer
	[ $flag == 0 ] && checkWinningCells $player
	[ $flag == 0 ] && takeCornerPosition
	[ $flag == 0 ] && takeCentersPosition
	[ $flag == 0 ] && takeSidesPosition
	displayBoard
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
	[ ${FUNCNAME[1]} == "playerTurn" ] && call=checkWinner || call=checkForComputer; sign=$1;

	declare -A cellsOfLeftDiagonal
	countForDiagonal=0
	flag=0

	for(( row=0;row<BOARD_SIZE;row++ ))
	do
		declare -A cellsOfRow
		declare -A cellsOfColumn
		countForRowCol=0

		for(( col=0;col<BOARD_SIZE;col++ ))
		do
			cellsOfRow[$countForRowCol]=$row,$col
			cellsOfColumn[$countForRowCol]=$col,$row
			if [[ $row == $col ]]; then
				cellsOfLeftDiagonal[$countForDiagonal]=$row,$col
				((countForDiagonal++))
			fi
			((countForRowCol++))
		done
		[ $flag == 0 ] && $call ${cellsOfRow[@]}
		[ $flag == 0 ] && $call ${cellsOfColumn[@]}
	done
	[ $flag == 0 ] && $call ${cellsOfLeftDiagonal[@]}

	#for right diagonals
	declare -A cellsOfRightDiagonal
	countForDiagonal=0
	for(( row=0,col=$((BOARD_SIZE-1));row<BOARD_SIZE;row++,col--))
	do
		cellsOfRightDiagonal[$countForDiagonal]=$row,$col
		((countForDiagonal++))
	done
	[ $flag == 0 ] && $call ${cellsOfRightDiagonal[@]} 
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
		displayBoard
		exit
	fi
}

#Computer trying to win
function checkForComputer()
{
	local cells=("$@")
	local cellCount=0

	for i in ${cells[@]}
	do
		if [ ${gameBoard[$i]} == $sign ]; then
			((cellCount++))
		fi
	done

	if [ $cellCount == $((BOARD_SIZE-1)) ]; then
		for i in ${cells[@]}
		do
			if [ ${gameBoard[$i]} == "-" ]; then
				gameBoard[$i]=$computer
				checkWinner ${cells[@]}
				((playerMoves++))
				flag=1
				break
			fi
		done
	fi
}

#Set mark on corners if position is vacant
function takeCornerPosition()
{
	for(( row=0;row<$BOARD_SIZE;row+=$((BOARD_SIZE-1)) ))
	do
		for(( col=0;col<$BOARD_SIZE;col+=$((BOARD_SIZE-1)) ))
		do
			if [ ${gameBoard[$row,$col]} == "-" ]; then
				gameBoard[$row,$col]=$computer
				((playerMoves++))
				flag=1
				return
			fi
		done
	done
}

#Set mark on centers if position is vacant
function takeCentersPosition()
{
	for((row=1;row<$((BOARD_SIZE-1));row++))
	do
		for((col=1;col<$((BOARD_SIZE-1));col++))
		do
			if [ ${gameBoard[$row,$col]} == "-" ]; then
				gameBoard[$row,$col]=$computer
				((playerMoves++))
				flag=1
				return
			fi
		done
	done
}

#Set mark on sides if position is vacant
function takeSidesPosition()
{
	row=0
	for(( col=1;col<$((BOARD_SIZE-1));col++ ))
	do
		if [ ${gameBoard[$row,$col]} == "-" ]; then
			gameBoard[$row,$col]=$computer
			((playerMoves++))
			flag=1
			return
		fi
	done

	col=0
	for(( row=1;row<$((BOARD_SIZE-1));row++ ))
	do
		if [ ${gameBoard[$row,$col]} == "-" ]; then
			gameBoard[$row,$col]=$computer
			((playerMoves++))
			flag=1
			return
		fi
	done

	row=$((BOARD_SIZE-1))
	for(( col=1;col<$((BOARD_SIZE-1));col++ ))
	do
		if [ ${gameBoard[$row,$col]} == "-" ]; then
			gameBoard[$row,$col]=$computer
			((playerMoves++))
			flag=1
			return
		fi
	done

	col=$((BOARD_SIZE-1))
	for(( row=1;row<$((BOARD_SIZE-1));row++ ))
	do
		if [ ${gameBoard[$row,$col]} == "-" ]; then
			gameBoard[$row,$col]=$computer
			((playerMoves++))
			flag=1
			return
		fi
	done
}

#Running game untill game ends
function playTillGameEnd()
{
	resetBoard
	tossForPlay
	while [ $playerMoves -le $TOTAL_MOVES ]
	do
		switchPlayer
	done
	displayBoard
	echo "Game Tie"
}

#starting game
playTillGameEnd
