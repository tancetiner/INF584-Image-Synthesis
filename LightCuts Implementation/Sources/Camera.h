// ----------------------------------------------
// Polytechnique - INF584 "Image Synthesis"
//
// Base code for practical assignments.
//
// Copyright (C) 2022 Tamy Boubekeur
// All rights reserved.
// ----------------------------------------------
#pragma once

#include <iostream>

#include <glm/glm.hpp>
#include <glm/ext.hpp>
#define GLM_ENABLE_EXPERIMENTAL

#include <glm/gtx/string_cast.hpp>

#include "Transform.h"
#include "Ray.h"


/// Basic camera model
class Camera : public Transform {
public:
	inline float getFoV () const { return m_fov; }
	inline void setFoV (float f) { m_fov = f; }
	inline float getAspectRatio () const { return m_aspectRatio; }
	inline void setAspectRatio (float a) { m_aspectRatio = a; }
	inline float getNear () const { return m_near; }
	inline void setNear (float n) { m_near = n; }
	inline float getFar () const { return m_far; }
	inline void setFar (float n) { m_far = n; }
		
	/**
	 *  The view matrix is the inverse of the camera model matrix, 
	 *  so that we can express the entire world in the camera frame 
	 *  by transforming all its entities with this matrix. 
	 *  Here, it is composed after the camera transformation and the 
	 *  rotation matrix stemming from the cmaera quaternion.
	 */
	inline glm::mat4 computeViewMatrix () const { return inverse (glm::mat4_cast (curQuat) * computeTransformMatrix ()); }
	
	/// Returns the projection matrix stemming from the camera intrinsic parameter. 
	inline glm::mat4 computeProjectionMatrix () const {	return glm::perspective (glm::radians (m_fov), m_aspectRatio, m_near, m_far); }

	/// Creates and returns a Ray with origin at the camera location and pointing toward the (u,v) location on the associated image plane.
	Ray rayAt (float u, float v) const;

private:
	float m_fov = 45.f; // Vertical field of view, in degrees
	float m_aspectRatio = 1.f; // Ratio between the width and the height of the image
	float m_near = 0.1f; // Distance before which geometry is excluded fromt he rasterization process
	float m_far = 10.f; // Distance after which the geometry is excluded fromt he rasterization process
	glm::quat curQuat;
	glm::quat lastQuat;
};
