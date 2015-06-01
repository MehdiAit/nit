# ...
module walker
import lexic_test_parser
import class_model

# ...
class Interpretor 
	super Visitor

	# Get the type
	var get_type = new Array[String]

	# Get the class name
	var get_class = new Array[String]
	# TMP
	var get_cl_temp = new Array[String]

	# Get the scoop
	var get_scoop = new Array[String]

	# Get the params
	var get_params = new Array[String]
	# Check if this is a param
	var is_param = false

	# The class that will be use by the FFi
	var redef_class = new HashSet[String]
	# The class model
	var class_model = new Jc_model

	redef fun visit(n) do n.accept_walker(self)
end

redef class Node
	# The visitor
	fun accept_walker(w: Interpretor) do visit_children(w)
end

redef class Nclass_construct_construct
	redef fun accept_walker(v) do
		print "const"
	end
end

redef class Nclass_def_class
	redef fun accept_walker(v) do
		v.enter_visit(n_class_id)
		var class_name = v.get_class.pop	
		v.class_model.cl_name = class_name
		
		var nclass_core = n_class_core
		if nclass_core != null then
			v.enter_visit(nclass_core)
		end

		#print v.class_model.cl_name
	end
end

redef class Nfield_def_field
	redef fun accept_walker(v) do
	end
end

redef class Nscope
	redef fun accept_walker(v) do 
		v.get_scoop.push(text)
	end
end

redef class Nfun_def_fun
	redef fun accept_walker(v) do
		v.enter_visit(n_type)

		var fun_featers = new Cl_functions
		var tmp_param = new Array[String]
		var tmp_scope = new Array[String]

		fun_featers.fun_type = v.get_type.pop
		fun_featers.fun_name = n_id.text

		var nparams = n_params
		if nparams != null then
			v.enter_visit(nparams)
			for x in [0..v.get_params.length[ do
				tmp_param[x] = v.get_params[x]
			end
			for x in [0..v.get_params.length[ do
				v.get_params.pop
			end

		end

		var nscope = n_scope
		if nscope != null then
			v.enter_visit(nscope)
			for x in [0..v.get_scoop.length[ do
				tmp_scope[x] = v.get_scoop[x]
			end
			for x in [0..v.get_scoop.length[ do
				v.get_scoop.pop
			end
			#print tmp_scope.length
		end

		fun_featers.fun_params = tmp_param
		fun_featers.fun_scoop = tmp_scope

		v.class_model.cl_fun.push(fun_featers)

		#print "Fun {n_id.text} : {check_param(fun_featers.fun_params)}"
	end

	private fun check_param(arr: Array[String]): String do
		var a = ""
		for x in [0..arr.length[ do
			a = a + arr[x] + " ,"
		end
		return a
	end
end

redef class Nparams_param_type
	redef fun accept_walker(v) do
		v.is_param = true
		super
		v.is_param = false
	end
end

redef class Ntype_list_param_type_list
	redef fun accept_walker(v) do
		super
	end
end

redef class Nprimitive_type
	redef fun accept_walker(v) do
		var text = n_prim_type.text
		v.get_type.push(text)
		if v.is_param == true then v.get_params.push(text)
	end
end

redef class Nstruct_type_struct_core
	redef fun accept_walker(v) do
		v.enter_visit(n_simple_type)
		var text = v.get_type.pop + n_brackets.text
		v.get_type.push(text)
		if v.is_param == true then
			text = v.get_params.pop + n_brackets.text
			v.get_params.push(text)
		end
	end
end

redef class Nclass_id_object_type
	redef fun accept_walker(v)do 
		super
		var text = n_id.text
		var list_class = n_class_id_list

		if list_class != null then
			for x in [0..v.get_cl_temp.length[ do
				text = text + v.get_cl_temp[x]
			end

			for x in [0..v.get_cl_temp.length[ do
				v.get_cl_temp.pop
			end
		end

		v.get_class.push(text)
		if v.is_param == true then v.get_params.push(text)

		v.redef_class.add(text)
	end
end

redef class Nclass_id_list_object_type_list
	redef fun accept_walker(v) do
		var text = "."+n_id.text
		v.get_cl_temp.push(text)
	end
end

# Visitor lancher
class Lancher
	# Start the visitor and get the model
	fun walker: Jc_model do
		var t = new TestParser_lexic
		var n = t.main
		var v = new Interpretor 

		v.enter_visit(n)

		v.class_model.cl_redef_class = v.redef_class.to_a
		return v.class_model
	end
end
