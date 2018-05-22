//---------------------------------------------------------------------------

#pragma hdrstop

#include "Cell.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)

namespace Maze{

Cell::Cell() :
	m_iRow(-1),
	m_iColumn(-1),
	m_iDistance(-1),
	m_mapLinks(),
	m_mapNeighbours()
{
	//
}

Cell::Cell(const int ARow, const int AColumn) :
	m_iRow(ARow),
	m_iColumn(AColumn),
	m_iDistance(-1),
	m_mapLinks(),
	m_mapNeighbours()
{
	//
}

const int Cell::Row() const {
	return m_iRow;
}

const int Cell::Column() const {
	return m_iColumn;
}

void Cell::Link(std::shared_ptr<Cell>& self, std::shared_ptr<Cell>& cell, bool Bidi) {
	std::weak_ptr<Cell> c = cell;
	self->m_mapLinks[c] = true;
	if (Bidi) {
		Cell::Link(cell, self, false);
	}
}

void Cell::UnLink(std::shared_ptr<Cell>& self, std::shared_ptr<Cell>& cell, bool Bidi) {
	std::weak_ptr<Cell> c = cell;
	self->m_mapLinks[c] = false;
	if (Bidi) {
		Cell::UnLink(cell, self, false);
	}
}

std::list<std::shared_ptr<Cell>> Cell::Links() const {
	std::list<std::shared_ptr<Cell>> list;

	for(auto& kv : m_mapLinks) {
		list.push_back(kv.first.lock());
    }

	return list;
}

bool Cell::IsLinked(const std::shared_ptr<Cell>& cell) const {
	return m_mapLinks.find(cell) != m_mapLinks.end();
}

void Cell::SetNeighbour(Direction dir, std::shared_ptr<Cell> cell) {
	if (cell) {
		m_mapNeighbours[dir] = cell;
	} else {
		auto it = m_mapNeighbours.find(dir);
		if (it != m_mapNeighbours.end()) {
			m_mapNeighbours.erase(it);
		}
    }
}

const std::shared_ptr<Cell> Cell::GetNeighbour(Direction dir) {
	return m_mapNeighbours[dir].lock();
}

std::vector<std::shared_ptr<Cell>> Cell::Neighbours() const {
	std::vector<std::shared_ptr<Cell>> list;

	for(auto& kv : m_mapNeighbours) {
		if (!kv.second.expired()) {
			list.push_back(kv.second.lock());
		}
	}

	return list;
}

} // namespace Maze
