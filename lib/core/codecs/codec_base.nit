# This file is part of NIT (http://www.nitlanguage.org).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	 http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Base for codecs to use with streams
#
# A Codec (Coder/Decoder) is a tranformer from a byte-format to another
#
# As Nit Strings are UTF-8, a codec works as :
# - Coder: From a UTF-8 string to a specified format (writing)
# - Decoder: From a specified format to a UTF-8 string (reading)
module codec_base

import text
import bytes

# Codes UTF-8 entities to an external format
abstract class Coder

	# Transforms `c` to its representation in the format of `self`
	fun code_char(c: Char): Bytes is abstract

	# Adds a char `c` to bytes `s`
	fun add_char_to(c: Char, s: Bytes) is abstract

	# Transforms `s` to the format of `self`
	fun code_string(s: Text): Bytes is abstract

	# Adds a string `s` to bytes `b`
	fun add_string_to(s: Text, b: Bytes) is abstract
end

# Decodes entities in an external format to UTF-8
abstract class Decoder

	# Decodes a char from `b` to a Unicode code-point
	fun decode_char(b: Bytes): Char is abstract

	# Decodes a string `b` to UTF-8
	fun decode_string(b: Bytes): String is abstract
end
