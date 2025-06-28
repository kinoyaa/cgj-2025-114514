extends Node
class_name Algo


# 归并排序入口函数
static func merge_sort(data: Array) -> Array:
	if data.size() <= 1:
		return data
	# 创建副本以避免修改原数组
	var arr = data.duplicate()
	_merge_sort_helper(arr, 0, arr.size() - 1)
	return arr

# 递归排序辅助函数
static func _merge_sort_helper(arr: Array, left: int, right: int) -> void:
	if left < right:
		var mid := left + (right - left) / 2
		_merge_sort_helper(arr, left, mid)
		_merge_sort_helper(arr, mid + 1, right)
		_merge(arr, left, mid, right)

# 合并两个已排序的子数组
static func _merge(arr: Array, left: int, mid: int, right: int) -> void:
	var n1 := mid - left + 1
	var n2 := right - mid
	
	# 使用预分配数组提高性能
	var L := []
	L.resize(n1)
	var R := []
	R.resize(n2)
	
	# 填充左半部分
	for i in range(n1):
		L[i] = arr[left + i]
	
	# 填充右半部分
	for j in range(n2):
		R[j] = arr[mid + 1 + j]
	
	# 合并过程
	var i := 0
	var j := 0
	var k := left
	
	while i < n1 and j < n2:
		if L[i] <= R[j]:
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
