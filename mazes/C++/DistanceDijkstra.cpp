//---------------------------------------------------------------------------

#pragma hdrstop

#include "DistanceDijkstra.h"
#include "Grid.h"
#include <map>
//---------------------------------------------------------------------------
#pragma package(smart_init)

namespace Maze {

std::map<std::shared_ptr<Cell>, int> GetDistances(Grid& grid) {
	std::map<std::shared_ptr<Cell>, int> distances;
	for (auto cell : grid.EachCell()) {
		distances[cell] = -1;
	}

	std::vector<std::shared_ptr<Cell>> frontier;

	// Start cell is always bottom left - arbitrary
	auto start = grid.GetCell(grid.Rows()-1, 0);
	frontier.push_back(start);
	distances[start] = 0;

	while (!frontier.empty()) {
		std::vector<std::shared_ptr<Cell>> newFrontier;

		for (auto cell : frontier) {
			for (auto link : cell->Links()) {
				if (distances[link] == -1) {
					distances[link] = distances[cell] + 1;
					newFrontier.push_back(link);
                }
			}
		}

		frontier.clear();
		frontier = newFrontier;
	}

	return distances;
}

void Dijkstra::CalcDistance(Grid& grid) {
	std::map<std::shared_ptr<Cell>, int> distances(GetDistances(grid));

	for (auto kv : distances) {
		kv.first->Distance = kv.second;
	}
}

std::shared_ptr<Cell> MinLinkedNeighbour(std::shared_ptr<Cell> cell,
	std::map<std::shared_ptr<Cell>, int> distances)
{
	std::shared_ptr<Cell> res(nullptr);

	int maxDist = distances[cell];
	for (auto n : cell->Links()) {
		if (distances[n] < maxDist) {
			maxDist = distances[n];
			res = n;
		}
	}

	return res;
}

void Dijkstra::CalcSolve(Grid& grid) {
	for (auto cell : grid.EachCell()) {
		cell->Distance = -1;
	}

	auto distances = GetDistances(grid);

	// Always solve to the bottom right - arbitrary
	std::shared_ptr<Cell> current(grid.GetCell(grid.Rows()-1, grid.Columns()-1));

	// If not found, or it's the starting cell, quit
	if ((!current) || (distances[current] <= 0)) {
		return;
    }

	while (current) {
		const int dist = distances[current];
		current->Distance = dist;
		current = MinLinkedNeighbour(current, distances);
	}
}

} // namespace Maze

