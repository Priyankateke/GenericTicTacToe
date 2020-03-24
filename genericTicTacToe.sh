#!/bin/bash -x

echo "Welcome To Generic Tic Tac Toe"

declare -a gameBoard

read -p "Enter Board Size : " BOARD_SIZE

#Restting game board
function resetBoard()
{
	for((row=0;row<BOARD_SIZE;row++))
	do
		for((column=0;column<BOARD_SIZE;column++))
		do
			gameBoard[$row,$column]='-'
		done
	done
}

#Assiging letter X or O to player and decide who play first
function tossForPlay()
{
	if [ $(( RANDOM % 2 )) -eq 0 ]; then
		player=X
		playerTurn=true
	else
		player=O
		playerTurn=true
	fi
}

resetBoard
tossForPlay
