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

/** A [RenderTarget] specifies the buffers where color, depth, and stencil
 * are written to during a draw call.
 *
 * NOTE: To output into the system provided render target see
 * [RenderTarget.systemRenderTarget]
 */
class RenderTarget extends DeviceChild {
  final int _bindTarget = WebGL.FRAMEBUFFER;
  final int _bindingParam = WebGL.FRAMEBUFFER_BINDING;
  final List<DeviceChild> _colorTargets;
  final List<int> _drawBuffers;
  WebGL.Framebuffer _deviceFramebuffer;

  DeviceChild _depthTarget;
  DeviceChild get depthTarget => _depthTarget;
  DeviceChild get stencilTarget => null;

  static RenderTarget _systemRenderTarget;
  /** System provided rendering target */
  static RenderTarget get systemRenderTarget => _systemRenderTarget;

  bool _renderable = false;
  /** Is the render target valid and renderable? */
  bool get isRenderable => _renderable;
  int _status;
  int get statusCode => _status;

  RenderTarget(String name, GraphicsDevice device)
      : _colorTargets =
            new List<DeviceChild>(device.capabilities.maxRenderTargets),
        _drawBuffers =
            new List<int>(device.capabilities.maxRenderTargets),
        super._internal(name, device) {
    _deviceFramebuffer = device.gl.createFramebuffer();
    for (int i = 0; i < _drawBuffers.length; i++) {
      _drawBuffers[i] = WebGL.NONE;
    }
  }

  RenderTarget.systemTarget(String name, GraphicsDevice device)
      : _colorTargets =
            new List<DeviceChild>(0),
        _drawBuffers =
            new List<int>(0),
        super._internal(name, device) {
    _renderable = true;
  }

  void finalize() {
    super.finalize();
    device.gl.deleteFramebuffer(_deviceFramebuffer);
    _deviceFramebuffer = null;
    _renderable = false;
  }

  void _updateStatus() {
    _status = device.gl.checkFramebufferStatus(_bindTarget);
    _renderable = _status == WebGL.FRAMEBUFFER_COMPLETE;
  }

  /// Set the [i]th color target to [colorBuffer].
  /// [colorBuffer] can be null, a [RenderBuffer] or a [Texture2D].
  /// An optional [mipLevel] can be specified for For [Texture2D] buffers.
  dynamic setColorTarget(int i, dynamic colorBuffer, [int mipLevel=0]) {
    if ((colorBuffer != null) &&
        (colorBuffer is! RenderBuffer) &&
        (colorBuffer is! Texture2D)) {
      throw new ArgumentError(
          'colorTarget must be a RenderBuffer or Texture2D.');
    }
    if (i < 0 || i >= _drawBuffers.length) {
      throw new ArgumentError('Invalid color target index. Index must be within'
                              '0 and ${_drawBuffers.length}}');
    }
    var r = _colorTargets[i];
    _colorTargets[i] = colorBuffer;
    if (colorBuffer == null) {
      _drawBuffers[i] = WebGL.NONE;
    } else {
      _drawBuffers[i] = WebGL.COLOR_ATTACHMENT0 + i;
    }
    var old = device.context.setRenderTarget(this);
    if (colorBuffer == null) {
      device.gl.framebufferRenderbuffer(_bindTarget,
                                        WebGL.COLOR_ATTACHMENT0 + i,
                                        WebGL.RENDERBUFFER,
                                        null);
    } else if (colorBuffer is RenderBuffer) {
      device.gl.framebufferRenderbuffer(_bindTarget,
                                        WebGL.COLOR_ATTACHMENT0 + i,
                                        WebGL.RENDERBUFFER,
                                        colorBuffer._buffer);
    } else if (colorBuffer is Texture2D) {
      device.gl.framebufferTexture2D(_bindTarget,
                                     WebGL.COLOR_ATTACHMENT0 + i,
                                     colorBuffer._textureTarget,
                                     colorBuffer._deviceTexture, mipLevel);
    }
    _updateStatus();
    device.context.setRenderTarget(old);
    return r;
  }

  /// Set the depth target to [depthBuffer].
  /// [depthBuffer] can be null, a [RenderBuffer] or a [Texture2D].
  /// An optional [mipLevel] can be specified for For [Texture2D] buffers.
  dynamic setDepthTarget(dynamic depthBuffer, [int mipLevel=0]) {
    if (depthBuffer != null &&
        (depthBuffer is! RenderBuffer) &&
        (depthBuffer is! Texture2D)) {
      throw new ArgumentError(
      'depthTarget must be a RenderBuffer or Texture2D.');
    }
    var r = _depthTarget;
    _depthTarget = depthBuffer;
    var old = device.context.setRenderTarget(this);
    if (depthBuffer == null) {
      device.gl.framebufferRenderbuffer(_bindTarget,
                                        WebGL.DEPTH_ATTACHMENT,
                                        WebGL.RENDERBUFFER,
                                        null);
    } else if (depthBuffer is RenderBuffer) {
      device.gl.framebufferRenderbuffer(_bindTarget,
                                        WebGL.DEPTH_ATTACHMENT,
                                        WebGL.RENDERBUFFER,
                                        depthBuffer._buffer);
    } else if (depthBuffer is Texture2D) {
      device.gl.framebufferTexture2D(_bindTarget,
                                     WebGL.DEPTH_ATTACHMENT,
                                     depthBuffer._textureTarget,
                                     depthBuffer._deviceTexture, mipLevel);
    }
    _updateStatus();
    device.context.setRenderTarget(old);
    return r;
  }
}
