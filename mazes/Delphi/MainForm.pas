unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ListBox, Maze.Grid, Maze.Cell, FMX.Layouts,
  FMX.ExtCtrls, FMX.Edit, Maze.Algorithms;

type
  TForm1 = class(TForm)
    ToolBar: TToolBar;
    btnNew: TSpeedButton;
    cmbDistance: TComboBox;
    btnPlayStepped: TSpeedButton;
    btnPlay: TSpeedButton;
    ImageViewer: TImageViewer;
    edtCellSize: TEdit;
    btnStop: TSpeedButton;
    cmbAlgorithm: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure btnNewClick(Sender: TObject);
    procedure edtCellSizeKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btnPlaySteppedClick(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure cmbDistanceChange(Sender: TObject);
  private
    FGrid : IGrid;
    FStopPlaying : Boolean;
    procedure RecreateGrid;
    procedure PaintGrid;
    function CellSize: Integer;
    procedure DoDijkstra;
    function GetMazeGenerationProc: TMazeGenerationProc;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.Math, Maze.DistanceDijkstra;

{ TForm1 }

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited;
  FStopPlaying := false;

  RecreateGrid;
end;

destructor TForm1.Destroy;
begin

  inherited;
end;

procedure TForm1.edtCellSizeKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if Key = vkReturn then begin
    RecreateGrid;
    PaintGrid;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  PaintGrid;
end;

procedure TForm1.RecreateGrid;
var
  R, C : Integer;
begin
  C := Trunc(ImageViewer.Width / CellSize) - 1;
  R := Trunc(ImageViewer.Height / CellSize) - 1;

  // Limit the small size
  C := Max(C, 2);
  R := Max(R, 2);

  FGrid := CreateGrid(R, C);
end;

function TForm1.CellSize : Integer;
begin
  Result := 50;
  TryStrToInt(edtCellSize.Text, Result);
end;

procedure TForm1.PaintGrid;
var
  CellDistPainting : TCellPainting;
begin
  CellDistPainting := TCellPainting(cmbDistance.ItemIndex);
  ImageViewer.Bitmap.Assign(FGrid.Repaint(CellSize, CellDistPainting));
  Invalidate;
end;

procedure TForm1.btnNewClick(Sender: TObject);
begin
  RecreateGrid;
  PaintGrid;
end;

function TForm1.GetMazeGenerationProc : TMazeGenerationProc;
begin
  Result := nil;
  case cmbAlgorithm.ItemIndex of
    0 : Result := BinaryTree;
    1 : Result := AldousBroder;
    2 : Result := RecursiveBacktracker;
  end;
end;

procedure TForm1.btnPlayClick(Sender: TObject);
var
  MazeGenProc : TMazeGenerationProc;
begin
  MazeGenProc := GetMazeGenerationProc();
  MazeGenProc(FGrid);
  DoDijkstra;
  PaintGrid;
end;

function ShouldStopPlaying : Boolean;
begin
  Result := Form1.FStopPlaying;
  Form1.FStopPlaying := false; // Once checked once
end;

procedure TForm1.DoDijkstra;
begin
  case TCellPainting(cmbDistance.ItemIndex) of
    //cdNone : ClearCellDistances;
    cdDistance, cdColour : CalcDijkstraDistance(FGrid);
    cdSolution : CalcDijkstraSolve(FGrid);
  end;
end;

procedure TForm1.btnPlaySteppedClick(Sender: TObject);
var
  MazeGenProc : TMazeGenerationProc;
  PauseTimeMs : Integer;
begin
  btnStop.Enabled := true;
  btnPlayStepped.Enabled := false;
  btnPlay.Enabled := false;

  MazeGenProc := GetMazeGenerationProc();

  PauseTimeMs := 10000 div FGrid.NumCells;
//  PauseTimeMs := 50; // For slow ones, eg Aldous-Broder

  PauseTimeMs := Max(PauseTimeMs, 1);

  MazeGenProc(FGrid, procedure
    var
      Pause : Boolean;
    begin
      Pause := true;
      // If very short sleep, don't sleep every time
      if PauseTimeMs < 50 then
        Pause := Random(50 div PauseTimeMs) = 0;

      if Pause then begin
        PaintGrid;
        Application.ProcessMessages; // Ugh
        Sleep(PauseTimeMs);
      end;
    end,
    ShouldStopPlaying);

  DoDijkstra;
  PaintGrid;

  btnStop.Enabled := false;
  btnPlayStepped.Enabled := true;
  btnPlay.Enabled := true;
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  FStopPlaying := true;
end;

procedure TForm1.cmbDistanceChange(Sender: TObject);
begin
  DoDijkstra;
  PaintGrid;
end;

end.
