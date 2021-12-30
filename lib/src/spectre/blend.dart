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

/// Defines color blending factors.
class Blend extends Enum {
  /// Each component of the color is multiplied by (0, 0, 0, 0).
  static const int Zero = WebGL.ZERO;
  /// Each component of the color is multiplied by (1, 1, 1, 1).
  static const int One = WebGL.ONE;
  /// Each component of the color is multiplied by the source color.
  ///
  /// This can be represented as (Rs, Gs, Bs, As), where R, G, B, and A
  /// respectively stand for the red, green, blue, and alpha source values.
  static const int SourceColor = WebGL.SRC_COLOR;
  /// Each component of the color is multiplied by the inverse of the source
  /// color.
  /// This can be represented as (1 − Rs, 1 − Gs, 1 − Bs, 1 − As) where
  /// R, G, B, and A respectively stand for the red, green, blue, and alpha
  /// destination values.
  static const int InverseSourceColor = WebGL.ONE_MINUS_SRC_COLOR;
  /// Each component of the color is multiplied by the alpha value of the
  /// source. This can be represented as (As, As, As, As), where As is the
  /// alpha source value.
  static const int SourceAlpha = WebGL.SRC_ALPHA;
  /// Each component of the color is multiplied by the inverse of the alpha
  /// value of the source.
  /// This can be represented as (1 − As, 1 − As, 1 − As, 1 − As), where As is
  /// the alpha destination value.
  static const int InverseSourceAlpha = WebGL.ONE_MINUS_SRC_ALPHA;
  /// Each component of the color is multiplied by the alpha value of the
  /// destination.
  ///
  /// This can be represented as (Ad, Ad, Ad, Ad), where Ad is the destination
  /// alpha value.
  static const int DestinationAlpha = WebGL.DST_ALPHA;
  /// Each component of the color is multiplied by the inverse of the alpha
  /// value of the destination.
  ///
  /// This can be represented as (1 − Ad, 1 − Ad, 1 − Ad, 1 − Ad), where Ad is
  /// the alpha destination value.
  static const int InverseDestinationAlpha = WebGL.ONE_MINUS_DST_ALPHA;
  /// Each component color is multiplied by the destination color.
  ///
  /// This can be represented as (Rd, Gd, Bd, Ad), where R, G, B, and A
  /// respectively stand for
  /// red, green, blue, and alpha destination values.
  static const int DestinationColor = WebGL.DST_COLOR;
  /// Each component of the color is multiplied by the inverse of the
  /// destination color.
  ///
  /// This can be represented as (1 − Rd, 1 − Gd, 1 − Bd, 1 − Ad), where
  /// Rd, Gd, Bd, and Ad respectively stand for the red, green, blue, and alpha
  /// destination values.
  static const int InverseDestinationColor = WebGL.ONE_MINUS_DST_COLOR;
  /// Each component of the color is multiplied by either the alpha of the
  /// source color, or the inverse of the alpha of the source color, whichever
  /// is greater.
  ///
  /// This can be represented as (f, f, f, 1), where f = min(A, 1 − Ad).
  static const int SourceAlphaSaturation = WebGL.SRC_ALPHA_SATURATE;
  /// Each component of the color is multiplied by a constant set in
  /// BlendFactor.
  static const int BlendFactor = WebGL.CONSTANT_COLOR;
  /// Each component of the color is multiplied by the inverse of a constant
  /// set in BlendFactor.
  static const int InverseBlendFactor = WebGL.ONE_MINUS_CONSTANT_COLOR;

  static const int Default = One;

  static Map<String, int> _values = {
    'Blend.Zero' : Blend.Zero,
    'Blend.One' : Blend.One,
    'Blend.SourceColor' : Blend.SourceColor,
    'Blend.InverseSourceColor' : Blend.InverseSourceColor,
    'Blend.SourceAlpha' : Blend.SourceAlpha,
    'Blend.InverseSourceAlpha' : Blend.InverseSourceAlpha,
    'Blend.DestinationAlpha' : Blend.DestinationAlpha,
    'Blend.InverseDestinationAlpha' : Blend.InverseDestinationAlpha,
    'Blend.DestinationColor' : Blend.DestinationColor,
    'Blend.InverseDestinationColor' : Blend.InverseDestinationColor,
    'Blend.SourceAlphaSaturation' : Blend.SourceAlphaSaturation,
    'Blend.BlendFactor' : Blend.BlendFactor,
    'Blend.InverseBlendFactor' : Blend.InverseBlendFactor
  };

  /// Convert a [String] to a [Blend].
  static int parse(String name, [int d = Default]) =>
      Enum._parse(_values, name, d);
  /// Convert a [Blend] to a [String].
  static String stringify(int value) => Enum._stringify(_values, value);
  /// Checks whether the value is a valid enumeration.
  static bool isValid(int value) => Enum._isValid(_values, value);
}
