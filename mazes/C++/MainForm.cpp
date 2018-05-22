//---------------------------------------------------------------------------

#include <fmx.h>
#pragma hdrstop

#include "MainForm.h"
#include "Grid.h"
#include <algorithm>
#include "Algorithms.h"
#include "DistanceDijkstra.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.fmx"
TForm2 *Form2;
//---------------------------------------------------------------------------
__fastcall TForm2::TForm2(TComponent* Owner) :
	TForm(Owner),
	m_pGrid(new Maze::Grid(2, 2))
{
	RecreateGrid();
}

void TForm2::RecreateGrid() {
	const int C = std::max(2, (int)floor(ImageViewer->Width / CellSize()) - 1);
	const int R = std::max(2, (int)floor(ImageViewer->Height / CellSize()) - 1);

	m_pGrid.reset(new Maze::Grid(R, C));
}

void TForm2::PaintGrid() {
	const Maze::CellPainting CellDistPainting = static_cast<Maze::CellPainting>(cmbDistance->ItemIndex);
	ImageViewer->Bitmap->Assign(m_pGrid->Repaint(CellSize(), CellDistPainting));
	Invalidate();
}

void TForm2::DoDijkstra() {
	switch (Maze::CellPainting(cmbDistance->ItemIndex)) {
		case Maze::CellPainting::None :
		case Maze::CellPainting::Candidates :
			break;
		case Maze::CellPainting::Distance :
		case Maze::CellPainting::Colour : {
			Maze::Dijkstra::CalcDistance(*m_pGrid);
			break;
		}
		case Maze::CellPainting::Solution : {
			Maze::Dijkstra::CalcSolve(*m_pGrid);
			break;
		}
	}

}

int TForm2::CellSize() {
	int res = 50;
	TryStrToInt(edtCellSize->Text, res);
	return res;
}

void __fastcall TForm2::edtCellSizeKeyUp(TObject *Sender, WORD &Key, System::WideChar &KeyChar,
	TShiftState Shift)
{
	if (Key == vkReturn) {
		RecreateGrid();
		PaintGrid();
	}
}

void __fastcall TForm2::btnNewClick(TObject *Sender)
{
	RecreateGrid();
	PaintGrid();
}

void __fastcall TForm2::btnPlayClick(TObject *Sender)
{
	auto MazeGenProc = GetMazeGenerationProc();
	MazeGenProc(*m_pGrid);
	DoDijkstra();
	PaintGrid();
}

std::function<void(Maze::Grid&)> TForm2::GetMazeGenerationProc() {
	switch (cmbAlgorithm->ItemIndex) {
		case 0 : return Maze::BinaryTree;
		case 1 : return Maze::AldousBroder;
		case 2 : return Maze::RecursiveBacktracker;
	}
    return nullptr;
}

void __fastcall TForm2::cmbDistanceChange(TObject *Sender)
{
	DoDijkstra();
	PaintGrid();
}

void __fastcall TForm2::FormShow(TObject *Sender)
{
    PaintGrid();
}
//---------------------------------------------------------------------------

