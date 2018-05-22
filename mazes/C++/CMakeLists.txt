cmake_minimum_required (VERSION 3.10)
project (Mazes)

set_embt_target("FMX" "DynamicRuntime")
 
add_executable(Mazes CppMazes.cpp Algorithms.cpp Cell.cpp DistanceDijkstra.cpp Grid.cpp MainForm.cpp)

