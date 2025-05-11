# Sistema de Gestión de Vendedores

Este es un sistema CRUD (Create, Read, Update, Delete) para la gestión de vendedores desarrollado con Node.js, Express y MySQL.

## Requisitos Previos

- Node.js (versión 14 o superior)
- MySQL (versión 5.7 o superior)
- npm (incluido con Node.js)

## Instalación

1. Clona el repositorio:

   ```bash
   git clone https://github.com/CarlTheBoss/NODEDEMO.git
   cd NODEDEMO
   ```

2. Instala las dependencias:

   ```bash
   npm install
   ```

3. Configura la base de datos:

   - Inicia MySQL en tu sistema
   - Importa el archivo `ventas.sql` en tu servidor MySQL:
     - Puedes usar phpMyAdmin y importar el archivo directamente
     - O usar el comando MySQL en la terminal:
       ```bash
       mysql -u root -p < ventas.sql
       ```

4. Configura las credenciales de la base de datos:
   - Abre el archivo `crud-vendedores/db.js`
   - Modifica las credenciales según tu configuración de MySQL:
     ```javascript
     const connection = mysql.createConnection({
       host: "localhost",
       user: "tu_usuario",
       password: "tu_contraseña",
       database: "ventas",
     });
     ```

## Uso

1. Inicia la aplicación:

   ```bash
   npm start
   ```

   o en modo desarrollo:

   ```bash
   npm run dev
   ```

2. Abre tu navegador y visita:
   ```
   http://localhost:3000
   ```

## Estructura del Proyecto

```
├── crud-vendedores/
│   ├── app.js          # Archivo principal de la aplicación
│   ├── db.js           # Configuración de la base de datos
│   ├── routes/         # Rutas de la aplicación
│   └── views/          # Plantillas EJS
├── package.json        # Dependencias y scripts
├── ventas.sql         # Esquema de la base de datos
└── README.md          # Este archivo
```

## Solución de Problemas Comunes

1. Error de conexión a la base de datos:

   - Verifica que MySQL esté en ejecución
   - Comprueba las credenciales en db.js
   - Asegúrate de que la base de datos 'ventas' existe

2. Error al iniciar la aplicación:
   - Verifica que el puerto 3000 no esté en uso
   - Asegúrate de haber instalado todas las dependencias

## Dependencias Principales

- express: Framework web
- mysql2: Driver de MySQL
- ejs: Motor de plantillas
- body-parser: Middleware para procesar datos POST

## Licencia

ISC
