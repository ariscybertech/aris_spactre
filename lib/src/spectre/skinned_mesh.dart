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

class Float32ListHelpers {
  static void addScale44(out, input, scale) {
    out[0] += input[0] * scale;
    out[1] += input[1] * scale;
    out[2] += input[2] * scale;
    out[3] += input[3] * scale;
    out[4] += input[4] * scale;
    out[5] += input[5] * scale;
    out[6] += input[6] * scale;
    out[7] += input[7] * scale;
    out[8] += input[8] * scale;
    out[9] += input[9] * scale;
    out[10] += input[10] * scale;
    out[11] += input[11] * scale;
    out[12] += input[12] * scale;
    out[13] += input[13] * scale;
    out[14] += input[14] * scale;
    out[15] += input[15] * scale;
  }
}


class Animation {
  final String name;
  final List<BoneAnimation> _boneData;
  Animation(this.name, final int length) :
      _boneData = new List<BoneAnimation>(length) {
  }
  BoneAnimation getDataForBone(int boneIndex) {
    if (boneIndex >= _boneData.length) {
      return null;
    }
    return _boneData[boneIndex];
  }
  double _runTime = 0.0;
  double get runTime => _runTime;
  double _timeScale = 1.0/24.0;
  double get timeScale => _timeScale;
}

class SkinnedMesh extends SpectreMesh {
  VertexBuffer _deviceVertexBuffer;
  IndexBuffer _deviceIndexBuffer;
  IndexBuffer get indexArray => _deviceIndexBuffer;
  VertexBuffer get vertexArray => _deviceVertexBuffer;
  final List<Map> meshes = new List<Map>();

  SkinnedMesh(String name, GraphicsDevice device) :
      super(name, device) {
    _deviceVertexBuffer = new VertexBuffer(name, device);
    _deviceIndexBuffer = new IndexBuffer(name, device);
    _deviceSkinningBuffer = new VertexBuffer('${name}_skinning', device);
    animations['null'] = new SkeletonAnimation('null', 0);
    currentAnimation = 'null';
  }

  void finalize() {
    _deviceVertexBuffer.dispose();
    _deviceIndexBuffer.dispose();
    _deviceSkinningBuffer.dispose();
    _deviceVertexBuffer = null;
    _deviceIndexBuffer = null;
    _deviceSkinningBuffer = null;
    count = 0;
  }

  Float32List baseVertexData; // The unanimated reference data.
  Float32List vertexData; // The animated vertex data.
  Float32x4List baseVertexData4;
  Float32x4List vertexData4;
  int _floatsPerVertex;
  final Float32List globalInverseTransform = new Float32List(16);

  // These are indexed together
  Float32List weightData;
  Int32List boneData;
  Float32List skinningData;

  VertexBuffer _deviceSkinningBuffer;
  VertexBuffer get skinningArray => _deviceSkinningBuffer;

  Skeleton skeleton;

  // current time.
  double _currentTime = 0.0;

  final Map<String, SkeletonAnimation> animations =
      new Map<String,SkeletonAnimation>();
  SkeletonAnimation _currentAnimation;
  String get currentAnimation => _currentAnimation.name;
  set currentAnimation(String name) {
    _currentAnimation = animations[name];
  }

  SkeletonPoser skeletonPoser = new SimpleSkeletonPoser();
  SkeletonPoser skeletonPoserSIMD = new SIMDSkeletonPoser();

  void skin(PosedSkeleton pose, bool useSimdSkinning) {
    if (useSimdSkinning) {
      _updateVerticesSIMD(pose);
    } else {
      _updateVertices(pose);
    }
  }

  final Stopwatch sw = new Stopwatch();

  final Float32List m = new Float32List(16);
  final Float32List vertex = new Float32List(12);
  // Transform baseVertexData into vertexData based on bone hierarchy.
  void _updateVertices(PosedSkeleton pose) {
    int numVertices = baseVertexData.length~/_floatsPerVertex;
    int vertexBase = 0;
    sw.reset();
    sw.start();
    for (int v = 0; v < numVertices; v++) {
      // Zero vertices.
      vertex[0] = 0.0;
      vertex[1] = 0.0;
      vertex[2] = 0.0;
      vertex[3] = 0.0;
      for (int i = 4; i < _floatsPerVertex; i++) {
        vertexData[i] = baseVertexData[vertexBase+i];
      }
      int skinningDataOffset = v*4;
      Matrix44Operations.zero(m, 0);
      for (int i = 0; i < 4; ++i) {
        final int boneId = boneData[skinningDataOffset];
        final double weight = weightData[skinningDataOffset];
        Float32ListHelpers.addScale44(m, pose.skinningTransforms[boneId],
                                      weight);
        skinningDataOffset++;
      }
      Matrix44Operations.transform4(vertex, 0, m, 0, baseVertexData,
                                    vertexBase);
      for (int i = 0; i < 4; i++) {
        vertexData[vertexBase+i] = vertex[i];
      }
      vertexBase += _floatsPerVertex;
    }
    sw.stop();
    vertexArray.uploadSubData(0, vertexData);
  }

  // Transform baseVertexData into vertexData based on bone hierarchy.
  final Float32x4List m4 = new Float32x4List(4);
  final Float32x4List vertex4 = new Float32x4List(3);
  void _updateVerticesSIMD(PosedSkeleton pose) {
    int numVertices = baseVertexData.length~/_floatsPerVertex;
    int vertexBase = 0;
    sw.reset();
    sw.start();
    for (int v = 0; v < numVertices; v++) {
      vertexData4[1] = baseVertexData4[vertexBase+1];
      vertexData4[2] = baseVertexData4[vertexBase+2];
      int skinningDataOffset = v*4;
      Matrix44SIMDOperations.zero(m4, 0);
      for (int i = 0; i < 4; ++i) {
        final int boneId = boneData[skinningDataOffset];
        final double weight = weightData[skinningDataOffset];
        Float32x4 weight4 = new Float32x4.splat(weight);
        Float32x4List boneMatrix = pose.skinningTransforms4[boneId];
        m4[0] += boneMatrix[0] * weight4;
        m4[1] += boneMatrix[1] * weight4;
        m4[2] += boneMatrix[2] * weight4;
        m4[3] += boneMatrix[3] * weight4;
        skinningDataOffset++;
      }
      Matrix44SIMDOperations.transform4(vertex4, 0, m4, 0, baseVertexData4,
                                        vertexBase);
      vertexData4[vertexBase] = vertex4[0];
      vertexBase += _floatsPerVertex ~/ 4;
    }
    sw.stop();
    vertexArray.uploadSubData(0, vertexData);
  }

  // Set the vertices to the bind pose.
  // This resets a skinned mesh for GPU skinning
  void resetToBindPose() {
    int numVertices = baseVertexData.length~/_floatsPerVertex;
    int vertexBase = 0;
    for (int v = 0; v < numVertices; v++) {
      vertexData4[vertexBase] = baseVertexData4[vertexBase];
      vertexBase += _floatsPerVertex ~/ 4;
    }
    vertexArray.uploadSubData(0, vertexData);
  }
}

class SkinnedMeshInstance {
  SkinnedMesh mesh;
  PosedSkeleton posedSkeleton;

  // current time.
  double _currentTime = 0.0;
  double get currentTime => _currentTime;
  set currentTime(double value) {
    _currentTime = value;
    if (_currentAnimation == null || _currentAnimation.runTime == 0.0) {
      _currentTime = 0.0;
    } else {
      while (_currentTime >= _currentAnimation.runTime) {
        _currentTime -= _currentAnimation.runTime;
      }
    }
  }

  SkeletonAnimation _currentAnimation;
  String get currentAnimation => _currentAnimation.name;
  set currentAnimation(String name) {
    _currentAnimation = mesh.animations[name];
    currentTime = 0.0;
  }

  SkinnedMeshInstance(SkinnedMesh this.mesh) {
    posedSkeleton = new PosedSkeleton(mesh.skeleton);
    _currentAnimation = mesh._currentAnimation;
  }

  bool update(double dt, bool useSimd) {
    if(_currentAnimation == null)
      return false; // TODO: In this case the posedSkeleton should be set to all identity matricies

    double oldCurrentTime = currentTime;
    currentTime += dt * _currentAnimation.timeScale;

    if(useSimd) {
      mesh.skeletonPoserSIMD.pose(mesh.skeleton, _currentAnimation, posedSkeleton, _currentTime);
    } else {
      mesh.skeletonPoser.pose(mesh.skeleton, _currentAnimation, posedSkeleton, _currentTime);
    }

    return oldCurrentTime > currentTime;
  }

  void skin(bool useSimd) {
    mesh.skin(posedSkeleton, useSimd);
  }
}

void importMesh(SkinnedMesh mesh, Map json) {
  mesh.meshes.add(json);
}

void importAttribute(SkinnedMesh mesh, Map json) {
  String name = json['name'];
  int offset = json['offset'];
  int stride = json['stride'];
  mesh.attributes[name] = new SpectreMeshAttribute(
      name,
      new VertexAttribute(0, 0, offset, stride, DataType.Float32, 4, false));
}

void importAnimationFrames(SkeletonAnimation animation, int boneId, Map ba) {
  assert(boneId >= 0 && boneId < animation.boneList.length);
  assert(animation.boneList[boneId] == null);

  List positions = ba['positions'];
  List rotations = ba['rotations'];
  List scales = ba['scales'];

  BoneAnimation boneData = new BoneAnimation('', boneId, positions, rotations,
                                             scales);
  animation.boneList[boneId] = boneData;
}

void importAnimation(SkinnedMesh mesh, Map json) {
  String name = json['name'];
  assert(name != null);
  assert(name != "");
  num ticksPerSecond = json['ticksPerSecond'];
  num duration = json['duration'];
  assert(ticksPerSecond != null);
  assert(duration != null);
  var animation = new SkeletonAnimation(name, mesh.skeleton.boneList.length);
  animation.runTime = duration.toDouble();
  animation.timeScale = ticksPerSecond.toDouble();
  mesh.animations[name] = animation;
  mesh._currentAnimation = mesh.animations[name];
  json['boneAnimations'].forEach((ba) {
    Bone bone = mesh.skeleton.bones[ba['name']];
    if (bone == null) {
      _spectreLog.shout('Cannot find ${ba['name']}');
      return;
    }
    int id = bone._boneIndex;
    importAnimationFrames(animation, id, ba);
  });
}

class SkinnedVertex {
  final int vertexId;
  final List<int> bones = new List<int>();
  final List<double> weights = new List<double>();
  SkinnedVertex(this.vertexId);
}

SkinnedMesh importSkinnedMesh2(String name, GraphicsDevice device, Map json) {
  SkinnedMesh mesh = new SkinnedMesh(name, device);

  List attributes = json['attributes'];
  // static mesh data begins.
  attributes.forEach((a) {
    importAttribute(mesh, a);
  });
  mesh._floatsPerVertex = attributes[0]['stride']~/4;

  List vertices = json['vertices'];
  mesh.vertexData4 = new Float32x4List(json['vertices'].length~/4);
  mesh.baseVertexData4 = new Float32x4List(mesh.vertexData4.length);
  mesh.vertexData = new Float32List.view(mesh.vertexData4.buffer);
  mesh.baseVertexData = new Float32List.view(mesh.baseVertexData4.buffer);
  for (int i = 0; i < json['vertices'].length; i++) {
    mesh.vertexData[i] = json['vertices'][i].toDouble();
    mesh.baseVertexData[i] = json['vertices'][i].toDouble();
  }
  mesh.vertexArray.uploadData(mesh.vertexData4,
                              UsagePattern.DynamicDraw);
  List indices = json['indices'];
  mesh.indexArray.uploadData(new Uint16List.fromList(json['indices']),
                             UsagePattern.StaticDraw);
  List meshes = json['meshes'];
  meshes.forEach((m) {
    importMesh(mesh, m);
  });
  List bones = json['boneTable'];
  mesh.skeleton = new Skeleton(name, bones.length);
  // TODO: FIX THIS.
  mesh.skeleton.globalOffsetTransform[0] = 1.0;
  mesh.skeleton.globalOffsetTransform[6] = -1.0;
  mesh.skeleton.globalOffsetTransform[9] = 1.0;
  mesh.skeleton.globalOffsetTransform[15] = 1.0;
  // Bone table.
  bones.forEach((b) {
    String boneName = b['name'];
    List<double> transform = b['localTransform'];
    List<double> offsetTransform = b['offsetTransform'];
    int index = b['index'];
    assert(16 == transform.length);
    assert(16 == offsetTransform.length);
    Bone bone = new Bone(boneName, transform, offsetTransform);
    mesh.skeleton.boneList[index] = bone;
    mesh.skeleton.boneList[index]._boneIndex = index;
    mesh.skeleton.bones[boneName] = bone;
  });
  // Bone hierarchy.
  bones.forEach((b) {
    String boneName = b['name'];
    Bone parentBone = mesh.skeleton.bones[boneName];
    List<String> children = b['children'];
    for (int i = 0; i < children.length; i++) {
      Bone childBone = mesh.skeleton.bones[children[i]];
      if (childBone == null) {
        _spectreLog.shout('Could not find ${children[i]}');
        continue;
      }
      assert(childBone.parent == null);
      childBone.parent = parentBone;
      parentBone.children.add(childBone);
    }
  });

  {
    List boneId = json['vertexBones'];
    List weights = json['vertexWeights'];
    assert(boneId.length == weights.length);
    mesh.boneData = new Int32List(boneId.length);
    mesh.skinningData = new Float32List(boneId.length*2);
    Float32List floatBoneData = new Float32List.view(mesh.skinningData.buffer,
                                                     0,
                                                     boneId.length);
    mesh.weightData = new Float32List.view(mesh.skinningData.buffer,
                                           boneId.length*4);
    for (int i = 0; i < boneId.length; i++) {
      mesh.boneData[i] = boneId[i].toInt();
      mesh.weightData[i] = weights[i].toDouble();

      // This is unfortunate, but it's the only way GPU skinning will run fast
      // on most cards.
      floatBoneData[i] = boneId[i].toDouble();
    }

    // GPU-skinning specific attributes
    mesh.attributes['vBoneIndices'] = new SpectreMeshAttribute('vBoneIndices',
        new VertexAttribute(1, 0, 0, 16, DataType.Float32, 4, false));
    mesh.attributes['vBoneWeights'] = new SpectreMeshAttribute('vBoneWeights',
        new VertexAttribute(1, 0, boneId.length*4, 16, DataType.Float32, 4,
                            false));
    mesh.skinningArray.uploadData(mesh.skinningData, UsagePattern.StaticDraw);
  }
  return mesh;
}