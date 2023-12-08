#! /bin/bash

read num1
read num2

function product(){
	product=$(( $1 * $2 ))
	echo $product
}

product num1 num2
