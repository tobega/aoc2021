package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"os"
	"strings"
)

func getSolutionPart1(cave [][]int) int {
	costs := make([][]int, len(cave))
	for i,_ := range costs {
	  costs[i] = make([]int, len(cave[0]))
		for j,_ := range costs[i] {
			costs[i][j] = math.MaxInt32
		}
	}
	return 0
}

func getSolutionPart2(cave [][]int) int {
	return 0
}

func parseInput(input string) [][]int {
	var cave [][]int

	lines := strings.Split(strings.TrimSpace(input), "\n")

	for _, line := range lines {
		var row []int
		for _, risk := range []rune(line) {
		  row = append(row, int(risk - '0'))
		}
		cave = append(cave, row)
	}
	return cave
}

func main() {
	inputBytes, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic("couldn't read input")
	}

	cave := parseInput(string(inputBytes))

	part := os.Getenv("part")

	if part == "part2" {
		fmt.Println(getSolutionPart2(cave))
	} else {
		fmt.Println(getSolutionPart1(cave))
	}
}
