# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.24

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Produce verbose output by default.
VERBOSE = 1

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = C:/Xilinx/Vitis/2023.2/tps/win64/cmake-3.24.2/bin/cmake.exe

# The command to remove a file.
RM = C:/Xilinx/Vitis/2023.2/tps/win64/cmake-3.24.2/bin/cmake.exe -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = C:/Project/CameraLink/PS/LizzieSat/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/libsrc/build_configs/exmetadata

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = C:/Project/CameraLink/PS/LizzieSat/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/libsrc/build_configs/exmetadata

# Utility rule file for uartns550_example.

# Include any custom commands dependencies for this target.
include CMakeFiles/uartns550_example.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/uartns550_example.dir/progress.make

CMakeFiles/uartns550_example:
	lopper -f -O C:/Project/CameraLink/PS/LizzieSat/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/libsrc/uartns550 C:/Project/CameraLink/PS/LizzieSat/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/hw_artifacts/ps7_cortexa9_0_baremetal.dts -- bmcmake_metadata_xlnx ps7_cortexa9_0 C:/Xilinx/Vitis/2023.2/data/embeddedsw/XilinxProcessorIPLib/drivers/uartns550_v3_9/examples drvcmake_metadata

uartns550_example: CMakeFiles/uartns550_example
uartns550_example: CMakeFiles/uartns550_example.dir/build.make
.PHONY : uartns550_example

# Rule to build all files generated by this target.
CMakeFiles/uartns550_example.dir/build: uartns550_example
.PHONY : CMakeFiles/uartns550_example.dir/build

CMakeFiles/uartns550_example.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/uartns550_example.dir/cmake_clean.cmake
.PHONY : CMakeFiles/uartns550_example.dir/clean

CMakeFiles/uartns550_example.dir/depend:
	$(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" C:/Project/CameraLink/PS/LizzieSat/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/libsrc/build_configs/exmetadata C:/Project/CameraLink/PS/LizzieSat/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/libsrc/build_configs/exmetadata C:/Project/CameraLink/PS/LizzieSat/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/libsrc/build_configs/exmetadata C:/Project/CameraLink/PS/LizzieSat/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/libsrc/build_configs/exmetadata C:/Project/CameraLink/PS/LizzieSat/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/libsrc/build_configs/exmetadata/CMakeFiles/uartns550_example.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/uartns550_example.dir/depend

