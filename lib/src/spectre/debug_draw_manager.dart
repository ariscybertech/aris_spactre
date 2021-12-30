/*
  Copyright (C) 2013 John McCutchan

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

part of spectre;

class _DebugLineVertex {
  double x;
  double y;
  double z;
  _DebugLineVertex next = null;
}

class _DebugLineObject {
  double r;
  double g;
  double b;
  double a;
  double duration;
  _DebugLineVertex vertexStream;
}

class _DebugLineCollection {
  List<_DebugLineVertex> _freeLineVertices;
  List<_DebugLineObject> _freeLineObjects;
  List<_DebugLineObject> _lineObjects;

  _DebugLineObject _lineObject;

  _DebugLineCollection() {
    _freeLineVertices = new List<_DebugLineVertex>();
    _freeLineObjects = new List<_DebugLineObject>();
    _lineObjects = new List<_DebugLineObject>();
  }

  void startLineObject(double r, double g, double b, double a, double duration){
    // Can't call recursively.
    assert(_lineObject == null);
    if (_freeLineObjects.length > 0) {
      _lineObject = _freeLineObjects.removeLast();
    } else {
      _lineObject = new _DebugLineObject();
    }
    _lineObject.r = r;
    _lineObject.g = g;
    _lineObject.b = b;
    _lineObject.a = a;
    _lineObject.duration = duration;
  }

  void finishLineObject() {
    if (_lineObject != null) {
      _lineObjects.add(_lineObject);
      _lineObject = null;
    }
  }

  _DebugLineVertex getVertex() {
    if (_freeLineVertices.length > 0) {
      return _freeLineVertices.removeLast();
    }
    return new _DebugLineVertex();
  }

  void addVertex(double x, double y, double z) {
    _DebugLineVertex v = getVertex();
    v.x = x;
    v.y = y;
    v.z = z;
    v.next = _lineObject.vertexStream;
    _lineObject.vertexStream = v;
  }

  void freeLineObject(_DebugLineObject lineObject) {
    _DebugLineVertex v = lineObject.vertexStream;
    while (v != null) {
      _freeLineVertices.add(v);
      v = v.next;
    }
    lineObject.vertexStream = null;
    _freeLineObjects.add(lineObject);
  }

  void update(num dt) {
    for (int i = _lineObjects.length-1; i >= 0; i--) {
      _DebugLineObject lineObject = _lineObjects[i];
      lineObject.duration -= dt;
      if (lineObject.duration < 0.0) {
        freeLineObject(lineObject);
        int last = _lineObjects.length-1;
        // Copy last over
        _lineObjects[i] = _lineObjects[last];
        _lineObjects.removeLast();
      }
    }
  }

  void _addLine(Vector3 start, Vector3 finish) {
    addVertex(finish.x, finish.y, finish.z);
    addVertex(start.x, start.y, start.z);
  }

  void _addLineRaw(double sx, double sy, double sz,
                   double fx, double fy, double fz) {
    addVertex(fx, fy, fz);
    addVertex(sx, sy, sz);
  }
}

class _DebugDrawLineManager {
  static final int DebugDrawVertexSize = 7; // 3 (position) + 4 (color)
  final GraphicsDevice device;
  final _DebugLineCollection lines = new _DebugLineCollection();
  SingleArrayMesh _lineMesh;
  InputLayout _lineMeshInputLayout;

  Float32List _vboStorage;

  _DebugDrawLineManager(this.device, int maxVertices,
                        ShaderProgram shaderProgram) {
    if ((maxVertices & 0x1) != 0) {
      // Keep an even number of vertices.
      maxVertices += 1;
    }
    _vboStorage = new Float32List(maxVertices*DebugDrawVertexSize);
    _lineMesh = new SingleArrayMesh('_DebugDrawLineManager', device);
    _lineMesh.primitiveTopology = PrimitiveTopology.Lines;
    _lineMesh.vertexArray.allocate(_vboStorage.length*4,
                                   UsagePattern.DynamicDraw);
    _lineMesh.attributes['vPosition'] = new SpectreMeshAttribute(
        'vPosition',
        new VertexAttribute(0, 0, 0, 28, DataType.Float32, 3, false));
    _lineMesh.attributes['vColor'] = new SpectreMeshAttribute(
        'vColor',
        new VertexAttribute(0, 0, 12, 28, DataType.Float32, 4, false));
    _lineMeshInputLayout = new InputLayout('_DebugDrawLineManager', device);
    _lineMeshInputLayout.shaderProgram = shaderProgram;
    _lineMeshInputLayout.mesh = _lineMesh;
  }

  void _prepareForRender(GraphicsContext context) {
    final int vertexBufferLength = _vboStorage.length;
    int vertexBufferCursor = 0;
    for (_DebugLineObject line in lines._lineObjects) {
      _DebugLineVertex v = line.vertexStream;
      while (v != null) {
        _vboStorage[vertexBufferCursor++] = v.x;
        _vboStorage[vertexBufferCursor++] = v.y;
        _vboStorage[vertexBufferCursor++] = v.z;
        _vboStorage[vertexBufferCursor++] = line.r;
        _vboStorage[vertexBufferCursor++] = line.g;
        _vboStorage[vertexBufferCursor++] = line.b;
        _vboStorage[vertexBufferCursor++] = line.a;
        v = v.next;
        if (vertexBufferCursor == vertexBufferLength) {
          break;
        }
      }
      if (vertexBufferCursor == vertexBufferLength) {
        break;
      }
    }

    if(vertexBufferCursor != 0) {
      _lineMesh.vertexArray.uploadSubData(0, _vboStorage);
    }
    _lineMesh.count = vertexBufferCursor ~/ DebugDrawVertexSize;
  }

  void update(num dt) {
    lines.update(dt);
  }


}

/** The debug draw manager manages a collection of debug primitives that are
 * drawn each frame. Each debug primitive has a lifetime and the manager
 * continues to draw each primitive until its lifetime has expired.
 *
 * The following primitives are supported:
 *
 * - Lines
 * - Crosses
 * - Vectors
 * - Spheres
 * - Circles
 * - Arcs
 * - Transformations (coordinate axes)
 * - Triangles
 * - AABB (Axis Aligned Bounding Boxes)
 *
 *
 * The following properties can be controlled for each primitive:
 *
 * - Depth testing on or off.
 * - Size.
 * - Color.
 * - Lifetime.
 *
 */
class DebugDrawManager {
  static const double TWO_PI = 2.0 * Math.PI;

  DepthState _depthState;
  BlendState _blendState;
  RasterizerState _rasterizerState;
  VertexShader _lineVertexShader;
  FragmentShader _lineFragmentShader;
  ShaderProgram _lineShaderProgram;
  _DebugDrawLineManager _depthEnabledLines;
  _DebugDrawLineManager _depthDisabledLines;

  Float32List _cameraMatrix = new Float32List(16);

  final GraphicsDevice device;

  static Vector4 ColorRed = new Vector4(1.0, 0.0, 0.0, 1.0);
  static Vector4 ColorGreen = new Vector4(0.0, 1.0, 0.0, 1.0);
  static Vector4 ColorBlue = new Vector4(0.0, 0.0, 1.0, 1.0);

  /** Construct and initialize a DebugDrawManager. Can specify maximum
   * number of vertices with [maxVertices]. */
  DebugDrawManager(this.device, {int maxVertices: 16384}) {
    _depthState = new DepthState();
    _blendState = new BlendState.alphaBlend();
    _rasterizerState = new RasterizerState();
    _rasterizerState.cullMode = CullMode.None;
    _lineVertexShader = new VertexShader('DebugDrawManager', device);
    _lineFragmentShader = new FragmentShader('DebugDrawManager', device);
    _lineShaderProgram = new ShaderProgram('DebugDrawManager', device);
    _lineVertexShader.source = _debugLineVertexShader;
    _lineFragmentShader.source = _debugLineFragmentShader;
    _lineShaderProgram.vertexShader = _lineVertexShader;
    _lineShaderProgram.fragmentShader = _lineFragmentShader;
    _lineShaderProgram.link();
    _depthEnabledLines = new _DebugDrawLineManager(device,
                                                   maxVertices,
                                                   _lineShaderProgram);
    _depthDisabledLines = new _DebugDrawLineManager(device,
                                                    maxVertices,
                                                    _lineShaderProgram);
  }



  /** Add a line primitive extending from [start] to [finish].
   * Filled with [color].
   *
   * Optional parameters: [duration] and [depthEnabled].
   */
  void addLine(Vector3 start, Vector3 finish, Vector4 color,
               {num duration: 0.0, bool depthEnabled: true}) {
    var lineManager = depthEnabled ? _depthEnabledLines : _depthDisabledLines;
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
                                      duration);
    lineManager.lines._addLine(start, finish);
    lineManager.lines.finishLineObject();
  }


  /** Add a vector primitive extending from [origin] by [vector] with an arrow
   * at the end.
   * Filled with [color].
   *
   * Optional parameters: [size], [duration] and [depthEnabled].
   */
  void addVector(Vector3 origin, Vector3 vector, Vector4 color,
               {num size: 0.5, num duration: 0.0, bool depthEnabled: true}) {
    var lineManager = depthEnabled ? _depthEnabledLines : _depthDisabledLines;
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
                                      duration);
    var to = origin.clone().add(vector);
    var direction = vector.normalized().scale(-size);

    lineManager.lines._addLine(origin, to);
    
    var center = to.clone().add(direction);
    num s = size / Math.cos(45.0 / 2.0);
    num radius = Math.sqrt(s * s - size * size);

    buildPlaneVectors(direction.scaled(-size), _circle_u, _circle_v);
    _circle_u.normalize();
    _circle_v.normalize();

    num alpha = 0.0;
    num _step = TWO_PI/4.0;

    double lastX = center.x + _circle_u.x * radius;
    double lastY = center.y + _circle_u.y * radius;
    double lastZ = center.z + _circle_u.z * radius;

    for (alpha = 0.0; alpha <= TWO_PI; alpha += _step) {
      double cosScale = Math.cos(alpha) * radius;
      double sinScale = Math.sin(alpha) * radius;
      double lastX = center.x + cosScale * _circle_u.x + sinScale * _circle_v.x;
      double lastY = center.y + cosScale * _circle_u.y + sinScale * _circle_v.y;
      double lastZ = center.z + cosScale * _circle_u.z + sinScale * _circle_v.z;

      lineManager.lines._addLineRaw(
          to.x, to.y, to.z,
          lastX, lastY, lastZ);
    }

    lineManager.lines.finishLineObject();
  }

  /** Add a cross primitive at [point]. Filled with [color].
   *
   * Optional paremeters: [size], [duration], and [depthEnabled].
   */
  void addCross(Vector3 point, Vector4 color,
                {num size: 1.0, num duration: 0.0, bool depthEnabled:true}) {
    var lineManager = depthEnabled ? _depthEnabledLines : _depthDisabledLines;
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
                                      duration);
    num half_size = size * 0.5;
    lineManager.lines._addLine(point, point + new Vector3(half_size, 0.0, 0.0));
    lineManager.lines._addLine(point, point + new Vector3(-half_size, 0.0, 0.0));
    lineManager.lines._addLine(point, point + new Vector3(0.0, half_size, 0.0));
    lineManager.lines._addLine(point, point + new Vector3(0.0, -half_size, 0.0));
    lineManager.lines._addLine(point, point + new Vector3(0.0, 0.0, half_size));
    lineManager.lines._addLine(point, point + new Vector3(0.0, 0.0, -half_size));
    lineManager.lines.finishLineObject();
  }

  /** Add a sphere primitive at [center] with [radius]. Filled with [color].
   *
   * Optional paremeters: [duration] and [depthEnabled].
   */
  void addSphere(Vector3 center, num radius, Vector4 color,
                 {num duration: 0.0, bool depthEnabled: true}) {
    var lineManager = depthEnabled ? _depthEnabledLines : _depthDisabledLines;
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
                                      duration);

    int latSegments = 6;
    int lonSegments = 8;

    Vector3 lastVertex, vertex, upperVertex;

    for (int y = 0; y < latSegments; ++y) {
      lastVertex = null;
      for (int x = 0; x <= lonSegments; ++x) {
        num u = x / lonSegments;
        num v = y / latSegments;
        num v2 = (y+1) / latSegments;

        vertex = new Vector3(
            radius * Math.cos(u * TWO_PI) * Math.sin(v * Math.PI),
            radius * Math.cos(v * Math.PI),
            radius * Math.sin(u * TWO_PI) * Math.sin(v * Math.PI)
        ) + center;

        upperVertex = new Vector3(
            radius * Math.cos(u * TWO_PI) * Math.sin(v2 * Math.PI),
            radius * Math.cos(v2 * Math.PI),
            radius * Math.sin(u * TWO_PI) * Math.sin(v2 * Math.PI)
        ) + center;

        if(lastVertex != null) {
          lineManager.lines._addLineRaw(
              lastVertex.x, lastVertex.y, lastVertex.z,
              vertex.x, vertex.y, vertex.z);
          lineManager.lines._addLineRaw(
              upperVertex.x, upperVertex.y, upperVertex.z,
              vertex.x, vertex.y, vertex.z);
        }

        lastVertex = vertex;
      }
    }
    lineManager.lines.finishLineObject();
  }

  final Vector3 _circle_u = new Vector3.zero();
  final Vector3 _circle_v = new Vector3.zero();

  /// Add a plane primitive whose normal is [normal] at is located at
  /// [center]. The plane is drawn as a grid of [size] square. Drawn
  /// with [color].
  /// Optional parameters: [duration], [depthEnabled] and [numSegments].
  void addPlane(Vector3 normal, Vector3 center, double size,
                Vector4 color, {num duration: 0.0, bool depthEnabled: true,
                int numSegments: 16}) {
    var lineManager = depthEnabled ? _depthEnabledLines : _depthDisabledLines;
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
                                      duration);

    buildPlaneVectors(normal, _circle_u, _circle_v);
    _circle_u.normalize();
    _circle_v.normalize();

    double halfSize = size * 0.5;

    Vector3 start = center - (_circle_u + _circle_v) * halfSize;
    Vector3 end = _circle_v * size;
    for (int i = 0; i <= numSegments; i++) {
      double param = i / numSegments;
      var x = start + (_circle_u * param * size);
      lineManager.lines._addLine(x, x + end);
    }

    end = _circle_u * size;
    for (int j = 0; j <= numSegments; j++) {
      double param = j / numSegments;
      var x = start + (_circle_v * param * size);
      lineManager.lines._addLine(x, x + end);
    }

    lineManager.lines.finishLineObject();
  }

  /** Add a cone primitive at [apex] with [height] and [angle]. Filled with
   *  [color].
   *
   * Optional parameters: [duration], [depthEnabled] and [numSegments].
   */
  void addCone(Vector3 apex, Vector3 direction, num height, num angle,
               Vector4 color, {num duration: 0.0, bool depthEnabled: true,
               int numSegments: 16}) {
    var lineManager = depthEnabled ? _depthEnabledLines : _depthDisabledLines;
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
                                      duration);

    var center = apex.clone().add(direction.normalized().scale(height));
    num s = height / Math.cos(angle / 2.0);
    num radius = Math.sqrt(s * s - height * height);


    buildPlaneVectors(direction.scaled(-1.0), _circle_u, _circle_v);
    _circle_u.normalize();
    _circle_v.normalize();

    num alpha = 0.0;
    num _step = TWO_PI/numSegments;

    double lastX = center.x + _circle_u.x * radius;
    double lastY = center.y + _circle_u.y * radius;
    double lastZ = center.z + _circle_u.z * radius;

    for (alpha = 0.0; alpha <= TWO_PI; alpha += _step) {
      double cosScale = Math.cos(alpha) * radius;
      double sinScale = Math.sin(alpha) * radius;
      double pX = center.x + cosScale * _circle_u.x + sinScale * _circle_v.x;
      double pY = center.y + cosScale * _circle_u.y + sinScale * _circle_v.y;
      double pZ = center.z + cosScale * _circle_u.z + sinScale * _circle_v.z;
      lineManager.lines._addLineRaw(lastX, lastY, lastZ, pX, pY, pZ);

      lineManager.lines._addLineRaw(
          apex.x, apex.y, apex.z,
          lastX, lastY, lastZ);
      lastX = pX;
      lastY = pY;
      lastZ = pZ;
    }

    lineManager.lines._addLineRaw(lastX, lastY, lastZ,
        center.x + _circle_u.x * radius,
        center.y + _circle_u.y * radius,
        center.z + _circle_u.z * radius);

    lineManager.lines.finishLineObject();
  }

  /** Add an arc primitive at [center] in the plane whose normal is
   * [planeNormal] with a [radius]. The arc begins at [startAngle] and extends
   * to [stopAngle]. Filled with [color].
   *
   * Optional parameters: [duration], [depthEnabled], and [numSegments].
   */
  void addArc(Vector3 center, Vector3 planeNormal, num radius, num startAngle,
              num stopAngle, Vector4 color, {num duration: 0.0,
              bool depthEnabled: true, int numSegments: 16}) {
    var lineManager = depthEnabled ? _depthEnabledLines : _depthDisabledLines;
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
                                      duration);

    buildPlaneVectors(planeNormal, _circle_u, _circle_v);
    _circle_u.normalize();
    _circle_v.normalize();
    num alpha = 0.0;
    num _step = TWO_PI/numSegments;

    alpha = startAngle;
    double cosScale = Math.cos(alpha) * radius;
    double sinScale = Math.sin(alpha) * radius;
    double lastX = center.x + cosScale * _circle_u.x + sinScale * _circle_v.x;
    double lastY = center.y + cosScale * _circle_u.y + sinScale * _circle_v.y;
    double lastZ = center.z + cosScale * _circle_u.z + sinScale * _circle_v.z;

    for (alpha = startAngle; alpha <= stopAngle+_step; alpha += _step) {
      cosScale = Math.cos(alpha) * radius;
      sinScale = Math.sin(alpha) * radius;
      double pX = center.x + cosScale * _circle_u.x + sinScale * _circle_v.x;
      double pY = center.y + cosScale * _circle_u.y + sinScale * _circle_v.y;
      double pZ = center.z + cosScale * _circle_u.z + sinScale * _circle_v.z;
      lineManager.lines._addLineRaw(lastX, lastY, lastZ, pX, pY, pZ);
      lastX = pX;
      lastY = pY;
      lastZ = pZ;
    }
    lineManager.lines.finishLineObject();
  }

  /** Add an circle primitive at [center] in the plane whose normal is
   * [planeNormal] with a [radius]. Filled with [color].
   *
   * Optional parameters: [duration], [depthEnabled], and [numSegments].
   */
  void addCircle(Vector3 center, Vector3 planeNormal, num radius, Vector4 color,
                 {num duration: 0.0, bool depthEnabled: true,
                 int numSegments: 16}) {
    var lineManager = depthEnabled ? _depthEnabledLines : _depthDisabledLines;
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
                                      duration);

    buildPlaneVectors(planeNormal, _circle_u, _circle_v);
    _circle_u.normalize();
    _circle_v.normalize();
    num alpha = 0.0;
    num _step = TWO_PI/numSegments;

    double lastX = center.x + _circle_u.x * radius;
    double lastY = center.y + _circle_u.y * radius;
    double lastZ = center.z + _circle_u.z * radius;

    for (alpha = 0.0; alpha <= TWO_PI; alpha += _step) {
      double cosScale = Math.cos(alpha) * radius;
      double sinScale = Math.sin(alpha) * radius;
      double pX = center.x + cosScale * _circle_u.x + sinScale * _circle_v.x;
      double pY = center.y + cosScale * _circle_u.y + sinScale * _circle_v.y;
      double pZ = center.z + cosScale * _circle_u.z + sinScale * _circle_v.z;
      lineManager.lines._addLineRaw(lastX, lastY, lastZ, pX, pY, pZ);
      lastX = pX;
      lastY = pY;
      lastZ = pZ;
    }
    lineManager.lines._addLineRaw(lastX, lastY, lastZ,
                                  center.x + _circle_u.x * radius,
                                  center.y + _circle_u.y * radius,
                                  center.z + _circle_u.z * radius);
    lineManager.lines.finishLineObject();
  }

  /// Add a coordinate system primitive. Derived from [xform]. Scaled by [size].
  ///
  /// X,Y, and Z axes are colored Red,Green, and Blue
  ///
  /// Optional paremeters: [duration], and [depthEnabled]
  void addAxes(Matrix4 xform, num size,
               {num duration: 0.0, bool depthEnabled: true}) {
    var lineManager = depthEnabled ? _depthEnabledLines : _depthDisabledLines;

    Vector4 origin = new Vector4(0.0, 0.0, 0.0, 1.0);
    num size_90p = 0.9 * size;
    num size_10p = 0.1 * size;

    Vector4 color;

    Vector4 X = new Vector4(size, 0.0, 0.0, 1.0);
    Vector4 X_head_0 = new Vector4(size_90p, size_10p, 0.0, 1.0);
    Vector4 X_head_1 = new Vector4(size_90p, -size_10p, 0.0, 1.0);
    Vector4 X_head_2 = new Vector4(size_90p, 0.0, size_10p, 1.0);
    Vector4 X_head_3 = new Vector4(size_90p, 0.0, -size_10p, 1.0);

    Vector4 Y = new Vector4(0.0, size, 0.0, 1.0);
    Vector4 Y_head_0 = new Vector4(size_10p, size_90p, 0.0, 1.0);
    Vector4 Y_head_1 = new Vector4(-size_10p, size_90p, 0.0, 1.0);
    Vector4 Y_head_2 = new Vector4(0.0, size_90p, size_10p, 1.0);
    Vector4 Y_head_3 = new Vector4(0.0, size_90p, -size_10p, 1.0);


    Vector4 Z = new Vector4(0.0, 0.0, size, 1.0);
    Vector4 Z_head_0 = new Vector4(size_10p, 0.0, size_90p, 1.0);
    Vector4 Z_head_1 = new Vector4(-size_10p, 0.0, size_90p, 1.0);
    Vector4 Z_head_2 = new Vector4(0.0, size_10p, size_90p, 1.0);
    Vector4 Z_head_3 = new Vector4(0.0, -size_10p, size_90p, 1.0);

    origin = xform * origin;

    X = xform * X;
    X_head_0 = xform * X_head_0;
    X_head_1 = xform * X_head_1;
    X_head_2 = xform * X_head_2;
    X_head_3 = xform * X_head_3;

    color = new Vector4(1.0, 0.0, 0.0, 1.0);
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
        duration);
    lineManager.lines._addLine(origin.xyz, X.xyz);
    lineManager.lines._addLine(X.xyz, X_head_0.xyz);
    lineManager.lines._addLine(X.xyz, X_head_1.xyz);
    lineManager.lines._addLine(X.xyz, X_head_2.xyz);
    lineManager.lines._addLine(X.xyz, X_head_3.xyz);
    lineManager.lines.finishLineObject();

    Y = xform * Y;
    Y_head_0 = xform * Y_head_0;
    Y_head_1 = xform * Y_head_1;
    Y_head_2 = xform * Y_head_2;
    Y_head_3 = xform * Y_head_3;

    color = new Vector4(0.0, 1.0, 0.0, 1.0);
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
        duration);
    lineManager.lines._addLine(origin.xyz, Y.xyz);
    lineManager.lines._addLine(Y.xyz, Y_head_0.xyz);
    lineManager.lines._addLine(Y.xyz, Y_head_1.xyz);
    lineManager.lines._addLine(Y.xyz, Y_head_2.xyz);
    lineManager.lines._addLine(Y.xyz, Y_head_3.xyz);
    lineManager.lines.finishLineObject();

    Z = xform * Z;
    Z_head_0 = xform * Z_head_0;
    Z_head_1 = xform * Z_head_1;
    Z_head_2 = xform * Z_head_2;
    Z_head_3 = xform * Z_head_3;

    color = new Vector4(0.0, 0.0, 1.0, 1.0);
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
        duration);
    lineManager.lines._addLine(origin.xyz, Z.xyz);
    lineManager.lines._addLine(Z.xyz, Z_head_0.xyz);
    lineManager.lines._addLine(Z.xyz, Z_head_1.xyz);
    lineManager.lines._addLine(Z.xyz, Z_head_2.xyz);
    lineManager.lines._addLine(Z.xyz, Z_head_3.xyz);
    lineManager.lines.finishLineObject();
  }

  /// Add a triangle primitives from vertices [vertex0], [vertex1],
  /// and [vertex2]. Filled with [color].
  ///
  /// Optional parameters: [duration] and [depthEnabled]
  void addTriangle(Vector3 vertex0, Vector3 vertex1, Vector3 vertex2, Vector4 color,
                   {num duration: 0.0, bool depthEnabled: true}) {
    var lineManager = depthEnabled ? _depthEnabledLines : _depthDisabledLines;
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
                                      duration);
    lineManager.lines._addLine(vertex0, vertex1);
    lineManager.lines._addLine(vertex1, vertex2);
    lineManager.lines._addLine(vertex2, vertex0);
    lineManager.lines.finishLineObject();
  }

  /// Add an Axis Aligned Bounding Box with corners at [boxMin] and [boxMax].
  /// Filled with [color].
  ///
  /// Option parameters: [duration] and [depthEnabled]
  void addAABB(Vector3 boxMin, Vector3 boxMax, Vector4 color,
               {num duration: 0.0, bool depthEnabled: true}) {
    Vector3 vertex_a;
    Vector3 vertex_b;

    var lineManager = depthEnabled ? _depthEnabledLines : _depthDisabledLines;
    lineManager.lines.startLineObject(color.r, color.g, color.b, color.a,
        duration);

    vertex_a = new Vector3.copy(boxMin);
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[0] = boxMax[0];
    lineManager.lines._addLine(vertex_a, vertex_b);
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[1] = boxMax[1];
    lineManager.lines._addLine(vertex_a, vertex_b);
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[2] = boxMax[2];
    lineManager.lines._addLine(vertex_a, vertex_b);
    vertex_a[1] = boxMax[1];
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[0] = boxMax[0];
    lineManager.lines._addLine(vertex_a, vertex_b);
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[2] = boxMax[2];
    lineManager.lines._addLine(vertex_a, vertex_b);
    vertex_a = new Vector3.copy(boxMin);
    vertex_a[0] = boxMax[0];
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[1] = boxMax[1];
    lineManager.lines._addLine(vertex_a, vertex_b);
    vertex_a = new Vector3.copy(boxMax);
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[0] = boxMin[0];
    lineManager.lines._addLine(vertex_a, vertex_b);
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[1] = boxMin[1];
    lineManager.lines._addLine(vertex_a, vertex_b);
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[2] = boxMin[2];
    lineManager.lines._addLine(vertex_a, vertex_b);
    vertex_a[1] = boxMin[1];
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[0] = boxMin[0];
    lineManager.lines._addLine(vertex_a, vertex_b);
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[2] = boxMin[2];
    lineManager.lines._addLine(vertex_a, vertex_b);
    vertex_a = new Vector3.copy(boxMin);
    vertex_a[2] = boxMax[2];
    vertex_b = new Vector3.copy(vertex_a);
    vertex_b[1] = boxMax[1];
    lineManager.lines._addLine(vertex_a, vertex_b);
    lineManager.lines.finishLineObject();
  }

  /// Prepare to render debug primitives
  void prepareForRender() {
    _depthEnabledLines._prepareForRender(device.context);
    _depthDisabledLines._prepareForRender(device.context);
  }

  /// Render debug primitives for [Camera] [cam]
  void render(Camera cam) {
    if(_depthEnabledLines._lineMesh.count == 0 && _depthDisabledLines._lineMesh.count == 0) {
      return;
    }

    Matrix4 pm = cam.projectionMatrix;
    Matrix4 la = cam.viewMatrix;
    pm.multiply(la);
    pm.copyIntoArray(_cameraMatrix);
    device.context.setShaderProgram(_lineShaderProgram);
    device.context.setConstant('cameraTransform', _cameraMatrix);
    device.context.setRasterizerState(_rasterizerState);
    device.context.setBlendState(_blendState);
    device.context.setInputLayout(_depthEnabledLines._lineMeshInputLayout);

    if(_depthEnabledLines._lineMesh.count != 0) {
      _depthState.depthBufferEnabled = true;
      _depthState.depthBufferWriteEnabled = true;
      device.context.setDepthState(_depthState);
      device.context.setMesh(_depthEnabledLines._lineMesh);
      device.context.drawMesh(_depthEnabledLines._lineMesh);
    }

    if(_depthDisabledLines._lineMesh.count != 0) {
      _depthState.depthBufferEnabled = false;
      _depthState.depthBufferWriteEnabled = false;
      device.context.setDepthState(_depthState);
      device.context.setMesh(_depthDisabledLines._lineMesh);
      device.context.drawMesh(_depthDisabledLines._lineMesh);
    }
  }

  /// Update time [seconds], removing any dead debug primitives
  void update(num seconds) {
    _depthEnabledLines.update(seconds);
    _depthDisabledLines.update(seconds);
  }
}

final String _debugLineVertexShader = '''
precision highp float;

// Input attributes
attribute vec3 vPosition;
attribute vec4 vColor;
// Input uniforms
uniform mat4 cameraTransform;
// Varying outputs
varying vec4 fColor;

void main() {
    fColor = vColor;
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    gl_Position = cameraTransform*vPosition4;
}
''';

final String _debugLineFragmentShader = '''
precision mediump float;

varying vec4 fColor;

void main() {
    gl_FragColor = fColor;
}
''';
