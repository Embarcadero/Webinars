//---------------------------------------------------------------------------

#ifndef CellH
#define CellH

#include <vector>
#include <list>
#include <map>
#include <memory>

namespace Maze {
	enum class Direction { North, South, East, West };

	class Cell {
	private:
		int m_iRow;
		int m_iColumn;
		std::map<std::weak_ptr<Cell>, bool, std::owner_less<std::weak_ptr<Cell>>> m_mapLinks;
		std::map<Direction, std::weak_ptr<Cell>> m_mapNeighbours;
		int m_iDistance;

		const std::shared_ptr<Cell> GetNeighbour(Direction dir);
		void SetNeighbour(Direction dir, std::shared_ptr<Cell> cell);
	public:
		Cell();
		Cell(const int ARow, const int AColumn);

		const int Row() const;
		const int Column() const;

		// Self here avoids using shared_from_this
		static void Link(std::shared_ptr<Cell>& self, std::shared_ptr<Cell>& cell, bool Bidi = true);
		static void UnLink(std::shared_ptr<Cell>& self, std::shared_ptr<Cell>& cell, bool Bidi = true);

		std::list<std::shared_ptr<Cell>> Links() const;
		bool IsLinked(const std::shared_ptr<Cell>& cell) const;

		std::vector<std::shared_ptr<Cell>> Neighbours() const;
        
		__property std::shared_ptr<Cell> Neighbour[Direction dir] = { read=GetNeighbour, write=SetNeighbour };
		__property int Distance = { read = m_iDistance, write = m_iDistance };
	};
}

#endif
