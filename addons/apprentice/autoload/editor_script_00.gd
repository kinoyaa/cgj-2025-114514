# editor_script_00.gd
@tool
extends EditorScript


class A:
	pass

class B extends A:
	pass

class C extends B:
	pass


func _run():
	pass
	
	var list = ClassDB.get_inheriters_from_class("RefCounted")
	print(list)
	

