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

class VertexAttribute {
  /// Vertex buffer slot to fetch from.
  final int vboSlot;
  /// Shader attribute index.
  final int attributeIndex;
  /// Offset into buffer to fetch at.
  final int attributeOffset;
  /// Stride between vertices.
  final int attributeStride;
  /// Type of data.
  final int dataType;
  /// Number of dataType to be fetched for this attribute.
  final int dataCount;
  /// Data is converted into a normalized floating point value.
  /// 0.0 ... 1.0 for unsigned, -1.0 ... 1.0 for signed data.
  final bool normalizeData;
  VertexAttribute(this.vboSlot, this.attributeIndex, this.attributeOffset,
                  this.attributeStride, this.dataType, this.dataCount,
                  this.normalizeData);
  VertexAttribute.atAttributeIndex(VertexAttribute attribute,
                                   this.attributeIndex) :
      vboSlot = attribute.vboSlot,
      attributeOffset = attribute.attributeOffset,
      attributeStride = attribute.attributeStride,
      dataType = attribute.dataType,
      dataCount = attribute.dataCount,
      normalizeData = attribute.normalizeData;
}
