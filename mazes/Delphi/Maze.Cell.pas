unit Maze.Cell;

interface

uses
  Spring.Collections;

type
  TDirection = (North, South, East, West);
  TDirections = set of TDirection;

  TDirectionHelper = record helper for TDirection
    class function All : TDirections; static;
  end;

  ICell = interface
    ['{A79F9831-84B9-40A1-84BB-74627213A5CE}']

    function Row : Integer;
    function Column : Integer;

    procedure Link(Cell : ICell; Bidi : Boolean = true);
    procedure UnLink(Cell : ICell; Bidi : Boolean = true);
    procedure UnLinkAll;

    function Links : Spring.Collections.IReadOnlyCollection<ICell>;
    function IsLinked(const Cell : ICell) : Boolean;

    function Neighbours : Spring.Collections.IReadOnlyList<ICell>;

    function GetNeighbour(Direction : TDirection) : ICell;
    procedure SetNeighbour(Direction : TDirection; Cell : ICell);
    property Neighbour[Direction : TDirection] : ICell read GetNeighbour write SetNeighbour;

    function GetDistance : Integer;
    procedure SetDistance(Dist : Integer);
    property Distance : Integer read GetDistance write SetDistance;
  end;

  function CreateCell(const ARow, AColumn : Integer) : ICell;

implementation

type
  TCell = class(TInterfacedObject, ICell)
  private
    FRow,
    FColumn : Integer;
    FLinks : IDictionary<ICell, Boolean>;
    FNeighbours : IDictionary<TDirection, ICell>;
    FDistance : Integer;
  public
    constructor Create(const ARow, AColumn : Integer);

    function Row : Integer;
    function Column : Integer;

    procedure Link(Cell : ICell; Bidi : Boolean = true);
    procedure UnLink(Cell : ICell; Bidi : Boolean = true);
    procedure UnLinkAll;

    function Links : Spring.Collections.IReadOnlyCollection<ICell>;
    function IsLinked(const Cell : ICell) : Boolean;

    function Neighbours : Spring.Collections.IReadOnlyList<ICell>;

    function GetNeighbour(Direction : TDirection) : ICell;
    procedure SetNeighbour(Direction : TDirection; Cell : ICell);
    property Neighbour[Direction : TDirection] : ICell read GetNeighbour write SetNeighbour;

    function GetDistance : Integer;
    procedure SetDistance(Dist : Integer);
    property Distance : Integer read GetDistance write SetDistance;
  end;

function CreateCell(const ARow, AColumn : Integer) : ICell;
begin
  Result := TCell.Create(ARow, AColumn);
end;

{ TDirectionHelper }

class function TDirectionHelper.All: TDirections;
begin
  Result := [North, South, East, West];
end;

{ TCell }

constructor TCell.Create(const ARow, AColumn: Integer);
begin
  inherited Create();
  FRow := ARow;
  FColumn := AColumn;
  FLinks := TCollections.CreateDictionary<ICell, Boolean>;
  FNeighbours := TCollections.CreateDictionary<TDirection, ICell>;
  FDistance := -1;
end;

function TCell.Column: Integer;
begin
  Result := FColumn;
end;

function TCell.Row: Integer;
begin
  Result := FRow;
end;

procedure TCell.Link(Cell: ICell; Bidi: Boolean);
begin
  FLinks[Cell] := true;
  if Bidi then
    Cell.Link(Self, false);
end;

procedure TCell.UnLink(Cell: ICell; Bidi: Boolean);
begin
  FLinks[Cell] := false;
  if Bidi then
    Cell.UnLink(Self, false);
end;

procedure TCell.UnLinkAll;
begin
  // Because IDictionary doesn't support [weak] refs
  FLinks.Clear;
  FNeighbours.Clear;
end;

function TCell.Links: Spring.Collections.IReadOnlyCollection<ICell>;
begin
  Result := FLinks.Keys;
end;

function TCell.IsLinked(const Cell: ICell): Boolean;
begin
  if not Assigned(Cell) then
    Exit(false); // Common case

  Result := Links.Contains(Cell);
end;

function TCell.Neighbours: Spring.Collections.IReadOnlyList<ICell>;
var
  List : IList<ICell>;
  Dir : TDirection;
begin
  List := TCollections.CreateList<ICell>;

  for Dir in TDirection.All() do
    if Assigned(Neighbour[Dir]) then
      List.Add(Neighbour[Dir]);

  Result := List.AsReadOnlyList;
end;

function TCell.GetNeighbour(Direction: TDirection): ICell;
begin
  Result := FNeighbours[Direction];
end;

procedure TCell.SetNeighbour(Direction: TDirection; Cell: ICell);
begin
  FNeighbours.AddOrSetValue(Direction, Cell);
end;

function TCell.GetDistance: Integer;
begin
  Result := FDistance;
end;

procedure TCell.SetDistance(Dist: Integer);
begin
  FDistance := Dist;
end;

end.
