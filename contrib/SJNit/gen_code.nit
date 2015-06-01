# ...
module gen_code
import walker

# Gen cclass
class Gen
	# Model class
	var get_model: Jc_model

	# Nit class
	var cl_output = ""

	# Functions output
	var fun_output: String is noinit
	
	# Static functions output
	var static_fun_output: String is noinit

	# Nit name
	var nit_class: String is noinit

	# Nit functions number
	var is_function = new HashMap[String, Int]

	# Function gen
	fun fun_gen do
		nit_class = class_type(get_model.cl_name)
		fun_output = "extern class {nit_class} in \"Java\" \`\{ {get_model.cl_name} \`\}\n\n"
		static_fun_output = ""
		for x in [0..get_model.cl_fun.length[ do
			var is_returned = false
			var re_type = ""
			var n_param = 1
			var param = get_model.cl_fun[x].fun_params

			if not get_model.cl_fun[x].fun_scoop.has("static") then
				fun_output = fun_output + "\tfun "+ number_fun(get_model.cl_fun[x].fun_name.to_snake_case) + "("
				param_fun(param, n_param, "no_static")

				n_param = 1
				if get_model.cl_fun[x].fun_type != "void" then
					re_type = ": " + check_type(get_model.cl_fun[x].fun_type)
					is_returned = true
				end

				fun_output = fun_output + ")" + re_type + " in \"Java\" \`\{\n\t\t"
				return_check(is_returned, "no_static", get_model.cl_fun[x])
				java_param_fun(param, n_param, "no_static")
				fun_output += "); \n\t\`\}\n" + "\n"
			else
				static_fun_output += "\tfun " + number_fun(get_model.cl_fun[x].fun_name.to_snake_case) + "("
				param_fun(param, n_param, "static")

				n_param = 1
				if get_model.cl_fun[x].fun_type != "void" then
					re_type = ": " + check_type(get_model.cl_fun[x].fun_type)
					is_returned = true
				end

				static_fun_output += ")" + re_type + " in \"Java\" \`\{\n\t\t"
				return_check(is_returned, "static", get_model.cl_fun[x])
				java_param_fun(param, n_param, "static")
				static_fun_output += "); \n\t\`\}\n" + "\n"


			end
		end
		cl_output = fun_output + "end\n" + static_fun_output
		print cl_output
	end

	# Return check
	fun return_check(re_turn: Bool, scoop: String, other: Cl_functions) do
		if scoop == "no_static" then
			if re_turn then
				fun_output += " return self.{other.fun_name}("
			else
				fun_output += " self.{other.fun_name}("
			end
		else
			if re_turn then
				static_fun_output += " return {get_model.cl_name}.{other.fun_name}("
			else
				static_fun_output += " {get_model.cl_name}.{other.fun_name}("
			end
		end
	end

	# ...
	fun java_param_fun(param: Array[String], pos: Int, scoop: String) do
		var n_param = pos
		if scoop == "no_static" then
			for y in [0..param.length[ do
				if n_param == 1 then
					fun_output += "var{n_param}"
				else
					fun_output += ", var{n_param}"
				end
				n_param += 1
			end
		else
			for y in [0..param.length[ do
				if n_param == 1 then
					static_fun_output += "var{n_param}"
				else
					static_fun_output += ", var{n_param}"
				end
				n_param += 1
			end
		end
	end

	# ...
	fun param_fun(param: Array[String], pos: Int, scoop: String) do
		var n_param = pos
		if scoop == "no_static" then
			for y in [0..param.length[ do
				if n_param == 1 then
					fun_output += "var{n_param}: " + check_type(param[y])
				else
					fun_output += ", var{n_param}: " + check_type(param[y])
				end
				n_param += 1
			end
		else
			for y in [0..param.length[ do
				if n_param == 1 then
					static_fun_output += "var{n_param}: " + check_type(param[y])
				else
					static_fun_output += ", var{n_param}: " + check_type(param[y])
				end
				n_param += 1
			end
		end
	end

	# Type check
	fun check_type(other: String): String do
		if other.has("[]") then return struct_type(other)
		return get_type(other)
	end

	# Get types (primitive and class types)
	fun get_type(other: String): String do
		if other == "int" then return "Int"
		if other == "byte" then return "Int"
		if other == "long" then return "Int"
		if other == "short" then return "Int"
		if other == "java.lang.Integer" then return "Int"
		if other == "java.lang.Byte" then return "Int"
		if other == "java.lang.Short" then return "Int"
		if other == "java.lang.Long" then return "Int"
		if other == "char" then return "Char"
		if other == "java.lang.Character" then return "Char"
		if other == "float" then return "Float"
		if other == "double" then return "Float"
		if other == "java.lang.Float" then return "Float"
		if other == "java.lang.Double" then return "Float"
		if other == "boolean" then return "Bool"
		if other == "java.lang.Boolean" then return "Bool"
		if other == "java.lang.Object" then return "JavaObject"
		if other == "java.lang.String" then return "JavaString"
		return class_type(other)
	end

	# Class type
	fun class_type(other: String): String do 
		return "Java" + other.split('.').last
	end

	# Struct type
	fun struct_type(other:String): String do
		# FIXME get more details about the table type
		if other == "float[]" then return "JavaFloatArray"
		if other == "double[]" then return "JavaDoubleArray"
		if other == "int[]" then return "JavaIntArray"
		if other == "char[]" then return "JavaCharArray"
		if other == "boolean[]" then return "JavaBoolArray"
		if other == "byte[]" then return "JavaByteArray"
		if other == "short[]" then return "JavaShortArray"
		if other == "long[]" then return "JavaLongArray"
		return "JavaArray"
	end

	# How many functions have the same name
	fun number_fun(other: String): String do
		if is_function.has_key(other) then
			is_function[other] += 1 
			return other + "_" + is_function[other].to_s
		else
			is_function[other] = 0
			return other
		end
	end

	# Java type
	fun java_type do
		for x in [0..get_model.cl_redef_class.length[ do
			if not get_model.cl_redef_class[x] == get_model.cl_name then
				cl_output += "extern class " + class_type(get_model.cl_redef_class[x]) + 
					" in \"Java\" \`\{ {get_model.cl_redef_class[x]} \`\} end \n"
			end
		end
	end

	# Output
	fun out_put do
		fun_gen
		java_type
		var file = new FileWriter.open(nit_class.to_lower + ".nit")
		file.write(cl_output)
		file.close
	end

	# TODO 
	# Generice types
	# The class constructor

end

var start = new Lancher
var gen = new Gen(start.walker)

gen.out_put

