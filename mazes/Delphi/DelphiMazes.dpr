program DelphiMazes;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm in 'MainForm.pas' {Form1},
  Maze.Cell in 'Maze.Cell.pas',
  Maze.Grid in 'Maze.Grid.pas',
  Maze.Algorithms in 'Maze.Algorithms.pas',
  Maze.DistanceDijkstra in 'Maze.DistanceDijkstra.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
