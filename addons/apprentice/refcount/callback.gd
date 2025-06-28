#============================================================
#    Callback
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-04 13:29:58
# - version: 4.0
#============================================================
## 回调
##
##一般用在信号参数上，发出这个功能的回调方法，接受传入的参数
class_name Callback


var _callback : Callable


func _init(callback: Callable):
	_callback = callback


func execute(params: Array = []):
	_callback.callv(params)

