// ----------------------------------------------
// Polytechnique - INF584 "Image Synthesis"
//
// Base code for practical assignments.
//
// Copyright (C) 2022 Tamy Boubekeur
// All rights reserved.
// ----------------------------------------------
#include "Camera.h"

inline Ray Camera::rayAt (float x, float y) const {
		glm::vec4 p (x, y, 0.f, 1.f);
		glm::vec4 p2 (x, y, 1.f, 1.f);
		glm::mat4 viewMatrix = computeViewMatrix ();
		glm::mat4 projectionMatrix = computeProjectionMatrix ();
		glm::vec4 pWorld = glm::inverse (projectionMatrix * viewMatrix) * p;
		glm::vec4 pWorld2 = glm::inverse (projectionMatrix * viewMatrix) * p2;
		glm::vec3 origin = glm::vec3 (pWorld / pWorld.w);
		glm::vec3 direction = glm::normalize (glm::vec3 (pWorld2 / pWorld2.w) - origin);
		return Ray (origin, direction);
	}
