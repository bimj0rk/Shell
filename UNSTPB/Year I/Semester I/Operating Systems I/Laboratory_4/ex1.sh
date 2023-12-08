#! /bin/bash

read num1
read num2

function sum(){
	sum=$(( $1 + $2 ))
	echo $sum
}

sum num1 num2
