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

library multiple_render_targets_main;

import 'dart:async';
import 'dart:html';

import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_example_ui.dart';

class MultipleRenderTargets extends Example {
  MultipleRenderTargets(CanvasElement element) : super('OffscreenRender',
                                                        element);
  Texture2D redColorBuffer;
  Texture2D greenColorBuffer;
  Texture2D blueColorBuffer;
  Texture2D alphaColorBuffer;
  Texture2D depthBuffer;
  RenderTarget renderTarget;
  OrbitCameraController cameraController;
  Model model;
  RasterizerState rasterizerState;
  DepthState depthState;
  Viewport offscreenViewport;

  Model fullscreenBlitModel;

  Future initialize() {
    return super.initialize().then((_) {
      if (!graphicsDevice.capabilities.hasDepthTextures) {
        throw new UnsupportedError('Computer does not support depth textures.');
      }
      int offscreenWidth = 1024;
      int offscreenHeight = 1024;
      offscreenViewport = new Viewport();
      offscreenViewport.width = offscreenWidth;
      offscreenViewport.height = offscreenHeight;
      // Create color buffers.
      redColorBuffer = new Texture2D('redColorBuffer', graphicsDevice);
      redColorBuffer.uploadPixelArray(offscreenWidth, offscreenHeight, null);
      greenColorBuffer = new Texture2D('greenColorBuffer', graphicsDevice);
      greenColorBuffer.uploadPixelArray(offscreenWidth, offscreenHeight, null);
      blueColorBuffer = new Texture2D('blueColorBuffer', graphicsDevice);
      blueColorBuffer.uploadPixelArray(offscreenWidth, offscreenHeight, null);
      alphaColorBuffer = new Texture2D('alphaColorBuffer', graphicsDevice);
      alphaColorBuffer.uploadPixelArray(offscreenWidth, offscreenHeight, null);
      // Create depth buffer.
      depthBuffer = new Texture2D('depthBuffer', graphicsDevice);
      depthBuffer.pixelFormat = PixelFormat.Depth;
      depthBuffer.pixelDataType = DataType.Uint32;
      depthBuffer.uploadPixelArray(offscreenWidth, offscreenHeight, null);
      // Create render target.
      renderTarget = new RenderTarget('renderTarget', graphicsDevice);
      // Use color buffer.
      renderTarget.setColorTarget(0, redColorBuffer);
      renderTarget.setColorTarget(1, greenColorBuffer);
      renderTarget.setColorTarget(2, blueColorBuffer);
      renderTarget.setColorTarget(3, alphaColorBuffer);
      // Use depth buffer.
      renderTarget.setDepthTarget(depthBuffer);
      // Verify that it's renderable.
      if (!renderTarget.isRenderable) {
        throw new UnsupportedError('Render target is not renderable: '
                                   '${renderTarget.statusCode}');
      }
      cameraController = new OrbitCameraController();
      // New model.
      model = new Model(assetManager['base.unitCube'],
                        assetManager['base.simpleMultipleRenderTargetsShader'],
                        graphicsDevice);
      rasterizerState = new RasterizerState();
      depthState = new DepthState();
      fullscreenBlitModel = new Model(fullscreenMesh,
                                      assetManager['base.blitMergeColorTexturesShader'],
                                      graphicsDevice);
    });
  }

  Future load() {
    return super.load().then((_) {
    });
  }

  double _radians = 0.1;
  onUpdate() {
    updateCameraController(cameraController);

    _radians += gameLoop.updateTimeStep * 3.14159;
  }

  onRender() {
    // Set the render target to be the offscreen buffer.
    graphicsContext.setRenderTarget(renderTarget);

    // Set the viewport (2D area of render target to render on to).
    graphicsContext.setViewport(offscreenViewport);
    // Clear it.
    graphicsContext.clearColorBuffer(0.0, 0.0, 0.0, 0.0);
    graphicsContext.clearDepthBuffer(1.0);


    Matrix4 T = new Matrix4.rotationX(_radians).scale(8.0);
    // Set model for rendering.
    model.set();
    // Update camera shader constants.
    updateCameraConstants(camera);
    // Update object transform shader constant.
    updateObjectTransformConstant(T);
    // Use the 'wood' texture.
    graphicsContext.setTexture(0, assetManager['base.wood']);
    // Use the default sampler to sample the texture.
    graphicsContext.setSampler(0, defaultSampler);
    // Configure rasterizer for this model.
    graphicsContext.setRasterizerState(rasterizerState);
    // Configure depth buffer for this model.
    graphicsContext.setDepthState(depthState);
    // Draw.
    model.draw();

    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);

    // Use the system provided render target by switching to
    // RenderTarget.systemRenderTarget.
    graphicsContext.setRenderTarget(RenderTarget.systemRenderTarget);

    // Set the depth state for fullscreen rendering.
    graphicsContext.setDepthState(fullscreenDepthState);

    // Set the viewport (2D area of render target to render on to).
    // The viewport variable is defined in example.dart and always
    // fills the canvas element.
    graphicsContext.setViewport(viewport);

    // Clear it.
    graphicsContext.clearColorBuffer(0.97, 0.97, 0.97, 1.0);
    graphicsContext.clearDepthBuffer(1.0);

    // Draw the off screen texture.

    fullscreenBlitModel.set();
    ShaderProgram sp = assetManager['base.blitMergeColorTexturesShader'];
    // Use the color buffer for the texture.
    graphicsContext.setTexture(sp.samplers['sourceR'].index, redColorBuffer);
    graphicsContext.setTexture(sp.samplers['sourceG'].index, greenColorBuffer);
    graphicsContext.setTexture(sp.samplers['sourceB'].index, blueColorBuffer);
    graphicsContext.setTexture(sp.samplers['sourceA'].index, alphaColorBuffer);
    // Use a sampler that supports non-power-of-two texture dimensions.
    graphicsContext.setSampler(0, fullscreenSampler);
    graphicsContext.setSampler(1, fullscreenSampler);
    graphicsContext.setSampler(2, fullscreenSampler);
    graphicsContext.setSampler(3, fullscreenSampler);
    graphicsContext.setViewport(viewport);
    fullscreenBlitModel.draw();
  }
}

main() {
  Example example = new MultipleRenderTargets(query('#backBuffer'));
  runExample(example);
}
