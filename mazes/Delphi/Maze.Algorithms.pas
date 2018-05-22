unit Maze.Algorithms;

interface

uses
  Maze.Grid, System.SysUtils;

type
  TStopFunc = function : Boolean;
  TMazeGenerationProc = procedure(const Grid : IGrid; const StepProc : TProc = nil;
    const StopFunc : TStopFunc = nil);

  procedure BinaryTree(const Grid : IGrid; const StepProc : TProc = nil;
    const StopFunc : TStopFunc = nil);
  procedure AldousBroder(const Grid : IGrid; const StepProc : TProc = nil;
    const StopFunc : TStopFunc = nil);
  procedure RecursiveBacktracker(const Grid : IGrid; const StepProc : TProc = nil;
    const StopFunc : TStopFunc = nil);

implementation

uses
  Maze.Cell, Spring.Collections;

procedure BinaryTree(const Grid : IGrid; const StepProc : TProc; const StopFunc : TStopFunc);
var
  Cell : ICell;
  Neighbours : IList<ICell>;
  Index : Integer;
  Link : ICell;
  Z : ICell;
begin
  Neighbours := TCollections.CreateList<ICell>;
  for Cell in Grid.EachCell do begin
    Neighbours.Clear;
    Link := nil;

    if Assigned(Cell.Neighbour[North]) then
      Neighbours.Add(Cell.Neighbour[North]);
    if Assigned(Cell.Neighbour[East]) then
      Neighbours.Add(Cell.Neighbour[East]);

    if Neighbours.Count > 0 then begin
      Index := Random(Neighbours.Count);
      Link := Neighbours[Index];
      Cell.Link(Link);

      if Assigned(StopFunc) then
        if StopFunc() then
          Exit;

      if Assigned(StepProc) then begin
        // For visualisation
        for Z in Grid.EachCell do
          Z.Distance := -1;
        Cell.Distance := -3;
        Link.Distance := -2;

        StepProc;
      end;
    end;
  end;
end;

procedure AldousBroder(const Grid : IGrid; const StepProc : TProc = nil;
  const StopFunc : TStopFunc = nil);
var
  Cell,
  N : ICell;
  NumUnvisited : Integer;
begin
  Cell := Grid.RandomCell;
  NumUnvisited := Grid.NumCells;

  while NumUnvisited > 1 do begin
    N := Cell.Neighbours[Random(Cell.Neighbours.Count)];
    if not N.Links.Any then begin
      Cell.Link(N);
      Dec(NumUnvisited);
    end;

    // For visualisation
    if Assigned(StepProc) then begin
      Cell.Distance := -2;
      N.Distance := -3;
    end;

    Cell := N;

    if Assigned(StopFunc) then
      if StopFunc() then
        Exit;

    if Assigned(StepProc) then
      StepProc;
  end;
end;

procedure RecursiveBacktracker(const Grid : IGrid; const StepProc : TProc = nil;
  const StopFunc : TStopFunc = nil);
  function GetUnvisitedNeighbours(const Cell : ICell) : IReadOnlyList<ICell>;
  var
    List : IList<ICell>;
    Dir : TDirection;
  begin
    List := TCollections.CreateList<ICell>;
    // Neighbour cells that have no links at all (if any links, they've been visited)
    for Dir in TDirection.All() do
      if Assigned(Cell.Neighbour[Dir]) and not (Cell.Neighbour[Dir].Links.Any) then
        List.Add(Cell.Neighbour[Dir]);
    Result := List.AsReadOnlyList;
  end;
var
  Stack : IStack<ICell>;
  Current,
  N : ICell;
  Neighbours : IReadOnlyList<ICell>;
begin
  Stack := TCollections.CreateStack<ICell>;
  Stack.Push(Grid.Cells[Grid.Rows-1, 0]); // Bottom left; can be random

  while Stack.Any do begin
    Current := Stack.Peek;
    N := nil;

    Neighbours := GetUnvisitedNeighbours(Current);
    if Neighbours.Any then begin
      N := Neighbours[Random(Neighbours.Count)];
      Current.Link(N);
      Stack.Push(N);
    end else
      Stack.Pop;

    if Assigned(StopFunc) then
      if StopFunc() then
        Exit;

    if Assigned(StepProc) then begin
      // For visualisation
      for Current in Grid.EachCell do
        Current.Distance := -1;
      for Current in Stack do
        Current.Distance := -2;
      if Stack.Any then
        Stack.Peek.Distance := -3;

      StepProc;
    end;
  end;
end;

end.
