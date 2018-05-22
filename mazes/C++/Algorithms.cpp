//---------------------------------------------------------------------------

#pragma hdrstop

#include "Algorithms.h"
#include "Grid.h"
#include "Cell.h"
#include <stack>
//---------------------------------------------------------------------------
#pragma package(smart_init)

namespace Maze {

void BinaryTree(Grid& grid) {
	std::vector<std::shared_ptr<Cell>> neighbours;

	for (auto cell : grid.EachCell()) {
		neighbours.clear();

		if (cell->Neighbour[Direction::North]) {
			neighbours.push_back(cell->Neighbour[Direction::North]);
		}
		if (cell->Neighbour[Direction::East]) {
			neighbours.push_back(cell->Neighbour[Direction::East]);
		}

		if (!neighbours.empty()) {
			const int index = rand() % neighbours.size();
			std::shared_ptr<Cell> c = neighbours[index];
			Cell::Link(cell, c);
		}
	}
}

void AldousBroder(Grid& grid) {
	std::shared_ptr<Cell> cell { grid.RandomCell() };
	int NumUnvisited = grid.NumCells();

	while (NumUnvisited > 1) {
		std::vector<std::shared_ptr<Cell>> neighbours(cell->Neighbours());
		const int i = rand() % neighbours.size();
		std::shared_ptr<Cell> N(neighbours[i]);

		if (N->Links().empty()) {
			Cell::Link(cell, N);
			--NumUnvisited;
		}
		cell = N;
	}
}

std::vector<std::shared_ptr<Cell>> GetUnvisitedNeighbours(std::shared_ptr<Cell> cell) {
	std::vector<std::shared_ptr<Cell>> res;
	std::vector<std::shared_ptr<Cell>> neighbours(cell->Neighbours());
	// Neighbour cells that have no links at all (if any links, they've been visited)
	for (auto n : neighbours) {
		if (n->Links().empty()) {
			res.push_back(n);
        }
	}
	return res;
}

void RecursiveBacktracker(Grid& grid) {
	std::stack<std::shared_ptr<Cell>> stack;
	stack.push(grid.GetCell(grid.Rows()-1, 0)); // Bottom left; can be random

	while (!stack.empty()) {
		std::shared_ptr<Cell> current(stack.top());
		std::vector<std::shared_ptr<Cell>> neighbours(GetUnvisitedNeighbours(current));

		if (!neighbours.empty()) {
			auto n(neighbours[rand() % neighbours.size()]);
			Cell::Link(current, n);
			stack.push(n);
		} else {
			stack.pop();
		}
	}
}

} // namespace Maze
