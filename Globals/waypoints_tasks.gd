extends Node

# List of Tasks / Activities 
# class_name WaypointsTasks

enum tasks {
	ARCHIVE_DRAWER, 
	PRINTER,
	BOOKSHELF, 
	FRIDGE, 
	IDEA, 
	WATER_DISPENSER, 
	REST 
}

# Sprites per Activity / Tasks 
# 0 Paper | 1 Book | 2 Cookie | 3 Lightbulb | 4 Water | 5 Rest
const tasks_frames := {
	tasks.ARCHIVE_DRAWER: 0,
	tasks.PRINTER: 0,
	tasks.BOOKSHELF: 1,
	tasks.FRIDGE: 2,
	tasks.IDEA: 3,
	tasks.WATER_DISPENSER: 4,
	tasks.REST: 5 
}

# Roles and their tasks 
const role_tasks := {
	"Jefe": [
		tasks.ARCHIVE_DRAWER, tasks.BOOKSHELF, tasks.IDEA, tasks.PRINTER, 
		tasks.WATER_DISPENSER, tasks.FRIDGE, tasks.REST
	],
	"Informático": [
		tasks.PRINTER, tasks.ARCHIVE_DRAWER,
		tasks.WATER_DISPENSER, tasks.FRIDGE, tasks.REST
	],
	"Becario": [
		tasks.ARCHIVE_DRAWER, tasks.PRINTER, 
		tasks.WATER_DISPENSER, tasks.FRIDGE, tasks.REST
	],
	"Servicio al Cliente": [
		tasks.PRINTER, 
		tasks.WATER_DISPENSER, tasks.FRIDGE, tasks.REST
	],
	"Mantenimiento": [
		tasks.PRINTER, tasks.ARCHIVE_DRAWER, 
		tasks.WATER_DISPENSER, tasks.FRIDGE, tasks.REST
	],
}

# static func frame_for_task(task: int) -> int:
func frame_for_task(task: int) -> int:
	return tasks_frames.get(task, 0)

# static func can_role_use(task: int, role: String) -> bool:
func can_role_use(task: int, role: String) -> bool:
	var allowed: Array = role_tasks.get(role, [])
	# si un rol no está en la tabla, por defecto permitimos todo
	return allowed.is_empty() or allowed.has(task)

# static func name_for_task(task: int) -> String:
func name_for_task(task: int) -> String:
	match task:
		tasks.ARCHIVE_DRAWER: return "Archivador"
		tasks.BOOKSHELF: return "Biblioteca"
		tasks.FRIDGE:     return "Comer"
		tasks.IDEA:      return "Idear"
		tasks.WATER_DISPENSER:       return "Beber agua"
		tasks.REST:   return "Descansar"
		tasks.PRINTER:  return "Impresora"
		_: return "Desconocido"
