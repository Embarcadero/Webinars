unit Maze.DistanceDijkstra;

interface

uses
  Maze.Grid, Maze.Cell;

  procedure CalcDijkstraDistance(const Grid : IGrid);
  procedure CalcDijkstraSolve(const Grid : IGrid);

implementation

uses
  Spring.Collections, System.SysUtils;

function GetDistances(const Grid : IGrid) : IDictionary<ICell, Integer>;
var
  Distances : IDictionary<ICell, Integer>;
  Cell,
  Link : ICell;
  Frontier,
  NewFrontier : IList<ICell>;
begin
  Distances := TCollections.CreateDictionary<ICell, Integer>;
  for Cell in Grid.EachCell do
    Distances.Add(Cell, -1);

  Frontier := TCollections.CreateList<ICell>;
  NewFrontier := TCollections.CreateList<ICell>;

  // Start cell is always bottom left - arbitrary
  Cell := Grid.Cells[Grid.Rows-1, 0];
  Frontier.Add(Cell);
  Distances[Cell] := 0;

  while Frontier.Any do begin
    NewFrontier.Clear;

    for Cell in Frontier do begin
      for Link in Cell.Links do begin
        if Distances[Link] = -1 then begin
          Distances.AddOrSetValue(Link, Distances[Cell] + 1);
          NewFrontier.Add(Link);
        end;
      end;
    end;

    Frontier.Clear;
    Frontier.AddRange(NewFrontier);
  end;

  Result := Distances;
end;

procedure CalcDijkstraDistance(const Grid : IGrid);
var
  Distances : IDictionary<ICell, Integer>;
  Cell : ICell;
begin
  Distances := GetDistances(Grid);

  for Cell in Distances.Keys do
    Cell.Distance := Distances[Cell];
end;

function FindMaxCell(const Distances : IDictionary<ICell, Integer>) : ICell;
var
  MaxDist : Integer;
  Cell : ICell;
begin
  Result := nil;
  MaxDist := -1;
  for Cell in Distances.Keys do
    if Cell.Distance > MaxDist then begin
      MaxDist := Cell.Distance;
      Result := Cell;
    end;
end;

function FindMinLinkedNeighbour(const Cell : ICell; const Distances : IDictionary<ICell, Integer>) : ICell;
var
  MaxDist : Integer;
  N : ICell;
begin
  Result := nil;
  MaxDist := Distances[Cell];
  for N in Cell.Links do
    if Distances[N] < MaxDist then begin
      MaxDist := Distances[N];
      Result := N;
    end;
end;

procedure CalcDijkstraSolve(const Grid : IGrid);
var
  Distances : IDictionary<ICell, Integer>;
  Cell,
  CurrentCell : ICell;
begin
  for Cell in Grid.EachCell do
    Cell.Distance := -1;

  Distances := GetDistances(Grid);
  //CurrentCell := FindMaxCell(Distances);

  // Always solve to the bottom right - arbitrary
  CurrentCell := Grid.Cells[Grid.Rows-1, Grid.Columns-1];

  // If not found, or it's the starting cell, quit
  if not Assigned(CurrentCell) or (Distances[CurrentCell] <= 0) then
    Exit;

  while Assigned(CurrentCell) do begin
    CurrentCell.Distance := Distances[CurrentCell]; // Non- -1
    CurrentCell := FindMinLinkedNeighbour(CurrentCell, Distances);
  end;
end;

end.
