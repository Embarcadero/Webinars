//---------------------------------------------------------------------------

#pragma hdrstop

#include "Grid.h"
#include <FMX.Types.hpp>
#include <System.UITypes.hpp>

//---------------------------------------------------------------------------
#pragma package(smart_init)

namespace Maze {

const TAlphaColor BackColor = TAlphaColorRec::White;
const TAlphaColor WallColor = TAlphaColorRec::Black;
const int HalfStrokeThickness = 1;

Grid::Grid(const int NumRows, const int NumCols) :
	m_iRows(NumRows),
	m_iColumns(NumCols),
	m_oGrid(),
	m_pBitmap(new TBitmap())
{
	PrepareGrid();
    ConfigureCells();
}

void Grid::PrepareGrid() {
	for (int r = 0; r < m_iRows; r++) {
		m_oGrid.push_back(std::vector<std::shared_ptr<Cell>>());
		for (int c = 0; c < m_iColumns; c++) {
			m_oGrid[r].push_back(std::shared_ptr<Cell>(new Cell(r, c)));
		}
	}
}

void Grid::ConfigureCells() {
	for (int r = 0; r < m_iRows; r++) {
		for (int c = 0; c < m_iColumns; c++) {
			m_oGrid[r][c]->Neighbour[Direction::North] = GetCell(r-1, c);
			m_oGrid[r][c]->Neighbour[Direction::South] = GetCell(r+1, c);
			m_oGrid[r][c]->Neighbour[Direction::West] = GetCell(r, c-1);
			m_oGrid[r][c]->Neighbour[Direction::East] = GetCell(r, c+1);
		}
	}
}

TSize Grid::BitmapSize(const int CellSize) {
	return TSize(m_iColumns * CellSize + 2, m_iRows * CellSize + 2);
}

int Grid::Rows() const {
	return m_iRows;
}

int Grid::Columns() const {
	return m_iColumns;
}

const std::shared_ptr<Cell> Grid::GetCell(const int iRow, const int iColumn) const {
  if ((iRow < 0) || (iRow >= m_iRows)) {
	return nullptr;
  }
  if ((iColumn < 0) || (iColumn >= m_iColumns)) {
	return nullptr;
  }

  return m_oGrid[iRow][iColumn];
}

int Grid::NumCells() const {
	return Rows() * Columns();
}

const std::shared_ptr<Cell> Grid::RandomCell() const {
	const int r = rand() % Rows();
	const int c = rand() % Columns();
	return GetCell(r, c);
}

const std::vector<std::vector<std::shared_ptr<Cell>>> Grid::EachRow() const {
	return m_oGrid;
}

const std::vector<std::shared_ptr<Cell>> Grid::EachCell() const {
	std::vector<std::shared_ptr<Cell>> list;

	for (auto r : m_oGrid) {
		std::copy(r.begin(), r.end(), std::back_inserter(list));
	}

	return list;
}

TBitmap* Grid::Repaint(const int CellSizePx, const CellPainting painting) {
	const TSize BMPSize = BitmapSize(CellSizePx);
	m_pBitmap->Width = BMPSize.cx;
	m_pBitmap->Height = BMPSize.cy;
	m_pBitmap->Clear(BackColor);

	PaintCellFill(CellSizePx, painting);
	PaintCellBorders(CellSizePx, painting);

	return m_pBitmap.get();
}

void Grid::PaintCellFill(const int CellSize, CellPainting Painting) {
	const float Alpha = 0.7;

	int MaxDist = -1;
	for (auto Cell : EachCell()) {
		if (Cell->Distance > MaxDist) {
			MaxDist = Cell->Distance;
		}
	}

	m_pBitmap->Canvas->Font->Size = CellSize * 0.5;

	m_pBitmap->Canvas->BeginScene();
	__try {
		for (auto Cell : EachCell()) {
			// Fill based on cell distance
			if ((Cell->Distance >= 0) ||
				(Painting == CellPainting::Candidates)) {
				const TRect CellRect = GetCellRect(*Cell, CellSize);

				switch (Painting) {
				case CellPainting::None:
					break;
				case CellPainting::Candidates:
					{ // Paint candidate cells, ones with dist -2, -3
						switch (Cell->Distance) {
						case -1:
							m_pBitmap->Canvas->Fill->Color = TAlphaColorRec::White;
							break;
						case -2:
							m_pBitmap->Canvas->Fill->Color = TAlphaColorRec::Cornflowerblue;
							break;
						case -3:
							m_pBitmap->Canvas->Fill->Color = TAlphaColorRec::Red;
						}
						m_pBitmap->Canvas->FillRect(CellRect, 0, 0,
							Fmx::Types::TCorners(), Alpha);
						break;
					}
				case CellPainting::Distance: {
						m_pBitmap->Canvas->Fill->Color = TAlphaColorRec::Red;
						m_pBitmap->Canvas->FillText(CellRect,
							IntToStr(Cell->Distance), false, 1.0,
							TFillTextFlags(), TTextAlign::Center,
							TTextAlign::Center);
						break;
					}
				case CellPainting::Colour: {
						if (Cell->Distance == 0) {
							m_pBitmap->Canvas->Fill->Color = TAlphaColorRec::Red;
						}
						else {
							m_pBitmap->Canvas->Fill->Color = TAlphaColorF::Create
								((float)Cell->Distance / (float)MaxDist, 0, 0).ToAlphaColor();
						}
						m_pBitmap->Canvas->FillRect(CellRect, 0, 0,
							Fmx::Types::TCorners(), Alpha);
						break;
					}
				case CellPainting::Solution: {
						if (Cell->Distance >= 0) {
							m_pBitmap->Canvas->Fill->Color = TAlphaColorRec::Red;
							m_pBitmap->Canvas->FillRect(CellRect, 0, 0,
								Fmx::Types::TCorners(), Alpha);
						}
						break;
					}
				}
			}
		}
	}
	__finally {
		m_pBitmap->Canvas->EndScene();
	}
}

void Grid::PaintCellBorders(const int CellSize, CellPainting Painting) {
	const int Stroke = HalfStrokeThickness * 2;

	m_pBitmap->Canvas->BeginScene();
	__try {
		m_pBitmap->Canvas->Stroke->Kind = TBrushKind::Solid;
		m_pBitmap->Canvas->Stroke->Thickness = Stroke;
		m_pBitmap->Canvas->Stroke->Color = WallColor;

		for (auto Cell : EachCell()) {
			TRect CellRect = GetCellRect(*Cell, CellSize);

			if (!Cell->Neighbour[Direction::North]) {
				m_pBitmap->Canvas->DrawLine(PointF(CellRect.Left, CellRect.Top), PointF(CellRect.Right, CellRect.Top), 1.0);
			}

			if (!Cell->Neighbour[Direction::West]) {
				m_pBitmap->Canvas->DrawLine(PointF(CellRect.Left, CellRect.Top), PointF(CellRect.Left, CellRect.Bottom), 1.0);
            }

			if (!Cell->IsLinked(Cell->Neighbour[Direction::East])) {
				m_pBitmap->Canvas->DrawLine(PointF(CellRect.Right, CellRect.Top), PointF(CellRect.Right, CellRect.Bottom), 1.0);
			}
			if (!Cell->IsLinked(Cell->Neighbour[Direction::South])) {
				m_pBitmap->Canvas->DrawLine(PointF(CellRect.Left, CellRect.Bottom), PointF(CellRect.Right, CellRect.Bottom), 1.0);
			}
		}
	}__finally {
		m_pBitmap->Canvas->EndScene();
	}
}

TRect Grid::GetCellRect(const Cell& Cell, const int CellSize) {
	const int X1 = Cell.Column() * CellSize + HalfStrokeThickness;
	const int Y1 = Cell.Row() * CellSize + HalfStrokeThickness;
	const int X2 = (Cell.Column() + 1) * CellSize + HalfStrokeThickness;
	const int Y2 = (Cell.Row() + 1) * CellSize + HalfStrokeThickness;
	return Rect(X1, Y1, X2, Y2);
}

}
