# Sistema de Reservas para Quioscos Universitarios

Aplicación móvil multiplataforma desarrollada en Flutter con backend en Firebase, diseñada para optimizar el tiempo de los estudiantes entre clases y digitalizar la gestión de inventario, ventas y reservas de los quioscos de la Universidad Técnica Federico Santa María (UTFSM).

## Problema y Solución

* **Problema:** En recesos breves, los estudiantes pierden entre 5 y 10 minutos haciendo fila para encontrarse con productos clave agotados (como mechada queso o mini pizzas). Además, las reservas informales y el control manual generan fricción y falta de visibilidad de stock entre los distintos quioscos del campus.
* **Solución:** Una plataforma centralizada con catálogo y stock actualizado en tiempo real, buscador multiquiosco, reserva con hora exacta de retiro y notificaciones push.

## Reglas de Negocio y Flujo Operativo

1. **Margen de Retiro:** Las reservas sin pago anticipado tienen una ventana máxima de 30 minutos para ser retiradas en el quiosco.
2. **Liberación Automática:** Si el estudiante no retira a tiempo, el producto vuelve automáticamente al inventario disponible.
3. **Penalización por Inasistencia:** Si un usuario incumple el retiro, queda bloqueado para volver a reservar ese mismo producto durante el resto del día.
4. **Reserva Garantizada:** El pago anticipado dentro de la app elimina el límite de tiempo de espera y asegura el producto.
5. **Control de Demanda:** Límites configurables de productos por reserva y reservas máximas diarias por estudiante.

## Stack Tecnológico

* **Frontend:** Flutter (Dart) — Soporte para Android, iOS y compilación de escritorio.
* **Backend y Cloud:** Firebase — Autenticación, base de datos en tiempo real y Firebase Cloud Messaging para notificaciones push.

## Instalación y Ejecución Local

1. **Clonar el repositorio:**
   ```bash
   git clone [https://github.com/gonzopsp/quiosko-reservas-app.git](https://github.com/gonzopsp/quiosko-reservas-app.git)
   cd quiosko-reservas-app
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación:**
   *(Nota: Si el entorno local arroja advertencias de versión con Android Gradle Plugin, utilizar la bandera de omisión)*
   ```bash
   flutter run --android-skip-build-dependency-validation
   ```