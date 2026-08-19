# ClassControl Flutter — versión conectada

## Backend configurado

La app ya apunta a:

`https://classcontrolserver-production.up.railway.app`

No agregues `/` al final.

## Qué quedó conectado

- Login real contra `/Iniciar`.
- Persistencia de sesión con `JSESSIONID`.
- Compatibilidad Flutter Web mediante `BrowserClient` + credenciales.
- Verificación de sesión al iniciar con `/api/SesionActual`.
- Cerrar sesión con `/api/CerrarSesion`.
- Registro público de aprendiz contra `/RegistrarUsuario`.
- Dashboard real contra `/ConsultarDashboard`.
- Fichas: listar / crear / editar / eliminar.
- Programas: listar / crear / editar / eliminar.
- Competencias: listar / crear / editar / eliminar.
- Actividades: listar / crear / editar / eliminar.
- Ambientes: listar / crear / editar / eliminar.
- Instructores: consulta real desde usuarios + roles.
- Usuarios: consulta real para administrador.
- Programación: consulta, creación, edición y eliminación para administrador y coordinador. El servidor valida permisos y conflictos de horario.
- Perfil: datos de la sesión real.

## Importante: backend

Para que Flutter Web funcione, Railway debe tener desplegada la versión del backend que contiene:

- `CorsFilter.java`
- `ApiUtil.java`
- `SesionActualApi.java`
- `CerrarSesionApi.java`
- las modificaciones de los servlets para `Accept: application/json`

El archivo `ClassControl_backend_actualizado.zip` que venía en `files.zip` es la versión preparada para esto.

## Ejecutar

```bash
flutter pub get
flutter run -d chrome
```

Para Android:

```bash
flutter run
```

## Si aparece 401

Eso significa que Flutter no tiene una sesión válida. Inicia sesión nuevamente.

## Si aparece CORS en Chrome

El backend desplegado en Railway todavía no tiene el `CorsFilter` actualizado. Hay que hacer Clean and Build, subir el WAR/repo actualizado y volver a desplegar.

## Nota sobre registro

El registro público está fijado como aprendiz (`rol = 2`) y usa tipo de documento `1`, siguiendo los valores definidos en el backend actual. Si tu tabla `tipo_documento` usa otro ID para el documento predeterminado, cambia ese valor en `registrar_screen.dart`.
