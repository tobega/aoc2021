package main

import (
	"io/ioutil"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestAOC_parseInput(t *testing.T) {
	inputBytes, err := ioutil.ReadFile("input_test.txt")
	if err != nil {
		panic("couldn't read input")
	}

	actualParsedInput := parseInput(string(inputBytes))
	assert.Equal(t, 6, actualParsedInput[0][2])
}

func TestAOC_getSolutionPart1(t *testing.T) {
	inputBytes, err := ioutil.ReadFile("input_test.txt")
	if err != nil {
		panic("couldn't read input")
	}

	cave := parseInput(string(inputBytes))

	actualSolution := getSolutionPart1(cave)
	assert.Equal(t, 40, actualSolution)
}

func TestAOC_getSolutionPart2(t *testing.T) {
	inputBytes, err := ioutil.ReadFile("input_test.txt")
	if err != nil {
		panic("couldn't read input")
	}

	cave := parseInput(string(inputBytes))

	actualSolution := getSolutionPart2(cave)
	assert.Equal(t, 0, actualSolution)
}
