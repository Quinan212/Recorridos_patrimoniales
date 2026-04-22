import os

desktop = os.path.join(os.path.expanduser("~"), "Desktop")
root = os.path.join(desktop, "Patrimonio_Fotos_Organizadas")

if not os.path.exists(root):
    os.makedirs(root)

points = [
    'Casa de Bernardino Horne',
    '3 de Febrero & Carlos Pellegrini',
    'Casa Juan Antonio Castro',
    'Casa del Dr. Péndola Diaz',
    'Casa Dr. Orlando Marcone',
    'Casa Alberto Crossa',
    'Casa Arcioni',
    'Banco Popular de Concordia',
    'Casa Dr. Camaño',
    'Casa Suburo',
    'Casa Juana C. de Salduna',
    'Casa Sarli',
    'Casa Bardengo',
    'Casa Cobelli',
    'Casa Miñones',
    'Casa Artaghnan',
    'Casa Hourcades',
    'Casa Beñatena',
    'Liga Argentina de Préstamos Mutuos',
    'Casa Manuel Fernández',
    'Casa Caprio',
    'Casilla del Juez de Raya'
]

for p in points:
    p_path = os.path.join(root, p)
    if not os.path.exists(p_path):
        os.makedirs(p_path)
    
    os.makedirs(os.path.join(p_path, "fotos de evidencia"), exist_ok=True)
    os.makedirs(os.path.join(p_path, "fotos finales"), exist_ok=True)

print(f"Estructura creada exitosamente en {root}")
