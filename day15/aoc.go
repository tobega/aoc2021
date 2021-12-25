package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"os"
	"strings"
)

func getSolutionPart1(cave [][]int) int {
	height := len(cave)
	width := len(cave[0])
	costs := make([][]int, height)
	for i := range costs {
		costs[i] = make([]int, width)
		for j := range costs[i] {
			costs[i][j] = math.MaxInt32
		}
	}
	i := 0
	j := 0
	costs[0][0] = 0
	for j < width {
		if i == height {
			j++
			i = 0
			continue
		}
		if i > 0 && costs[i-1][j]+cave[i][j] < costs[i][j] {
			costs[i][j] = costs[i-1][j] + cave[i][j]
		}
		if j > 0 && costs[i][j-1]+cave[i][j] < costs[i][j] {
			costs[i][j] = costs[i][j-1] + cave[i][j]
		}
		if i > 0 && costs[i][j]+cave[i-1][j] < costs[i-1][j] {
			costs[i-1][j] = costs[i][j] + cave[i-1][j]
			i--
			continue
		}
		if j > 0 && costs[i][j]+cave[i][j-1] < costs[i][j-1] {
			costs[i][j-1] = costs[i][j] + cave[i][j-1]
			j--
			continue
		}
		i++
	}
	return costs[height-1][width-1]
}

func getSolutionPart2(cave [][]int) int {
	height := len(cave)
	width := len(cave[0])
	bigcave := make([][]int, height*5)
	for i := range bigcave {
		cavei := i % height
		addi := i / height
		bigcave[i] = make([]int, width*5)
		for j := range bigcave[i] {
			cavej := j % width
			addj := j / width
			bigcave[i][j] = (cave[cavei][cavej]+addi+addj-1)%9 + 1
		}
	}
	return getSolutionPart1(bigcave)
}

func parseInput(input string) [][]int {
	var cave [][]int

	lines := strings.Split(strings.TrimSpace(input), "\n")

	for _, line := range lines {
		var row []int
		for _, risk := range []rune(line) {
			row = append(row, int(risk-'0'))
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
