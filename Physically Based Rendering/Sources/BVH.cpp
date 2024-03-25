// ----------------------------------------------
// Polytechnique - INF584 "Image Synthesis"
//
// Base code for practical assignments.
//
// Copyright (C) 2020-2024 Tamy Boubekeur
// All rights reserved.
// ----------------------------------------------
#include "BVH.h"

#include <algorithm>

using namespace std;

struct AxisSort {
  AxisSort(const std::shared_ptr<Scene> scene, size_t axis)
      : m_scene(scene), m_axis(axis) {}
  const std::shared_ptr<Scene> m_scene;
  size_t m_axis;
  bool operator()(const std::pair<size_t, size_t> &i,
                  const std::pair<size_t, size_t> &j) {
    const std::shared_ptr<Mesh> meshi = m_scene->mesh(i.first);
    const auto &Pi = meshi->vertexPositions();
    const auto &ti = meshi->triangles()[i.second];
    glm::mat4 transi = meshi->computeTransformMatrix();
    glm::vec3 pi = glm::vec3(transi * glm::vec4(Pi[ti[0].positionIndex], 1.0));
    const std::shared_ptr<Mesh> meshj = m_scene->mesh(j.first);
    const auto &Pj = meshj->vertexPositions();
    const auto &tj = meshj->triangles()[j.second];
    glm::mat4 transj = meshj->computeTransformMatrix();
    glm::vec3 pj = glm::vec3(transj * glm::vec4(Pj[tj[0].positionIndex], 1.0));
    return (pi[m_axis] < pj[m_axis]);
  }
};

BVH::BVH(const std::shared_ptr<Scene> scene)
    : BVH(scene, makeIndexPairSet(scene)) {}

BVH::BVH(const std::shared_ptr<Scene> scene,
         std::vector<std::pair<size_t, size_t>> &indexPairSet)
    : BVH(scene, indexPairSet, 0, indexPairSet.size()) {}

BVH::BVH(const std::shared_ptr<Scene> scene,
         std::vector<std::pair<size_t, size_t>> &indexPairSet, size_t begin,
         size_t end) {
  for (size_t i = begin; i < end; ++i) {
    const auto &indexPair = indexPairSet[i];
    const auto mesh = scene->mesh(indexPair.first);
    const auto &vertexPositions = mesh->vertexPositions();
    const auto &triangle = mesh->triangles()[indexPair.second];
    glm::mat4 transform = mesh->computeTransformMatrix();
    for (size_t j = 0; j < 3; ++j) {
      const glm::vec3 &p =
          glm::vec3(transform *
                    glm::vec4(vertexPositions[triangle[j].positionIndex], 1.0));
      if (i == begin && j == 0)
        m_bbox.init(p);
      else
        m_bbox.extendTo(p);
    }
  }

  // Using sort (std::sort(indexPairSet.begin() + int(begin),
  // indexPairSet.begin() + int(end), AxisSort(scene, axis));) is too much work,
  // a partial sort is enough.
  size_t axis = m_bbox.dominantAxis();
  auto median = indexPairSet.begin() + int(end - begin) / 2;
  std::nth_element(indexPairSet.begin() + int(begin), median,
                   indexPairSet.begin() + int(end), AxisSort(scene, axis));

  if (end - begin >= 2) {
    size_t mid = (end + begin) / 2;
    m_left = new BVH(scene, indexPairSet, begin, mid);
    m_right = new BVH(scene, indexPairSet, mid, end);
  } else {
    m_meshIndex = indexPairSet[begin].first;
    m_triangleIndex = indexPairSet[begin].second;
    m_left = nullptr;
    m_right = nullptr;
  }
}

std::vector<std::pair<size_t, size_t>>
BVH::makeIndexPairSet(const std::shared_ptr<Scene> scene) {
  std::vector<std::pair<size_t, size_t>> indexPairSet;
  for (size_t meshIndex = 0; meshIndex < scene->numOfMeshes(); ++meshIndex) {
    const auto &T = scene->mesh(meshIndex)->triangles();
    for (size_t triangleIndex = 0; triangleIndex < T.size(); ++triangleIndex)
      indexPairSet.push_back(
          std::pair<size_t, size_t>(meshIndex, triangleIndex));
  }
  return indexPairSet;
}

BVH::BVH(const BVH &bvh) {
  m_bbox = bvh.m_bbox;
  m_meshIndex = bvh.m_meshIndex;
  m_triangleIndex = bvh.m_triangleIndex;
  if (bvh.isLeaf()) {
    m_left = new BVH(*(bvh.m_left));
    m_right = new BVH(*(bvh.m_right));
  } else
    m_left = m_right = nullptr;
}

BVH::~BVH() {
  if (!isLeaf()) {
    delete m_left;
    delete m_right;
  }
}

BVH &BVH::operator=(const BVH &bvh) {
  m_bbox = bvh.m_bbox;
  m_meshIndex = bvh.m_meshIndex;
  m_triangleIndex = bvh.m_triangleIndex;
  if (bvh.isLeaf()) {
    m_left = new BVH(*(bvh.m_left));
    m_right = new BVH(*(bvh.m_right));
  } else
    m_left = m_right = nullptr;
  return (*this);
}

void BVH::intersect(
    const Ray &r,
    std::vector<std::pair<size_t, size_t>> &candidateMeshTrianglePairs) const {
  float n;
  float f;
  if (r.boxIntersect(m_bbox.min(), m_bbox.max(), n, f)) {
    if (isLeaf()) {
      candidateMeshTrianglePairs.push_back(
          std::pair<size_t, size_t>(m_meshIndex, m_triangleIndex));
      return;
    } else {
      m_left->intersect(r, candidateMeshTrianglePairs);
      m_right->intersect(r, candidateMeshTrianglePairs);
    }
  }
}
