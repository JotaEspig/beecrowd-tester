#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

print_diff()
{
    echo ""
    echo -e "${GREEN}Expected: ${RESET}"
    cat $2
    echo -e "\n${YELLOW}Got: ${RESET}"
    cat ./tmp/$1.output

    echo ""
    diff=$(diff --color ./tmp/$1.output $2)
    if [ "$diff" == "" ]; then
        echo -e "${GREEN}Accepted${RESET}"
    else
        echo -e "${RED}Difference:${RESET}"
        diff --color ./tmp/$1.output $2
    fi
}

test()
{
    filename=$1
    # get files path
    point_idx=$(expr index $filename .)
    input_file="./tests/$(expr substr $filename 1 $(($point_idx - 1))).in"
    expected_output_file="./tests/$(expr substr $filename 1 $(($point_idx - 1))).exout"
    solution_file="./solutions/$filename"

    # check if all files are where they should be
    exit=false
    if [ ! -f $solution_file ]; then
        echo "file $solution_file not found"
        exit=true
    fi
    if [ ! -f $input_file ]; then
        echo "file $input_file not found"
        exit=true
    fi
    if [ ! -f $expected_output_file ]; then
        echo "file $expected_output_file not found"
        exit=true
    fi
    if [ "$exit" == rue ]; then
        exit 1
    fi

    mkdir tmp 2>/dev/null    

    # languages
    if [[ "${filename:point_idx}" == cpp || "${filename:point_idx}" == c ]]; then
        g++ -O2 -lm $solution_file -o ./tmp/$filename.out
        cat $input_file | ./tmp/$filename.out > ./tmp/$filename.output

        print_diff $filename $expected_output_file
    fi
    if [[ "${filename:point_idx}" == exs ]]; then
        cat $input_file | elixir $solution_file > ./tmp/$filename.output

        print_diff $filename $expected_output_file
    fi
    if [[ "${filename:point_idx}" == py ]]; then
        cat $input_file | python3 $solution_file > ./tmp/$filename.output

        print_diff $filename $expected_output_file
    fi
    if [[ "${filename:point_idx}" == hs ]]; then
        ghc $solution_file -odir ./tmp/ -o ./tmp/$filename.out
        cat $input_file | ./tmp/$filename.out > ./tmp/$filename.output

        print_diff $filename $expected_output_file
    fi
}

add()
{
    basecpp="#include <bits/stdc++.h>
using namespace std;

int main(int argc, char argv[]) 
{

}
"

    filename=$1

    point_idx=$(expr index $filename .)
    extension="${filename##*.}"
    input_file="./tests/$(expr substr $filename 1 $(($point_idx - 1))).in"
    expected_output_file="./tests/$(expr substr $filename 1 $(($point_idx - 1))).exout"
    solution_file="./solutions/$filename"

    touch $input_file $expected_output_file $solution_file

    if [ $extension == "cpp" ]; then
        echo "$basecpp" > "$solution_file"
    fi 

    echo -e "Created files:\n$input_file\n$expected_output_file\n$solution_file"
}


if [[ ! "$#" -eq 1 && ! "$#" -eq 2 ]]; then
    echo "Invalid number of arguments."
    echo "Use: './run.sh help' to get better explanations"
    exit 1
fi

if [ $1 == "help" ]; then
    echo "Usage: './run.sh <command> [argument for command]'"
    exit 0
fi

if [ $1 == "test" ]; then
    if [ ! "$#" -eq 2 ]; then
        echo "Invalid number of arguments."
        echo "Use: './run.sh test <filename>'"
        echo "Use: './run.sh help' to get better explanations"
        exit 1
    fi
    
    test $2
elif [ $1 == "add" ]; then
    if [ ! "$#" -eq 2 ]; then
        echo "Invalid number of arguments."
        echo "Use: './run.sh add <filename>'"
        echo "Use: './run.sh help' to get better explanations"
        exit 1
    fi

    add $2
fi
