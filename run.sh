#!/bin/bash
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
    if [ "${filename:point_idx}" == cpp ]; then
        g++ $solution_file -o ./tmp/$filename.out
        cat $input_file | ./tmp/$filename.out > ./tmp/$filename.output
        diff ./tmp/$filename.output $expected_output_file
    fi
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
fi