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
        g++ -g3 -fsanitize=address,undefined -lm $solution_file -o ./tmp/$filename.out
        (./tmp/$filename.out < $input_file) > ./tmp/$filename.output

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
    filename=$1

    point_idx=$(expr index $filename .)
    input_file="./tests/$(expr substr $filename 1 $(($point_idx - 1))).in"
    expected_output_file="./tests/$(expr substr $filename 1 $(($point_idx - 1))).exout"
    solution_file="./solutions/$filename"

    touch $input_file $expected_output_file $solution_file
    echo -e "Created files:\n$input_file\n$expected_output_file\n$solution_file"
}

import()
{
    python beecrowd_importer.py $1 $2
}

clean()
{
    git clean -fdX
}

if [[ ! "$#" -le 1 && "$#" -gt 3 ]]; then
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
elif [ $1 == "import" ]; then
    if [ ! "$#" -eq 3 ]; then
        echo "Invalid number of arguments."
        echo "Use: './run.sh import <problem_id> <language extension>'"
        echo "Use: './run.sh help' to get better explanations"
        exit 1
    fi

    import $2 $3
elif [ $1 == "clean" ]; then
    clean
else
    echo "Unknown command: $1"
    echo "Use: './run.sh help' to get better explanations"
    exit 1
fi
