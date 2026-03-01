extends RefCounted

class_name Inventory

var slots: Array = []
var max_slots: int 

func _init(starting_slots: int = 4):
	max_slots = starting_slots
	for i in range(max_slots):
		slots.append(null)
		
signal inventory_changed 
		
func add_item(data: OreData) -> bool:
	#try stacking with existing items
	for slot in slots:
		if slot != null and slot.can_stack(data):
			slot.add_ore()
			inventory_changed.emit()
			return true
	
	#find empty slots
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = InventorySlot.new(data, 1)
			inventory_changed.emit()
			return true
			
	#no space
	return false
