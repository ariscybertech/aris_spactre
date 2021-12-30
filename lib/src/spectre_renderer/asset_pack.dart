/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

part of spectre_renderer;

class MaterialShaderImporter extends AssetImporter {
  final Renderer renderer;

  MaterialShaderImporter(this.renderer);

  /// Must initialize imported field in [asset].
  void initialize(Asset asset) {

  }
  /// Import [payload] and assign it to imported field in [asset].
  Future<Asset> import(dynamic payload, Asset asset, AssetPackTrace tracer) {

  }
  /// Delete [imported] object.
  void delete(dynamic imported) {

  }
}

class MaterialImporter extends AssetImporter {
  final Renderer renderer;

  MaterialImporter(this.renderer);

  /// Must initialize imported field in [asset].
  void initialize(Asset asset) {

  }
  /// Import [payload] and assign it to imported field in [asset].
  Future<Asset> import(dynamic payload, Asset asset, AssetPackTrace tracer) {

  }
  /// Delete [imported] object.
  void delete(dynamic imported) {

  }
}

class RendererConfigImporter extends AssetImporter {
  final Renderer renderer;

  RendererConfigImporter(this.renderer);

  /// Must initialize imported field in [asset].
  void initialize(Asset asset) {

  }
  /// Import [payload] and assign it to imported field in [asset].
  Future<Asset> import(dynamic payload, Asset asset, AssetPackTrace tracer) {

  }
  /// Delete [imported] object.
  void delete(dynamic imported) {

  }
}

class LayerListImporter extends AssetImporter {
  final Renderer renderer;
  LayerListImporter(this.renderer);

  /// Must initialize imported field in [asset].
  void initialize(Asset asset) {

  }
  /// Import [payload] and assign it to imported field in [asset].
  Future<Asset> import(dynamic payload, Asset asset, AssetPackTrace tracer) {

  }
  /// Delete [imported] object.
  void delete(dynamic imported) {

  }
}

/** Register the Spectre renderer with the asset_pack library. */
void registerSpectreRendererWithAssetManager(Renderer renderer,
                                             AssetManager assetManager) {
  assetManager.loaders['materialShader'] = new TextLoader();
  assetManager.loaders['material'] = new TextLoader();
  assetManager.loaders['rendererConfig'] = new TextLoader();
  assetManager.loaders['layerList'] = new TextLoader();

  /*
  assetManager.importers['materialShader'] =
      new MaterialShaderImporter(renderer);
  assetManager.importers['material'] =
      new MaterialImporter(renderer);
  assetManager.importers['rendererConfig'] =
      new RendererConfigImporter(renderer);
  assetManager.importers['layerList'] =
      new LayerListImporter(renderer);
  */
  assetManager.importers['materialShader'] = new NoopImporter();
  assetManager.importers['material'] = new NoopImporter();
  assetManager.importers['rendererConfig'] = new NoopImporter();
  assetManager.importers['layerList'] = new NoopImporter();
}