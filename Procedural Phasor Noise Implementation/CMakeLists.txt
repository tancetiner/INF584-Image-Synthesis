cmake_minimum_required(VERSION 3.9)

project(Procedural_Phasor_Noise LANGUAGES CXX)

add_subdirectory(External)

add_executable (
	Procedural_Phasor_Noise
	Sources/Main.cpp
	Sources/Camera.h
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
	Sources/Rasterizer.h
	Sources/Rasterizer.cpp
	Sources/Resources.h
	Sources/ShaderProgram.h
	Sources/ShaderProgram.cpp
	Sources/Scene.h
	Sources/Transform.h
)

set_target_properties(Procedural_Phasor_Noise PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED YES
    CXX_EXTENSIONS NO
)

# Copy the shader files in the binary location.

add_custom_command(TARGET Procedural_Phasor_Noise 
                   POST_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:Procedural_Phasor_Noise> ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${CMAKE_CURRENT_SOURCE_DIR} External/stb_image/)

target_link_libraries(Procedural_Phasor_Noise LINK_PRIVATE glad)

target_link_libraries(Procedural_Phasor_Noise LINK_PRIVATE glfw)

target_link_libraries(Procedural_Phasor_Noise LINK_PRIVATE glm)

