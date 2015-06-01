module class_model

class Jc_model
	var cl_name: String is noinit, writable
	var cl_atribut = new Array[Cl_attributs]
	var cl_fun = new Array[Cl_functions]
	var cl_const = new Array[Cl_const]
	var cl_redef_class = new Array[String] is writable
end

class Cl_attributs
	var att_name: String is noinit,  writable
	var att_type: String is noinit, writable
	var att_scoop = new Array[String]
end

class Cl_functions
	var fun_name: String is noinit, writable
	var fun_type: String is noinit,  writable
	var fun_scoop = new Array[String] is writable
	var fun_params = new Array[String] is writable
end

class Cl_const
end

