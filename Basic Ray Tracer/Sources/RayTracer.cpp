// ----------------------------------------------
// Polytechnique - INF584 "Image Synthesis"
//
// Base code for practical assignments.
//
// Copyright (C) 2022 Tamy Boubekeur
// All rights reserved.
// ----------------------------------------------
#include "RayTracer.h"

#include "Console.h"
#include "Camera.h"

RayTracer::RayTracer() : 
	m_imagePtr (std::make_shared<Image>()) {}

RayTracer::~RayTracer() {}

void RayTracer::init (const std::shared_ptr<Scene> scenePtr) {
}

void RayTracer::render (const std::shared_ptr<Scene> scenePtr) {
	size_t width = m_imagePtr->width();
	size_t height = m_imagePtr->height();
	std::chrono::high_resolution_clock clock;
	Console::print ("Start ray tracing at " + std::to_string (width) + "x" + std::to_string (height) + " resolution...");
	std::chrono::time_point<std::chrono::high_resolution_clock> before = clock.now();
	m_imagePtr->clear (scenePtr->backgroundColor ());
	
	// <---- Ray tracing code ---->
	std::shared_ptr<Camera> camera = scenePtr->camera();
	for (size_t i = 0; i < width; i++) {
		for (size_t j = 0; j < height; j++) {
			float x = (2.f * (i + 0.5f) / width - 1.f) * camera->getAspectRatio() * tan(glm::radians(camera->getFoV()) / 2.f);
			float y = (1.f - 2.f * (j + 0.5f) / height) * tan(glm::radians(camera->getFoV()) / 2.f);
			Ray ray = camera->rayAt(x, y);
			m_imagePtr->operator()(i, j) = scenePtr->backgroundColor();
		}
	}
	// <---- Ray tracing code ---->


	std::chrono::time_point<std::chrono::high_resolution_clock> after = clock.now();
	double elapsedTime = (double)std::chrono::duration_cast<std::chrono::milliseconds>(after - before).count();
	Console::print ("Ray tracing executed in " + std::to_string(elapsedTime) + "ms");
}