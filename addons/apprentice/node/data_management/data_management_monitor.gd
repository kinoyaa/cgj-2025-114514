#============================================================
#    Data Management Monitor
#============================================================
# - datetime: 2022-11-24 22:00:33
#============================================================
## DataManagement 信号监听器
##
##[br]指定 [DataManagement] 类型的节点自动连接发出的属性改变信号。
##[br]
##[br]用于继承此脚本，重写 [method _newly_added_data]、[method _data_changed]、
##[method _removed_data] 方法进行扩展自定义类方法及功能
class_name DataManagementMonitor
extends Node


@onready
var data_management : DataManagement = get_parent() :
	set(v):
		if data_management != null:
			push_error("已经置了 data_management 不能修改！")
			return
		data_management = v
		if data_management:
			data_management.newly_added_data.connect(self._newly_added_data)
			data_management.data_changed.connect(self._data_changed)
			data_management.removed_data.connect(self._removed_data)


#============================================================
#  自定义
#============================================================
func _newly_added_data(id, value):
	pass


func _data_changed(id, previous, current):
	pass


func _removed_data(id, value):
	pass


