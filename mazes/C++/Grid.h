//---------------------------------------------------------------------------

#ifndef GridH
#define GridH

#include <vector>
#include "Cell.h"
#include <memory>
#include <fmx.h>

namespace Maze {
	enum class CellPainting { None, Candidates, Distance, Colour, Solution };

	class Grid {
	private:
		int m_iRows;
		int m_iColumns;
		std::vector<std::vector<std::shared_ptr<Cell>>> m_oGrid;
		std::unique_ptr<TBitmap> m_pBitmap;

		virtual void PrepareGrid();
		virtual void ConfigureCells();
		TRect GetCellRect(const Cell& Cell, const int CellSize);
		void PaintCellFill(const int CellSize, CellPainting Painting);
		void PaintCellBorders(const int CellSize, CellPainting Painting);
	protected:
		virtual TSize BitmapSize(const int CellSize);
	public:
		Grid(const int NumRows, const int NumCols);

		Grid(const Grid&) = delete;
		Grid& operator=(const Grid&) = delete;

		int Rows() const;
		int Columns() const;

		const std::shared_ptr<Cell> GetCell(const int iRow, const int iColumn) const;

		int NumCells() const;
		const std::shared_ptr<Cell> RandomCell() const;

		const std::vector<std::vector<std::shared_ptr<Cell>>> EachRow() const;
		const std::vector<std::shared_ptr<Cell>> EachCell() const;

		TBitmap* Repaint(const int CellSizePx, const CellPainting painting);
    };
}


#endif
