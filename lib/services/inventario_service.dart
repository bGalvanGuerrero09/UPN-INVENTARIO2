import '../models/producto.dart';

class InventarioService {
  // =========================================================
  // PRODUCTOS TEMPORALES
  // Más adelante esto puede venir de una base de datos.
  // =========================================================

  static final List<Producto> _productos = [
    Producto(
      id: 1,
      nombre: 'Paracetamol 500 mg',
      stock: 100,
    ),
    Producto(
      id: 2,
      nombre: 'Ibuprofeno 400 mg',
      stock: 80,
    ),
    Producto(
      id: 3,
      nombre: 'Amoxicilina 500 mg',
      stock: 60,
    ),
    Producto(
      id: 4,
      nombre: 'Azitromicina 500 mg',
      stock: 40,
    ),
    Producto(
      id: 5,
      nombre: 'Diclofenaco 50 mg',
      stock: 70,
    ),
    Producto(
      id: 6,
      nombre: 'Omeprazol 20 mg',
      stock: 90,
    ),
    Producto(
      id: 7,
      nombre: 'Loratadina 10 mg',
      stock: 50,
    ),
    Producto(
      id: 8,
      nombre: 'Salbutamol 100 mcg',
      stock: 35,
    ),
    Producto(
      id: 9,
      nombre: 'Metformina 850 mg',
      stock: 75,
    ),
    Producto(
      id: 10,
      nombre: 'Losartán 50 mg',
      stock: 65,
    ),
    Producto(
      id: 11,
      nombre: 'Jeringa descartable 5 ml',
      stock: 200,
    ),
    Producto(
      id: 12,
      nombre: 'Jeringa descartable 10 ml',
      stock: 180,
    ),
    Producto(
      id: 13,
      nombre: 'Aguja hipodérmica 21G',
      stock: 250,
    ),
    Producto(
      id: 14,
      nombre: 'Aguja hipodérmica 23G',
      stock: 220,
    ),
    Producto(
      id: 15,
      nombre: 'Guantes quirúrgicos talla M',
      stock: 300,
    ),
    Producto(
      id: 16,
      nombre: 'Guantes quirúrgicos talla L',
      stock: 280,
    ),
    Producto(
      id: 17,
      nombre: 'Mascarilla quirúrgica',
      stock: 500,
    ),
    Producto(
      id: 18,
      nombre: 'Mascarilla N95',
      stock: 150,
    ),
    Producto(
      id: 19,
      nombre: 'Algodón hidrófilo 100 g',
      stock: 100,
    ),
    Producto(
      id: 20,
      nombre: 'Alcohol medicinal 70% 500 ml',
      stock: 90,
    ),
    Producto(
      id: 21,
      nombre: 'Agua oxigenada 10 volúmenes',
      stock: 60,
    ),
    Producto(
      id: 22,
      nombre: 'Gasa estéril 10 x 10 cm',
      stock: 200,
    ),
    Producto(
      id: 23,
      nombre: 'Venda elástica 10 cm',
      stock: 80,
    ),
    Producto(
      id: 24,
      nombre: 'Esparadrapo médico 5 cm',
      stock: 70,
    ),
    Producto(
      id: 25,
      nombre: 'Termómetro digital',
      stock: 25,
    ),
    Producto(
      id: 26,
      nombre: 'Tensiómetro digital',
      stock: 15,
    ),
    Producto(
      id: 27,
      nombre: 'Estetoscopio',
      stock: 12,
    ),
    Producto(
      id: 28,
      nombre: 'Oxímetro de pulso',
      stock: 20,
    ),
    Producto(
      id: 29,
      nombre: 'Suero fisiológico 0.9% 500 ml',
      stock: 50,
    ),
    Producto(
      id: 30,
      nombre: 'Solución dextrosa 5% 500 ml',
      stock: 40,
    ),
  ];


  // =========================================================
  // OBTENER TODOS LOS PRODUCTOS
  // =========================================================

  static List<Producto> obtenerProductos() {
    return List.unmodifiable(_productos);
  }

  // =========================================================
  // BUSCAR PRODUCTO EXACTAMENTE
  // =========================================================

  static Producto? buscarProducto(String nombre) {
    final texto = nombre.trim().toLowerCase();

    for (final producto in _productos) {
      if (producto.nombre.toLowerCase() == texto) {
        return producto;
      }
    }

    return null;
  }

  // =========================================================
  // FILTRAR PRODUCTOS
  //
  // Sirve para la lupa y para la búsqueda por voz.
  //
  // Ejemplo:
  //
  // "mouse"
  //
  // devuelve:
  //
  // Mouse Logitech
  //
  // =========================================================

  static List<Producto> filtrarProductos(String texto) {
    final busqueda = texto.trim().toLowerCase();

    // Si no se escribió nada,
    // devolvemos todos los productos.
    if (busqueda.isEmpty) {
      return obtenerProductos();
    }

    return _productos.where((producto) {
      return producto.nombre
          .toLowerCase()
          .contains(busqueda);
    }).toList();
  }

  // =========================================================
  // REGISTRAR INGRESO
  // =========================================================

  static bool registrarIngreso(
      Producto producto,
      int cantidad,
      ) {
    if (cantidad <= 0) {
      return false;
    }

    producto.stock += cantidad;

    return true;
  }

  // =========================================================
  // REGISTRAR SALIDA
  // Lo dejamos preparado para cuando hagamos salida.dart
  // =========================================================

  static bool registrarSalida(
      Producto producto,
      int cantidad,
      ) {
    if (cantidad <= 0) {
      return false;
    }

    // No permitir stock negativo.
    if (producto.stock < cantidad) {
      return false;
    }

    producto.stock -= cantidad;

    return true;
  }

  // =========================================================
// REGISTRAR NUEVO PRODUCTO
// =========================================================

  static Producto agregarProducto(
      String nombre,
      int stockInicial,
      ) {
    final nuevoId = _productos.isEmpty
        ? 1
        : _productos
        .map((producto) => producto.id)
        .reduce((a, b) => a > b ? a : b) +
        1;

    final nuevoProducto = Producto(
      id: nuevoId,
      nombre: nombre,
      stock: stockInicial,
    );

    _productos.add(nuevoProducto);

    return nuevoProducto;
  }



}
