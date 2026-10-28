# Chinita Designs · Huxcasti

Primera entrega de una tienda digital para productos personalizados, con catálogo y carrito, cotizaciones y panel de administración.

**ESTADO: DEMOSTRACIÓN. NO HAY PAGOS ACTIVOS NI PEDIDOS REALES.**

## Publicar la demostración

GitHub > Settings > Pages > Deploy from a branch > main > /(root). La tienda estará en la URL indicada por Pages; el panel estará en /admin.html.

## Preparar para uso real

1. Confirmar los datos comerciales con la dueña: nombre/logo/fotos de su autoría, precios, teléfono, recogido/envíos y políticas.
2. Crear un proyecto Supabase exclusivo de Chinita Designs (no mezclar con Just Be You, Cine ni Flambo).
3. Ejecutar database/001_schema.sql en SQL Editor. Crear una cuenta en Authentication > Users para la dueña e insertar el UID en store_admins según las instrucciones SQL.
4. Actualizar config.js con la URL pública y publishable/anon key (NUNCA service_role ni contraseñas).
5. Probar el panel, crear productos reales, revisar reglas RLS y configurar mitigación de spam/captcha para cotizaciones.
6. Para cobros, desarrollar backend privado que compruebe los precios y productos en el servidor y verifique notificaciones de pago antes de registrar órdenes; **no activar paymentsEnabled hasta realizar esas pruebas**. La primera versión mantiene los pagos desactivados, incluso si hay productos con precio.
7. Antes de aceptar pagos para productos personalizados, implementar las variaciones por artículo (nombres, textos, colores, fotos) y cálculo de precios en el servidor; mientras, publicarlos solo bajo cotización.

Archivos: index.html (tienda), styles.css (diseño), shared.js (utilidades), app.js (catálogo), admin.html y admin.js (administración), config.js (configuración pública), database/001_schema.sql (tablas y seguridad).
