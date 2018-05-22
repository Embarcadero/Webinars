unit Maze.Grid;

interface

uses
  Maze.Cell, FMX.Graphics, Spring.Collections, System.SysUtils;

type
  IGrid = interface;
  TMazeCreationProc = procedure(const Grid : IGrid; StepProc : TProc);

  // Keep in sync with the combo box
  TCellPainting = (cdNone, cdCandidates, cdDistance, cdColour, cdSolution);

  IGrid = interface
    ['{D8A9D857-5A7A-4054-8066-06DD85B1821B}']

    function Rows : Integer;
    function Columns : Integer;

    function GetCell(ARow, AColumn : Integer) : ICell;
    property Cells[Row, Column : Integer] : ICell read GetCell; default;

    function NumCells : Integer;
    function RandomCell : ICell;

    function EachRow : IReadOnlyList<IReadOnlyList<ICell>>;
    function EachCell : IReadOnlyList<ICell>;

    function Repaint(const CellSize : Integer; const Painting : TCellPainting) : TBitmap;
  end;

  function CreateGrid(const ARows, AColumns : Integer) : IGrid;

implementation

uses
  System.Types, System.UITypes, FMX.Types;

type
  TGrid = class(TInterfacedObject, IGrid)
  private
    FRows,
    FColumns : Integer;
    FGrid : IList<IList<ICell>>;
    FBitmap : TBitmap;

    procedure PrepareGrid;
    procedure ConfigureCells;
    function GetCellRect(const Cell: ICell; const CellSize: Integer): TRect;
    procedure PaintCellFill(const CellSize: Integer;
      const Painting: TCellPainting);
    procedure PaintCellBorders(const CellSize: Integer;
      const Painting: TCellPainting);
  protected
    function BitmapSize(const CellSize : Integer) : TSize; virtual;
  public
    constructor Create(const ARows, AColumns : Integer);
    destructor Destroy; override;

    function Rows : Integer;
    function Columns : Integer;

    function NumCells : Integer; virtual;
    function RandomCell : ICell; virtual;

    function EachRow : IReadOnlyList<IReadOnlyList<ICell>>;
    function EachCell : IReadOnlyList<ICell>;

    function GetCell(ARow, AColumn : Integer) : ICell; virtual;
    property Cells[Row, Column : Integer] : ICell read GetCell; default;

    function Repaint(const CellSize : Integer; const Painting : TCellPainting) : TBitmap;
  end;

const
  BackColor = TAlphaColorRec.White;
  WallColor = TAlphaColorRec.Black;
  HalfStrokeThickness = 1;

function CreateGrid(const ARows, AColumns : Integer) : IGrid;
begin
  Result := TGrid.Create(ARows, AColumns);
end;

{ TGrid }

constructor TGrid.Create(const ARows, AColumns: Integer);
begin
  inherited Create();
  FRows := ARows;
  FColumns := AColumns;

  FBitmap := TBitmap.Create;

  PrepareGrid;
  ConfigureCells;
end;

destructor TGrid.Destroy;
var
  R, C : Integer;
begin
  // Unlink all cells from each other, so that they no longer hold references
  // and when FCells is freed, the cells will be freed
  for R := 0 to Pred(FRows) do
    for C := 0 to Pred(FColumns) do
      if Assigned(FGrid[R][C]) then
        FGrid[R][C].UnLinkAll;

  FBitmap.Free;

  inherited;
end;

procedure TGrid.PrepareGrid;
var
  R, C : Integer;
begin
  FGrid := TCollections.CreateList<IList<ICell>>;

  for R := 0 to Pred(FRows) do begin
    FGrid.Add(TCollections.CreateList<ICell>);
    FGrid[R].Count := FColumns;
  end;

  for R := 0 to Pred(FRows) do
    for C := 0 to Pred(FColumns) do
      FGrid[R][C] := CreateCell(R, C);
end;

procedure TGrid.ConfigureCells;
var
  R, C : Integer;
begin
  for R := 0 to Pred(FRows) do
    for C := 0 to Pred(FColumns) do begin
      FGrid[R][C].Neighbour[North] := Cells[R-1, C];
      FGrid[R][C].Neighbour[South] := Cells[R+1, C];
      FGrid[R][C].Neighbour[West] := Cells[R, C-1];
      FGrid[R][C].Neighbour[East] := Cells[R, C+1];
    end;
end;

function TGrid.GetCell(ARow, AColumn: Integer): ICell;
begin
  if (ARow < 0)  or (ARow >= FRows) then
    Exit(nil);
  if (AColumn < 0)  or (AColumn >= FColumns) then
    Exit(nil);

  Result := FGrid[ARow][AColumn];
end;

function TGrid.Rows: Integer;
begin
  Result := FRows;
end;

function TGrid.Columns: Integer;
begin
  Result := FColumns;
end;

function TGrid.NumCells: Integer;
begin
  Result := FRows * FColumns;
end;

function TGrid.RandomCell: ICell;
var
  Row,
  Col : Integer;
begin
  Row := Random(FRows);
  Col := Random(FGrid[Row].Count);
  Result := FGrid[Row][Col];
end;

function TGrid.EachCell: IReadOnlyList<ICell>;
var
  Res : IList<ICell>;
  Row,
  Col : Integer;
begin
  Res := TCollections.CreateList<ICell>;
  for Row := 0 to Pred(FRows) do
    for Col := 0 to Pred(FColumns) do
      if Assigned(Cells[Row, Col]) then // Future grids may not be square
        Res.Add(Cells[Row, Col]);

  Result := Res.AsReadOnlyList;
end;

function TGrid.EachRow: IReadOnlyList<IReadOnlyList<ICell>>;
var
  Row : Integer;
  Res : IList<IReadOnlyList<ICell>>;
begin
  // No easy way to get an immutable view of collections in S4D
  // Can do FGrid.AsReadOnlyList, but of course doesn't carry to the second level

  // So start with the second level
  Res := TCollections.CreateList<IReadOnlyList<ICell>>;
  for Row := 0 to Pred(FRows) do
    Res.Add(FGrid[Row].AsReadOnlyList);

  Result := Res.AsReadOnlyList;
end;

function TGrid.BitmapSize(const CellSize : Integer) : TSize;
begin
  Result := TSize.Create(FColumns * CellSize + 2, FRows * CellSize + 2);
end;

function TGrid.GetCellRect(const Cell : ICell; const CellSize : Integer) : TRect;
var
  X1, X2,
  Y1, Y2 : Integer;
begin
  X1 := Cell.Column * CellSize + HalfStrokeThickness;
  Y1 := Cell.Row * CellSize + HalfStrokeThickness;
  X2 := (Cell.Column + 1) * CellSize + HalfStrokeThickness;
  Y2 := (Cell.Row + 1) * CellSize + HalfStrokeThickness;
  Result := Rect(X1, Y1, X2, Y2);
end;

procedure TGrid.PaintCellFill(const CellSize : Integer; const Painting : TCellPainting);
const
  Alpha = 0.7;
var
  Cell : ICell;
  CellRect : TRect;
  MaxDist : Integer;
begin
  MaxDist := -1;
  for Cell in EachCell do
    if Cell.Distance > MaxDist then
      MaxDist := Cell.Distance;

  FBitmap.Canvas.Font.Size := CellSize * 0.5;

  FBitmap.Canvas.BeginScene;
  try
    for Cell in EachCell do begin
      // Fill based on cell distance
      if (Cell.Distance >= 0) or (Painting = cdCandidates) then begin
        CellRect := GetCellRect(Cell, CellSize);
        case Painting of
          cdNone : ;
          cdCandidates : begin // Paint candidate cells, ones with dist -2, -3
            if Cell.Distance = -1 then
              FBitmap.Canvas.Fill.Color := TAlphaColorRec.White
            else if Cell.Distance = -2 then
              FBitmap.Canvas.Fill.Color := TAlphaColorRec.Cornflowerblue
            else if Cell.Distance = -3 then
              FBitmap.Canvas.Fill.Color := TAlphaColorRec.Red;

            FBitmap.Canvas.FillRect(CellRect, 0, 0, [], Alpha);
          end;
          cdDistance : begin
            FBitmap.Canvas.Fill.Color := TAlphaColorRec.Red;
            FBitmap.Canvas.FillText(CellRect, IntToStr(Cell.Distance), false, 1.0,
              [], TTextAlign.Center, TTextAlign.Center);
          end;
          cdColour : begin
            if Cell.Distance = 0 then
              FBitmap.Canvas.Fill.Color := TAlphaColorRec.Red
            else
              FBitmap.Canvas.Fill.Color := TAlphaColorF.Create(Cell.Distance / MaxDist, 0, 0).ToAlphaColor;
            FBitmap.Canvas.FillRect(CellRect, 0, 0, [], Alpha);
          end;
          cdSolution : begin
            if Cell.Distance >= 0 then begin
              FBitmap.Canvas.Fill.Color := TAlphaColorRec.Red;
              FBitmap.Canvas.FillRect(CellRect, 0, 0, [], Alpha);
            end;
          end;
        end;
      end;
    end;
  finally
    FBitmap.Canvas.EndScene;
  end;
end;

procedure TGrid.PaintCellBorders(const CellSize : Integer; const Painting : TCellPainting);
const
  Stroke = HalfStrokeThickness * 2;
var
  Cell : ICell;
  CellRect : TRectF;
begin
  FBitmap.Canvas.BeginScene;
  try
    FBitmap.Canvas.Stroke.Kind := TBrushKind.Solid;
    FBitmap.Canvas.Stroke.Thickness := Stroke;
    FBitmap.Canvas.Stroke.Color := WallColor;

    for Cell in EachCell do begin
      CellRect := GetCellRect(Cell, CellSize);

      if not Assigned(Cell.Neighbour[North]) then
        FBitmap.Canvas.DrawLine(PointF(CellRect.Left, CellRect.Top), PointF(CellRect.Right, CellRect.Top), 1.0);
      if not Assigned(Cell.Neighbour[West]) then
        FBitmap.Canvas.DrawLine(PointF(CellRect.Left, CellRect.Top), PointF(CellRect.Left, CellRect.Bottom), 1.0);

      if not Cell.IsLinked(Cell.Neighbour[East]) then
        FBitmap.Canvas.DrawLine(PointF(CellRect.Right, CellRect.Top), PointF(CellRect.Right, CellRect.Bottom), 1.0);
      if not Cell.IsLinked(Cell.Neighbour[South]) then
        FBitmap.Canvas.DrawLine(PointF(CellRect.Left, CellRect.Bottom), PointF(CellRect.Right, CellRect.Bottom), 1.0);
    end;
  finally
    FBitmap.Canvas.EndScene;
  end;
end;

function TGrid.Repaint(const CellSize : Integer; const Painting : TCellPainting) : TBitmap;
var
  BMPSize : TSize;
begin
  BMPSize := BitmapSize(CellSize);
  FBitmap.Width := BMPSize.cx;
  FBitmap.Height := BMPSize.cy;
  FBitmap.Clear(BackColor);

  PaintCellFill(CellSize, Painting);
  PaintCellBorders(CellSize, Painting);

  Result := FBitmap;
end;

end.
