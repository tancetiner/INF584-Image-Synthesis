// ----------------------------------------------
// Polytechnique - INF584 "Image Synthesis"
//
// Base code for practical assignments.
//
// Copyright (C) 2022 Tamy Boubekeur
// All rights reserved.
// ----------------------------------------------
#pragma once

#include <vector>
#include <memory>

#include <glm/glm.hpp>
#include <glm/ext.hpp>

#include "Transform.h"

struct Material
{
	glm::vec3 albedo;
	float roughness;
	float metallicness;
};

class Mesh : public Transform
{
public:
	virtual ~Mesh();

	inline const std::vector<glm::vec3> &vertexPositions() const { return m_vertexPositions; }
	inline std::vector<glm::vec3> &vertexPositions() { return m_vertexPositions; }
	inline const std::vector<glm::vec3> &vertexNormals() const { return m_vertexNormals; }
	inline std::vector<glm::vec3> &vertexNormals() { return m_vertexNormals; }
	inline const std::vector<glm::uvec3> &triangleIndices() const { return m_triangleIndices; }
	inline std::vector<glm::uvec3> &triangleIndices() { return m_triangleIndices; }
	inline const std::shared_ptr<Material> &material() const { return m_material; }
	inline std::shared_ptr<Material> &material() { return m_material; }

	/// Compute the parameters of a sphere which bounds the mesh
	void computeBoundingSphere(glm::vec3 &center, float &radius) const;

	void recomputePerVertexNormals(bool angleBased = false);

	void clear();

private:
	std::vector<glm::vec3> m_vertexPositions;
	std::vector<glm::vec3> m_vertexNormals;
	std::vector<glm::uvec3> m_triangleIndices;
	std::shared_ptr<Material> m_material;
};
