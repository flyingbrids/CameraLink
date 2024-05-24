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
CMAKE_SOURCE_DIR = C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp

# Include any dependencies generated for this target.
include libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/compiler_depend.make

# Include the progress variables for this target.
include libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/progress.make

# Include the compile flags for this target's objects.
include libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/flags.make

libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.obj: libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/flags.make
libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.obj: C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/coresightps_dcc/src/xcoresightpsdcc.c
libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.obj: libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.obj"
	cd C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp/libsrc/coresightps_dcc/src && C:/Xilinx/Vitis/2023.2/gnu/aarch32/nt/gcc-arm-none-eabi/bin/arm-none-eabi-gcc.exe $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -MD -MT libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.obj -MF CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.obj.d -o CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.obj -c C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/coresightps_dcc/src/xcoresightpsdcc.c

libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.i"
	cd C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp/libsrc/coresightps_dcc/src && C:/Xilinx/Vitis/2023.2/gnu/aarch32/nt/gcc-arm-none-eabi/bin/arm-none-eabi-gcc.exe $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/coresightps_dcc/src/xcoresightpsdcc.c > CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.i

libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.s"
	cd C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp/libsrc/coresightps_dcc/src && C:/Xilinx/Vitis/2023.2/gnu/aarch32/nt/gcc-arm-none-eabi/bin/arm-none-eabi-gcc.exe $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/coresightps_dcc/src/xcoresightpsdcc.c -o CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.s

# Object files for target coresightps_dcc
coresightps_dcc_OBJECTS = \
"CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.obj"

# External object files for target coresightps_dcc
coresightps_dcc_EXTERNAL_OBJECTS =

libsrc/coresightps_dcc/src/libcoresightps_dcc.a: libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/xcoresightpsdcc.c.obj
libsrc/coresightps_dcc/src/libcoresightps_dcc.a: libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/build.make
libsrc/coresightps_dcc/src/libcoresightps_dcc.a: libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C static library libcoresightps_dcc.a"
	cd C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp/libsrc/coresightps_dcc/src && $(CMAKE_COMMAND) -P CMakeFiles/coresightps_dcc.dir/cmake_clean_target.cmake
	cd C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp/libsrc/coresightps_dcc/src && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/coresightps_dcc.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/build: libsrc/coresightps_dcc/src/libcoresightps_dcc.a
.PHONY : libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/build

libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/clean:
	cd C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp/libsrc/coresightps_dcc/src && $(CMAKE_COMMAND) -P CMakeFiles/coresightps_dcc.dir/cmake_clean.cmake
.PHONY : libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/clean

libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/depend:
	$(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/coresightps_dcc/src C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp/libsrc/coresightps_dcc/src C:/Project/CameraLink/PS/LizzieSat/zynq_fsbl/zynq_fsbl_bsp/libsrc/build_configs/gen_bsp/libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : libsrc/coresightps_dcc/src/CMakeFiles/coresightps_dcc.dir/depend

