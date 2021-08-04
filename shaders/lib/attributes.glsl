#if !defined(_INCLUDE_ATTRIBUTES_GLSL)
#define _INCLUDE_ATTRIBUTES_GLSL

// xy = blockId, renderType
// "blockId" is used only for blocks specified in "block.properties"
attribute vec3 mc_Entity;

// st = midTexU, midTexV
// Sprite middle UV coordinates
attribute vec2 mc_midTexCoord;

// xyz = tangent vector, w = handedness
attribute vec4 at_tangent;

// vertex offset to previous frame
// In view space, only for entities and block entities
attribute vec3 at_velocity;

// offset to block center in 1/64m units
// Only for blocks
attribute vec3 at_midBlock;

#endif
