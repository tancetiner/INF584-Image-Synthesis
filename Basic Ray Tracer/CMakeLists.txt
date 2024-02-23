cmake_minimum_required(VERSION 3.9)

project(Basic_Ray_Tracer LANGUAGES CXX)

add_subdirectory(External)

add_executable (
	Basic_Ray_Tracer
	Sources/Main.cpp
	Sources/Console.h
	Sources/Console.cpp
	Sources/Error.h
	Sources/Error.cpp
	Sources/Image.h
	Sources/Transform.h
	Sources/Camera.h
	Sources/Camera.cpp
	Sources/Mesh.h
	Sources/Mesh.cpp
	Sources/MeshLoader.h
	Sources/MeshLoader.cpp
	Sources/RayTracer.h
	Sources/RayTracer.cpp
	Sources/Rasterizer.h
	Sources/Rasterizer.cpp
	Sources/Resources.h
	Sources/ShaderProgram.h
	Sources/ShaderProgram.cpp
	Sources/Scene.h
)

set_target_properties(Basic_Ray_Tracer PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED YES
    CXX_EXTENSIONS NO
)

# Copy the shader files in the binary location.

include_directories(${CMAKE_CURRENT_SOURCE_DIR} External/stb_image/)

target_link_libraries(Basic_Ray_Tracer LINK_PRIVATE glad)

target_link_libraries(Basic_Ray_Tracer LINK_PRIVATE glfw)

target_link_libraries(Basic_Ray_Tracer LINK_PRIVATE glm)





