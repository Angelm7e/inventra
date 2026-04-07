/// Destino del carrito al agregar desde el catálogo.
enum CatalogCartTarget {
  /// Cotización: no valida ni descuenta inventario.
  quote,

  /// Factura: respeta stock al agregar/editar cantidades.
  billing,
}
