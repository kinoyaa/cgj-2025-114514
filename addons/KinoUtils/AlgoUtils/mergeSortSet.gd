extends Resource
class_name mergeSortSet

@export var arr : Array
@export var variable : String = ""

# 主排序函数
func sort() -> void:
	if arr.size() <= 1:
		return
	
	_merge_sort(0, arr.size() - 1)

# 递归排序实现
func _merge_sort(left: int, right: int) -> void:
	if left < right:
		var mid := left + (right - left) / 2
		_merge_sort(left, mid)
		_merge_sort(mid + 1, right)
		_merge(left, mid, right)

# 合并两个已排序的子数组
func _merge(left: int, mid: int, right: int) -> void:
	var n1 := mid - left + 1
	var n2 := right - mid
	
	# 创建临时数组
	var L := []
	L.resize(n1)
	var R := []
	R.resize(n2)
	
	# 填充临时数组
	for i in range(n1):
		L[i] = arr[left + i]
	for j in range(n2):
		R[j] = arr[mid + 1 + j]
	
	# 合并过程
	var i := 0
	var j := 0
	var k := left
	
	while i < n1 and j < n2:
		var compare_result = _compare_elements(L[i], R[j])
		if compare_result <= 0:
			arr[k] = L[i]
			i += 1
		else:
			arr[k] = R[j]
			j += 1
		k += 1
	
	# 复制剩余元素
	while i < n1:
		arr[k] = L[i]
		i += 1
		k += 1
	
	while j < n2:
		arr[k] = R[j]
		j += 1
		k += 1

# 比较两个元素（支持属性路径）
func _compare_elements(a, b) -> int:
	if variable.is_empty():
		# 直接比较元素本身
		if a < b:
			return -1
		elif a > b:
			return 1
		return 0
	else:
		# 通过属性路径比较
		var a_value = a.get(variable) if a is Object else a[variable]
		var b_value = b.get(variable) if b is Object else b[variable]
		
		if a_value < b_value:
			return -1
		elif a_value > b_value:
			return 1
		return 0
