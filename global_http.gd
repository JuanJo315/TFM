extends Node

@onready var http_request: HTTPRequest = $HTTPRequest

signal response_received(text: String)

func _ready() -> void:
	http_request.request_completed.connect(_on_request_completed)

func send_prompt(prompt: Array[Dictionary]) -> void:
	var data: Dictionary = {
		"model": "gemma3",
		"messages": prompt
	}
	var json_data: String = JSON.stringify(data)
	var err: Error = http_request.request(
		"http://localhost:11434/api/chat",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		json_data
	)
	if err != OK:
		push_error("Error al iniciar HTTPRequest: %s" % err)

func _on_request_completed(_result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if code != 200:
		push_error("Error HTTP: %d" % code)
		return

	# 1. Parsear la respuesta completa
	var text: String = body.get_string_from_utf8()
	var parse = JSON.parse_string(text)
	if parse.error != OK:
		push_error("Error parseando JSON: %s" % parse.error)
		return

	var resp: Dictionary = parse.result
	if not resp.has("bots") or typeof(resp["bots"]) != TYPE_ARRAY:
		push_error("Respuesta inesperada: falta campo 'bots'")
		return

	# 2. Iterar sobre cada bot devuelto
	for bot_json in resp["bots"]:
		# Obtener el ID para mapear a tu instancia
		var bot_id = bot_json.get("bot_id", null)
		if bot_id == null:
			push_warning("Bot sin bot_id en respuesta, se omite")
			continue

		# —————— Buscar la instancia del bot en el grupo "Bot" ——————
		var bot_node: Node = null
		for b in get_tree().get_nodes_in_group("Bot"):
			if b.has_method("bot_id") or b.has_meta("bot_id"):
				# si usas una propiedad export var bot_id: int
				if b.bot_id == bot_id:
					bot_node = b
					break
				# o si lo guardaste en metadatos:
				# if b.get_meta("bot_id") == bot_id:
				#     bot_node = b; break

		if bot_node == null:
			push_warning("No se encontró instancia para bot_id %s" % bot_id)
			continue

		# 3. Aplicar el llm_state completo
		var llm_state: Dictionary = bot_json.get("llm_state", {})
		bot_node.personality        = llm_state.get("personality", bot_node.personality)
		bot_node.energy_level       = llm_state.get("energy_level", bot_node.energy_level)
		bot_node.stress_level       = llm_state.get("stress_level", bot_node.stress_level)
		bot_node.health             = llm_state.get("health", bot_node.health)
		bot_node.motivation         = llm_state.get("motivation", bot_node.motivation)
		bot_node.curiosity          = llm_state.get("curiosity", bot_node.curiosity)
		bot_node.risk_tolerance     = llm_state.get("risk_tolerance", bot_node.risk_tolerance)

		# Objetivos y pensamientos
		bot_node.goal               = llm_state.get("goal", bot_node.goal)
		bot_node.objective          = llm_state.get("objective", bot_node.objective)
		bot_node.inner_thinking     = llm_state.get("inner_thinking", bot_node.inner_thinking)

		# Relaciones con colegas (diccionario de bot_id → datos)
		bot_node.colleague_relations = llm_state.get("colleague_relations", {})

		# Otros campos dinámicos
		bot_node.gossip_level       = llm_state.get("gossip_level", bot_node.gossip_level)
		bot_node.rumors_known       = llm_state.get("rumors_known", bot_node.rumors_known)
		bot_node.visible_objects    = llm_state.get("visible_objects", bot_node.visible_objects)
		bot_node.nearby_colleagues  = llm_state.get("nearby_colleagues", bot_node.nearby_colleagues)
		bot_node.heard_conversations= llm_state.get("heard_conversations", bot_node.heard_conversations)
		bot_node.current_event      = llm_state.get("current_event", bot_node.current_event)

		# 4. (Opcional) Emitir señal o inicializar comportamiento
		bot_node.start_next_action()

	# 5. Emitir señal global si necesitas notificar que todos están listos
	emit_signal("all_bots_initialized")
