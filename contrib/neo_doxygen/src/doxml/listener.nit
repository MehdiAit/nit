# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Basic SAX listeners.
module doxml::listener

import saxophonit
import model
import language_specific

# Common abstractions for SAX listeners reading XML documents generated by Doxygen.
abstract class DoxmlListener
	super ContentHandler

	# The locator setted by calling `document_locator=`.
	protected var locator: nullable SAXLocator = null

	# The project graph.
	fun graph: ProjectGraph is abstract

	# The language-specific strategies to use.
	fun source_language: SourceLanguage is abstract

	redef fun document_locator=(locator: SAXLocator) do
		self.locator = locator
	end

	# The Doxygen’s namespace IRI.
	protected fun dox_uri: String do return ""

	redef fun start_element(uri: String, local_name: String, qname: String,
			atts: Attributes) do
		super
		if uri != dox_uri then return # None of our business.
		start_dox_element(local_name, atts)
	end

	# Process the start of an element in the Doxygen’s namespace.
	#
	# See `ContentHandler.start_element` for the description of the parameters.
	protected fun start_dox_element(local_name: String, atts: Attributes) do end

	redef fun end_element(uri: String, local_name: String, qname: String) do
		super
		if uri != dox_uri then return # None of our business.
		end_dox_element(local_name)
	end

	# Process the end of an element in the Doxygen’s namespace.
	#
	# See `ContentHandler.start_element` for the description of the parameters.
	protected fun end_dox_element(local_name: String) do end

	# Get the boolean value of the specified attribute.
	#
	# `false` by default.
	protected fun get_bool(atts: Attributes, local_name: String): Bool do
		return get_optional(atts, local_name, "no") == "yes"
	end

	# Get the value of an optional attribute.
	#
	# Parameters:
	#
	# * `atts`: attribute list.
	# * `local_name`: local name of the attribute.
	# * `default`: value to return when the specified attribute is not found.
	protected fun get_optional(atts: Attributes, local_name: String,
			default: String): String do
		return atts.value_ns(dox_uri, local_name) or else default
	end

	# Get the value of an required attribute.
	#
	# Parameters:
	#
	# * `atts`: attribute list.
	# * `local_name`: local name of the attribute.
	protected fun get_required(atts: Attributes, local_name: String): String do
		var value = atts.value_ns(dox_uri, local_name)
		if value == null then
			throw_error("The `{local_name}` attribute is required.")
			return ""
		else
			return value
		end
	end

	redef fun end_document do
		locator = null
	end

	# Throw an error with the specified message by prepending the current location.
	protected fun throw_error(message: String) do
		var e: SAXParseException

		if locator != null then
			e = new SAXParseException.with_locator(message, locator.as(not null))
		else
			e = new SAXParseException(message)
		end
		e.throw
	end
end

# A `DoxmlListener` that read only a part of a document.
#
# Temporary redirect events to itself until it ends processing its part.
abstract class StackableListener
	super DoxmlListener

	# The associated reader.
	var reader: XMLReader

	# The parent listener.
	var parent: DoxmlListener

	# Namespace’s IRI of the element at the root of the part to process.
	private var root_uri: String = ""

	# Local name of the element at the root of the part to process.
	private var root_local_name: String = ""

	# The number of open element of the same type than the root of the part to process.
	private var depth = 0

	# The project graph.
	private var p_graph: ProjectGraph is noinit

	# The language-specific strategies to use.
	private var p_source: SourceLanguage is noinit


	init do
		super
		p_graph = parent.graph
		p_source = parent.source_language
	end

	redef fun graph do return p_graph
	redef fun source_language do return p_source

	# Temporary redirect events to itself until the end of the specified element.
	fun listen_until(uri: String, local_name: String) do
		root_uri = uri
		root_local_name = local_name
		depth = 1
		reader.content_handler = self
		locator = parent.locator
	end

	redef fun start_element(uri: String, local_name: String, qname: String,
			atts: Attributes) do
		super
		if uri == root_uri and local_name == root_local_name then
			depth += 1
		end
	end

	redef fun end_element(uri: String, local_name: String, qname: String) do
		super
		if uri == root_uri and local_name == root_local_name then
			depth -= 1
			if depth <= 0 then
				end_listening
				parent.end_element(uri, local_name, qname)
			end
		end
	end

	# Reset the reader’s listener to the parent.
	fun end_listening do
		reader.content_handler = parent
		locator = null
	end

	redef fun end_document do
		end_listening
	end
end

# A SAX listener that skips any event except the end of the part to process.
#
# Used to skip an entire element.
class NoopListener
	super StackableListener
end

# Concatenates any text node found.
class TextListener
	super StackableListener

	# The read text.
	protected var buffer: Buffer = new FlatBuffer

	# Is the last read chunk was ignorable white space?
	private var sp: Bool = false

	redef fun listen_until(uri: String, local_name: String) do
		buffer.clear
		sp = false
		super
	end

	redef fun characters(str: String) do
		if sp then
			if buffer.length > 0 then buffer.append(" ")
			sp = false
		end
		buffer.append(str)
	end

	redef fun ignorable_whitespace(str: String) do
		sp = true
	end

	# Flush the buffer.
	protected fun flush_buffer: String do
		var s = buffer.to_s

		buffer.clear
		sp = false
		return s
	end

	redef fun to_s do return buffer.to_s
end

# Processes a content of type `linkedTextType`.
abstract class LinkedTextListener[T: LinkedText]
	super TextListener

	# The read text.
	var linked_text: T is noinit

	private var refid = ""

	# Create a new instance of `T`.
	protected fun create_linked_text: T is abstract

	redef fun listen_until(uri: String, local_name: String) do
		linked_text = create_linked_text
		refid = ""
		super
	end

	redef fun start_dox_element(local_name: String, atts: Attributes) do
		super
		push_part
		if "ref" == local_name then refid = get_required(atts, "refid")
	end

	redef fun end_dox_element(local_name: String) do
		super
		push_part
		if "ref" == local_name then refid = ""
	end

	private fun push_part do
		var s = flush_buffer

		if not s.is_empty then
			linked_text.add_part(s, refid)
		end
	end

	redef fun to_s do return linked_text.to_s
end

# Processes the content of a `<type>` element.
class TypeListener
	super LinkedTextListener[RawType]

	private var raw_type: RawType is noinit

	redef fun create_linked_text do return new RawType(graph)
end
