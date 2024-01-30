extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	mesh.surface_add_vertex(Vector3.LEFT)
	mesh.surface_add_vertex(Vector3.FORWARD)
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_end()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
