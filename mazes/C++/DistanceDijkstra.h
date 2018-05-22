//---------------------------------------------------------------------------

#ifndef DistanceDijkstraH
#define DistanceDijkstraH

namespace Maze {

class Grid;

class Dijkstra {
public:
	static void CalcDistance(Grid& grid);
	static void CalcSolve(Grid& grid);
};

}

#endif
