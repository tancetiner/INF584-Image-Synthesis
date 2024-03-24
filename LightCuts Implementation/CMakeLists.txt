cmake_minimum_required(VERSION 3.9)

project(LightCuts LANGUAGES CXX)

add_subdirectory(External)

add_executable (
	LightCuts
	Sources/Main.cpp
	Sources/Camera.h
	Sources/Camera.cpp
	Sources/Console.h
	Sources/Console.cpp
	Sources/Error.h
	Sources/Error.cpp
	Sources/Image.h
	Sources/Image.cpp
	Sources/IO.h
	Sources/IO.cpp
	Sources/LightSource.h
	Sources/Material.h 
	Sources/Mesh.h
	Sources/Mesh.cpp
	Sources/PBR.h
	Sources/Ray.h
	Sources/Ray.cpp
	Sources/RayTracer.h
	Sources/RayTracer.cpp
	Sources/Rasterizer.h
	Sources/Rasterizer.cpp
	Sources/Resources.h
	Sources/ShaderProgram.h
	Sources/ShaderProgram.cpp
	Sources/Scene.h
	Sources/Transform.h
	Sources/BVH.h
)

set_target_properties(LightCuts PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED YES
    CXX_EXTENSIONS NO
)

# Copy the shader files in the binary location.

add_custom_command(TARGET LightCuts 
                   POST_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:LightCuts> ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${CMAKE_CURRENT_SOURCE_DIR} External/stb_image/)

target_link_libraries(LightCuts LINK_PRIVATE glad)

target_link_libraries(LightCuts LINK_PRIVATE glfw)

target_link_libraries(LightCuts LINK_PRIVATE glm)

