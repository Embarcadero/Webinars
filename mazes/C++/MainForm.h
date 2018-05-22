//---------------------------------------------------------------------------

#ifndef MainFormH
#define MainFormH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <FMX.Controls.hpp>
#include <FMX.Forms.hpp>
#include <FMX.Controls.Presentation.hpp>
#include <FMX.Edit.hpp>
#include <FMX.ExtCtrls.hpp>
#include <FMX.Layouts.hpp>
#include <FMX.ListBox.hpp>
#include <FMX.StdCtrls.hpp>
#include <FMX.Types.hpp>
#include "Grid.h"
#include <memory>
#include <functional>
//---------------------------------------------------------------------------
class TForm2 : public TForm
{
__published:	// IDE-managed Components
	TToolBar *ToolBar;
	TSpeedButton *btnNew;
	TComboBox *cmbDistance;
	TSpeedButton *btnPlayStepped;
	TSpeedButton *btnPlay;
	TEdit *edtCellSize;
	TSpeedButton *btnStop;
	TComboBox *cmbAlgorithm;
	TLabel *Label1;
	TLabel *Label2;
	TLabel *Label3;
	TImageViewer *ImageViewer;
	void __fastcall edtCellSizeKeyUp(TObject *Sender, WORD &Key, System::WideChar &KeyChar,
          TShiftState Shift);
	void __fastcall btnNewClick(TObject *Sender);
	void __fastcall btnPlayClick(TObject *Sender);
	void __fastcall cmbDistanceChange(TObject *Sender);
	void __fastcall FormShow(TObject *Sender);
private:	// User declarations
	std::unique_ptr<Maze::Grid> m_pGrid;
	void RecreateGrid();
	void PaintGrid();
	int CellSize();
	std::function<void(Maze::Grid&)> GetMazeGenerationProc();
    void DoDijkstra();
public:		// User declarations
	__fastcall TForm2(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm2 *Form2;
//---------------------------------------------------------------------------
#endif
