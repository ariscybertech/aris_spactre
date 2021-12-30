#extension GL_EXT_draw_buffers : require
precision mediump float;

//---------------------------------------------------------------------
// Uniform variables
//---------------------------------------------------------------------

/// The diffuse sampler.
uniform sampler2D diffuse;

//---------------------------------------------------------------------
// Varying variables
//
// Allows communication between vertex and fragment stages
//---------------------------------------------------------------------

/// The texture coodinate of the vertex.
varying vec2 texCoord;

//---------------------------------------------------------------------
// Functions
//---------------------------------------------------------------------

void main()
{
  vec4 c = texture2D(diffuse, texCoord);
  gl_FragData[0] = vec4(c.r, 0.0, 0.0, 0.0);
  gl_FragData[1] = vec4(0.0, c.g, 0.0, 0.0);
  gl_FragData[2] = vec4(0.0, 0.0, c.b, 0.0);
  gl_FragData[3] = vec4(0.0, 0.0, 0.0, c.a);
}
