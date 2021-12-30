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

/// The [GraphicsContext] configures the GPU pipeline and executes draw
/// commands.
class GraphicsContext {
  final GraphicsDevice device;

  // Cached clear color
  double _clearR;
  double _clearG;
  double _clearB;
  double _clearA;

  // Cached clear depth
  double _clearD;

  // Cached texture state.
  int _tempTextureUnit;
  int _activeTextureUnit;
  List<SamplerState> _samplers;
  List<SpectreTexture> _textures;

  // Cached primitive topology.
  int _primitiveTopology;

  // Cached index buffer.
  IndexBuffer _indexBuffer;

  // VS and PS stages
  ShaderProgram _shaderProgram;

  RenderTarget _renderTarget;

  // TODO(johnmccutchan): Fix vertex input handling.
  List<VertexBuffer> _vertexBuffers;
  List<int> _enabledVertexAttributeArrays;
  InputLayout _inputLayoutHandle;
  InputLayout _preparedInputLayoutHandle;

  /// The default [BlendState] to use.
  /// Constructed with the values in [BlendState.opaque].
  BlendState _blendStateDefault;
  /// The default [DepthState] to use.
  /// Constructed with the values in [DepthState.depthWrite].
  DepthState _depthStateDefault;
  /// The default [RasterizerState] to use.
  /// Constructed with the values in [RasterizerState.cullClockwise].
  RasterizerState _rasterizerStateDefault;

  /// The current [Viewport] of the pipeline.
  Viewport _viewport;
  /// The current [BlendState] of the pipeline.
  BlendState _blendState;
  /// The current [DepthState] of the pipeline.
  DepthState _depthState;
  /// The current [RasterizerState] of the pipeline.
  RasterizerState _rasterizerState;

  GraphicsContext(this.device) {
    int numTextureUnits = device.capabilities.textureUnits;
    _tempTextureUnit = numTextureUnits - 1;
    _textures = new List<SpectreTexture>(numTextureUnits);
    _samplers = new List<SamplerState>(numTextureUnits);

    int numVertexBuffers = device.capabilities.maxVertexAttribs;
    _vertexBuffers = new List<VertexBuffer>(numVertexBuffers);
    _enabledVertexAttributeArrays = new List<int>();

    _initializeState();
    reset();
  }

  /// Initialize the WebGL pipeline state.
  /// Creates all the default state values and applies them to the pipeline.
  void _initializeState() {
    // Viewport setup
    _viewport = new Viewport();
    device.gl.viewport(_viewport.x, _viewport.y, _viewport.width,
                      _viewport.height);
    device.gl.depthRange(_viewport.minDepth, _viewport.maxDepth);
    // BlendState setup
    _blendStateDefault = new BlendState.opaque();
    _blendState = new BlendState.opaque();
    device.gl.disable(WebGL.BLEND);
    device.gl.blendFuncSeparate(_blendState.colorSourceBlend,
                                _blendState.colorDestinationBlend,
                                _blendState.alphaSourceBlend,
                                _blendState.alphaDestinationBlend);
    device.gl.blendEquationSeparate(_blendState.colorBlendOperation,
                                    _blendState.alphaBlendOperation);
    device.gl.colorMask(_blendState.writeRenderTargetRed,
                        _blendState.writeRenderTargetGreen,
                        _blendState.writeRenderTargetBlue,
                        _blendState.writeRenderTargetAlpha);
    device.gl.blendColor(_blendState.blendFactorRed,
                         _blendState.blendFactorGreen,
                         _blendState.blendFactorBlue,
                         _blendState.blendFactorAlpha);
    // DepthState setup
    _depthStateDefault = new DepthState.depthWrite();
    _depthState = new DepthState.depthWrite();
    device.gl.enable(WebGL.DEPTH_TEST);
    device.gl.depthMask(_depthState.depthBufferWriteEnabled);
    device.gl.depthFunc(_depthState.depthBufferFunction);
    // RasterizerState setup
    _rasterizerStateDefault = new RasterizerState.cullClockwise();
    _rasterizerState = new RasterizerState.cullClockwise();
    device.gl.enable(WebGL.CULL_FACE);
    device.gl.cullFace(_rasterizerState.cullMode);
    device.gl.frontFace(_rasterizerState.frontFace);
    device.gl.disable(WebGL.POLYGON_OFFSET_FILL);
    device.gl.polygonOffset(_rasterizerState.depthBias,
                            _rasterizerState.slopeScaleDepthBias);
    device.gl.disable(WebGL.SCISSOR_TEST);
  }

  void _prepareInputs({bool debug: false}) {
    if (_inputLayoutHandle == 0) {
      _spectreLog.shout('Prepare for draw no input layout');
      return;
    }

    InputLayout inputLayout = _inputLayoutHandle;
    if (inputLayout == null) {
      _spectreLog.shout('Prepare for draw no input layout.');
      return;
    }

    if (_preparedInputLayoutHandle == _inputLayoutHandle) {
      return;
    }

    _preparedInputLayoutHandle = _inputLayoutHandle;

    // Disable old arrays
    for (int index in _enabledVertexAttributeArrays) {
      if (index == 0) {
        continue;
      }
      device.gl.disableVertexAttribArray(index);
    }
    _enabledVertexAttributeArrays.clear();

    inputLayout.attributes.forEach((element) {
      VertexBuffer vb = _vertexBuffers[element.vboSlot];
      if (vb == null) {
        _spectreLog.shout('Prepare for draw referenced a null vertex buffer object');
        return;
      }
      device.gl.enableVertexAttribArray(element.attributeIndex);
      vb._bind();
      device.gl.vertexAttribPointer(element.attributeIndex,
        element.dataCount,
        element.dataType,
        element.normalizeData,
        element.attributeStride,
        element.attributeOffset);
      // Remember that this was enabled.
      _enabledVertexAttributeArrays.add(element.attributeIndex);
    });
  }

  void _prepareTextures() {
    for (int i = 0; i < _textures.length; i++) {
      SpectreTexture texture = _textures[i];
      SamplerState sampler = _samplers[i];
      if (texture == null) {
        continue;
      }
      if (sampler == null) {
        _spectreLog.shout('Texture $i has no sampler set.');
        continue;
      }
      setTexture(i, texture);
      setSampler(i, sampler);
    }
  }

  /// Resets the cached GPU pipeline state
  void reset() {
    setPrimitiveTopology(null);
    setIndexBuffer(null);
    setShaderProgram(null);
    for (int i = 0; i < _textures.length; i++) {
      setTexture(i, null);
      _samplers[i] = null;
    }
    _setActiveTextureUnit(0);
    setRenderTarget(null);

    for (int index in _enabledVertexAttributeArrays) {
      if (index == 0) {
        continue;
      }
      device.gl.disableVertexAttribArray(index);
    }
    _preparedInputLayoutHandle = null;
    _enabledVertexAttributeArrays.clear();
    for (int i = 0; i < _vertexBuffers.length; i++) {
      _vertexBuffers[i] = null;
    }
    _inputLayoutHandle = null;

    setBlendState(_blendStateDefault);
    setDepthState(_depthStateDefault);
    setRasterizerState(_rasterizerStateDefault);
  }

  /// Configure the primitive topology used when drawing.
  void setPrimitiveTopology(int topology) {
    _primitiveTopology = topology;
  }

  /// Set the IndexBuffer to [indexBuffer]
  void setIndexBuffer(IndexBuffer indexBuffer) {
    if (_indexBuffer != indexBuffer) {
      _indexBuffer = indexBuffer;
      if (indexBuffer != null) {
        device.gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER,
                             indexBuffer._deviceBuffer);
      } else {
        device.gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, null);
      }
    }
    _preparedInputLayoutHandle = null;
  }

  /// Set multiple VertexBuffers in [vertexBufferHandles] starting at
  /// [startSlot].
  void setVertexBuffers(int startSlot, List<VertexBuffer> vertexBufferHandles) {
    int limit = vertexBufferHandles.length + startSlot;
    for (int i = startSlot; i < limit; i++) {
      _vertexBuffers[i] = vertexBufferHandles[i-startSlot];
    }
	_preparedInputLayoutHandle = null;
  }

  /// Set InputLayout to [inputLayoutHandle]
  void setInputLayout(InputLayout inputLayoutHandle) {
    _inputLayoutHandle = inputLayoutHandle;
  }

  void setIndexedMesh(SingleArrayIndexedMesh indexedMesh) {
    if (indexedMesh == null) {
      return;
    }
    setPrimitiveTopology(indexedMesh.primitiveTopology);
    setIndexBuffer(indexedMesh.indexArray);
    setVertexBuffers(0, [indexedMesh.vertexArray]);
  }

  void setMesh(SingleArrayMesh mesh) {
    if (mesh == null) {
      return;
    }
    setPrimitiveTopology(mesh.primitiveTopology);
    setIndexBuffer(null);
    setVertexBuffers(0, [mesh.vertexArray]);
  }

  ShaderProgram get shaderProgram => _shaderProgram;

  /// Set ShaderProgram to [shaderProgram]
  ShaderProgram setShaderProgram(ShaderProgram shaderProgram) {
    var old = _shaderProgram;
    if (_shaderProgram != shaderProgram) {
      if (shaderProgram != null) {
        device.gl.useProgram(shaderProgram._program);
      } else {
        device.gl.useProgram(null);
      }
      _shaderProgram = shaderProgram;
    }
    return old;
  }

  /// Sets a [Viewport] identifying the portion of the render target to
  /// receive draw calls.
  void setViewport(Viewport viewport) {
    if (viewport == null) {
      return;
    }

    if ((_viewport.x      != viewport.x)     ||
        (_viewport.y      != viewport.y)     ||
        (_viewport.width  != viewport.width) ||
        (_viewport.height != viewport.height)) {
      device.gl.viewport(viewport.x, viewport.y,
                         viewport.width, viewport.height);
      _viewport.x      = viewport.x;
      _viewport.y      = viewport.y;
      _viewport.width  = viewport.width;
      _viewport.height = viewport.height;
    }

    if ((_viewport.minDepth != viewport.minDepth) ||
        (_viewport.maxDepth != viewport.maxDepth)) {
      device.gl.depthRange(viewport.minDepth, viewport.maxDepth);
      _viewport.minDepth = viewport.minDepth;
      _viewport.maxDepth = viewport.maxDepth;
    }
  }

  /// Sets the current [BlendState] to use on the pipeline.
  ///
  /// If [blendState] is null all values of the pipeline associated with
  /// blending will be reset to their defaults.
  void setBlendState(BlendState blendState) {
    if (blendState == null) {
      setBlendState(_blendStateDefault);
      return;
    }

    // Disable/Enable blending if necessary
    if (_blendState.enabled != blendState.enabled) {
      if (blendState.enabled) {
        device.gl.enable(WebGL.BLEND);
      } else {
        device.gl.disable(WebGL.BLEND);
      }

      _blendState.enabled = blendState.enabled;
    }

    // Modify the color write channels if necessary
    if ((_blendState.writeRenderTargetRed !=
         blendState.writeRenderTargetRed) ||
        (_blendState.writeRenderTargetGreen !=
         blendState.writeRenderTargetGreen) ||
        (_blendState.writeRenderTargetBlue  !=
         blendState.writeRenderTargetBlue)  ||
        (_blendState.writeRenderTargetAlpha !=
         blendState.writeRenderTargetAlpha)) {
      device.gl.colorMask(
        blendState.writeRenderTargetRed,
        blendState.writeRenderTargetGreen,
        blendState.writeRenderTargetBlue,
        blendState.writeRenderTargetAlpha
      );

      _blendState.writeRenderTargetRed   = blendState.writeRenderTargetRed;
      _blendState.writeRenderTargetGreen = blendState.writeRenderTargetGreen;
      _blendState.writeRenderTargetBlue  = blendState.writeRenderTargetBlue;
      _blendState.writeRenderTargetAlpha = blendState.writeRenderTargetAlpha;
    }

    // If blending is enabled enable all the functionality
    if (_blendState.enabled) {
      // Modify the blend functions if necessary
      if ((_blendState.colorSourceBlend !=
           blendState.colorSourceBlend) ||
          (_blendState.colorDestinationBlend !=
           blendState.colorDestinationBlend) ||
          (_blendState.alphaSourceBlend !=
           blendState.alphaSourceBlend) ||
          (_blendState.alphaDestinationBlend !=
           blendState.alphaDestinationBlend)) {
        device.gl.blendFuncSeparate(
          blendState.colorSourceBlend,
          blendState.colorDestinationBlend,
          blendState.alphaSourceBlend,
          blendState.alphaDestinationBlend
        );

        _blendState.colorSourceBlend      = blendState.colorSourceBlend;
        _blendState.colorDestinationBlend = blendState.colorDestinationBlend;
        _blendState.alphaSourceBlend      = blendState.alphaSourceBlend;
        _blendState.alphaDestinationBlend = blendState.alphaDestinationBlend;
      }

      // Modify the blend operations if necessary
      if ((_blendState.colorBlendOperation != blendState.colorBlendOperation) ||
          (_blendState.alphaBlendOperation != blendState.alphaBlendOperation))
      {
        device.gl.blendEquationSeparate(blendState.colorBlendOperation,
                                        blendState.alphaBlendOperation);
        _blendState.colorBlendOperation = blendState.colorBlendOperation;
        _blendState.alphaBlendOperation = blendState.alphaBlendOperation;
      }

      // Modify the blend factor if necessary
      if ((_blendState.blendFactorRed   != blendState.blendFactorRed)   ||
          (_blendState.blendFactorGreen != blendState.blendFactorGreen) ||
          (_blendState.blendFactorBlue  != blendState.blendFactorBlue)  ||
          (_blendState.blendFactorAlpha != blendState.blendFactorAlpha))
      {
        device.gl.blendColor(blendState.blendFactorRed,
                             blendState.blendFactorGreen,
                             blendState.blendFactorBlue,
                             blendState.blendFactorAlpha);
        _blendState.blendFactorRed   = blendState.blendFactorRed;
        _blendState.blendFactorGreen = blendState.blendFactorGreen;
        _blendState.blendFactorBlue  = blendState.blendFactorBlue;
        _blendState.blendFactorAlpha = blendState.blendFactorAlpha;
      }
    }
  }

  /// Sets the current [DepthState] to use on the pipeline.
  ///
  /// If [depthState] is null all values of the pipeline associated with depth
  /// will be reset to their defaults.
  void setDepthState(DepthState depthState) {
    if (depthState == null) {
      return;
    }

    if (_depthState.depthBufferEnabled != depthState.depthBufferEnabled) {
      if (depthState.depthBufferEnabled) {
        device.gl.enable(WebGL.DEPTH_TEST);
      } else {
        device.gl.disable(WebGL.DEPTH_TEST);
      }

      _depthState.depthBufferEnabled = depthState.depthBufferEnabled;
    }

    if ((_depthState.depthBufferEnabled) &&
        (_depthState.depthBufferFunction != depthState.depthBufferFunction)) {
      device.gl.depthFunc(depthState.depthBufferFunction);
      _depthState.depthBufferFunction = depthState.depthBufferFunction;
    }

    if (_depthState.depthBufferWriteEnabled !=
        depthState.depthBufferWriteEnabled) {
      device.gl.depthMask(depthState.depthBufferWriteEnabled);
      _depthState.depthBufferWriteEnabled = depthState.depthBufferWriteEnabled;
    }
  }

  /// Sets the current [RasterizerState] to use on the pipeline.
  ///
  /// If [rasterizerState] is null all values of the pipeline associated with
  /// rasterization will be reset to their defaults.
  void setRasterizerState(RasterizerState rasterizerState) {
    if (rasterizerState == null) {
      setRasterizerState(_rasterizerStateDefault);
      return;
    }

    // Disable/Enable culling if necessary
    if (_rasterizerState.cullMode != rasterizerState.cullMode) {
      if (rasterizerState.cullMode == CullMode.None) {
        device.gl.disable(WebGL.CULL_FACE);

        _rasterizerState.cullMode = rasterizerState.cullMode;
      } else if (_rasterizerState.cullMode == CullMode.None) {
        device.gl.enable(WebGL.CULL_FACE);
      }
    }

    // If culling is enabled enable culling mode and winding order
    if (rasterizerState.cullMode != CullMode.None) {
      // Modify the cull mode if necessary
      if (_rasterizerState.cullMode != rasterizerState.cullMode) {
        device.gl.cullFace(rasterizerState.cullMode);

        _rasterizerState.cullMode = rasterizerState.cullMode;
      }

      // Modify the front face if necessary
      if (_rasterizerState.frontFace != rasterizerState.frontFace) {
        device.gl.frontFace(rasterizerState.frontFace);

        _rasterizerState.frontFace = rasterizerState.frontFace;
      }
    }

    bool offsetEnabled = ((_rasterizerState.depthBias != 0.0) ||
                         (_rasterizerState.slopeScaleDepthBias != 0.0));

    if ((rasterizerState.depthBias != 0.0) ||
        (rasterizerState.slopeScaleDepthBias != 0)) {
      // Enable polygon offset
      if (!offsetEnabled) {
        device.gl.enable(WebGL.POLYGON_OFFSET_FILL);
      }
      // Modify the polygon offset if necessary
      if ((_rasterizerState.depthBias != rasterizerState.depthBias) ||
          (_rasterizerState.slopeScaleDepthBias !=
           rasterizerState.slopeScaleDepthBias))
      {
        device.gl.polygonOffset(rasterizerState.depthBias,
                                rasterizerState.slopeScaleDepthBias);
        _rasterizerState.depthBias = rasterizerState.depthBias;
        _rasterizerState.slopeScaleDepthBias =
            rasterizerState.slopeScaleDepthBias;
      }
    } else {
      // Disable polygon offset
      if (offsetEnabled) {
        device.gl.disable(WebGL.POLYGON_OFFSET_FILL);
        _rasterizerState.depthBias = rasterizerState.depthBias;
        _rasterizerState.slopeScaleDepthBias =
            rasterizerState.slopeScaleDepthBias;
      }
    }

    // Disable/Enable scissor test if necessary
    if (_rasterizerState.scissorTestEnabled !=
        rasterizerState.scissorTestEnabled) {
      if (rasterizerState.scissorTestEnabled) {
        device.gl.enable(WebGL.SCISSOR_TEST);
      } else {
        device.gl.disable(WebGL.SCISSOR_TEST);
      }
      _rasterizerState.scissorTestEnabled = rasterizerState.scissorTestEnabled;
    }
  }

  /// Set RenderTarget to [renderTarget]. Returns previously set RenderTarget.
  RenderTarget setRenderTarget(RenderTarget renderTarget) {
    var old = _renderTarget;
    if (_renderTarget != renderTarget) {
      if (renderTarget != null) {
        device.gl.bindFramebuffer(WebGL.FRAMEBUFFER,
                                  renderTarget._deviceFramebuffer);
      } else {
        device.gl.bindFramebuffer(WebGL.FRAMEBUFFER, null);
      }
      _renderTarget = renderTarget;
    }
    return old;
  }

  ShaderProgramUniform _findUniform(String name) {
    ShaderProgram sp = _shaderProgram;
    if (sp == null) {
      return null;
    }
    return sp.uniforms[name];
  }

  void setConstant(String name, var argument) {
    ShaderProgramUniform uniform = _findUniform(name);
    if (uniform != null) {
      uniform._apply(device, uniform.location, argument);
    } else if (_shaderProgram == null ){
      _spectreLog.shout('Cannot set $name: no ShaderProgram bound.');
    } else {
      //spectreLog.Error('Cannot set $name: not found.');
    }
  }

  /// Clear color buffer to ([r], [g], [b], [a]).
  void clearColorBuffer(double r, double g, double b, double a) {
    if ((r != _clearR) || (g != _clearG) || (b != _clearB) || (a != _clearA)) {
      device.gl.clearColor(r, g, b, a);
      _clearR = r;
      _clearG = g;
      _clearB = b;
      _clearA = a;
    }
    device.gl.clear(WebGL.COLOR_BUFFER_BIT);
  }

  // Clear depth buffer to [depth].
  void clearDepthBuffer(double depth) {
    if (depth != _clearD) {
      device.gl.clearDepth(depth);
      _clearD = depth;
    }
    device.gl.clear(WebGL.DEPTH_BUFFER_BIT);
  }

  /// Clear color buffer to ([r], [g], [b], [a]) and clear the depth buffer
  /// to [d].
  void clearColorAndDepthBuffer(double r, double g, double b, double a,
                                double d) {
    clearColorBuffer(r, g, b, a);
    clearDepthBuffer(d);
  }

  void _setActiveTextureUnit(int textureUnit) {
    if (_activeTextureUnit != textureUnit) {
      device.gl.activeTexture(WebGL.TEXTURE0 + textureUnit);
      _activeTextureUnit = textureUnit;
    }
  }

  /// Set [textureUnit] to use [texture]. Returns the previously
  /// set texture.
  SpectreTexture setTexture(int textureUnit, SpectreTexture texture) {
    if (textureUnit < 0 || textureUnit >= _textures.length) {
      throw new ArgumentError('Invalid texture unit.');
    }
    SpectreTexture old = _textures[textureUnit];
    _setActiveTextureUnit(textureUnit);
    if (_textures[textureUnit] != texture) {
      // Clear all possible texture targets.
      device.gl.bindTexture(WebGL.TEXTURE_2D, null);
      device.gl.bindTexture(WebGL.TEXTURE_CUBE_MAP, null);
      if (texture != null) {
        device.gl.bindTexture(texture._bindTarget, texture._deviceTexture);
      }
      _textures[textureUnit] = texture;
    }
    return old;
  }

  /// Set [sampler] state on texture bound to [textureUnit].
  void setSampler(int textureUnit, SamplerState sampler) {
    if (textureUnit < 0 || textureUnit >= _textures.length) {
      throw new ArgumentError('Invalid texture unit.');
    }
    _setActiveTextureUnit(textureUnit);
    SpectreTexture texture = _textures[textureUnit];
    _samplers[textureUnit] = sampler;

    if (texture == null) {
      // No texture bound.
      return;
    }

    int textureWrapS = TextureAddressMode.Default;
    int textureWrapT = TextureAddressMode.Default;
    int textureMinFilter = TextureMinFilter.Default;
    int textureMagFilter = TextureMagFilter.Default;

    if (sampler != null) {
      textureWrapS = sampler.addressU;
      textureWrapT = sampler.addressV;
      textureMinFilter = sampler.minFilter;
      textureMagFilter = sampler.magFilter;
    }

    if (texture._textureWrapS != textureWrapS) {
      device.gl.texParameteri(texture._textureTarget, WebGL.TEXTURE_WRAP_S,
                              textureWrapS);
      texture._textureWrapS = textureWrapS;
    }
    if (texture._textureWrapT != textureWrapT) {
      device.gl.texParameteri(texture._textureTarget, WebGL.TEXTURE_WRAP_T,
                              textureWrapT);
      texture._textureWrapT = textureWrapT;
    }
    if (texture._textureMinFilter != textureMinFilter) {
      device.gl.texParameteri(texture._textureTarget, WebGL.TEXTURE_MIN_FILTER,
                              textureMinFilter);
      texture._textureMinFilter = textureMinFilter;
    }
    if (texture._textureMagFilter != textureMagFilter) {
      device.gl.texParameteri(texture._textureTarget, WebGL.TEXTURE_MAG_FILTER,
                              textureMagFilter);
      texture._textureMagFilter = textureMagFilter;
    }
  }

  /// Sets a list of [textures] starting at [texUnitOffset]
  void setTextures(int texUnitOffset, List<SpectreTexture> textures) {
    for (int i = 0; i < textures.length; i++) {
      setTexture(i + texUnitOffset, textures[i]);
    }
  }

  /// Sets a list of [samplers] starting at [texUnitOffset]
  void setSamplers(int texUnitOffset, List<SamplerState> samplers) {
    for (int i = 0; i < samplers.length; i++) {
      setSampler(i + texUnitOffset, samplers[i]);
    }
  }

  void _preDraw() {
    _prepareInputs();
    _prepareTextures();
    if (device.capabilities.hasMultipleRenderTargets) {
      if ((_renderTarget != null) &&
          (_renderTarget != RenderTarget.systemRenderTarget)) {
        device.capabilities._multipleRenderTargets.drawBuffersWebgl(
            _renderTarget._drawBuffers);
      }
    }
  }

  /// Draw an indexed mesh with [numIndices] starting at [indexOffset]
  void drawIndexed(int numIndices, int indexOffset) {
    if (numIndices == 0) {
      return;
    }
    _preDraw();
    device.gl.drawElements(_primitiveTopology, numIndices,
                           WebGL.UNSIGNED_SHORT, indexOffset);
  }

  void drawIndexedMesh(SingleArrayIndexedMesh indexedMesh) {
    if (indexedMesh == null) {
      return;
    }
    drawIndexed(indexedMesh.count, 0);
  }

  void drawMesh(SingleArrayMesh mesh) {
    if (mesh == null) {
      return;
    }
    draw(mesh.count, 0);
  }

  /// Draw a mesh with [numVertices] starting at [vertexOffset]
  void draw(int numVertices, int vertexOffset) {
    if (numVertices == 0) {
      return;
    }
    _preDraw();
    device.gl.drawArrays(_primitiveTopology, vertexOffset, numVertices);
  }
}
