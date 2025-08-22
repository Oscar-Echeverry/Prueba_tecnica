# 📑 Gestor Documental – Portofino + MySQL

Aplicación web desarrollada con **Portofino 5.3.4** conectada a **MySQL 8** para la gestión documental.
Incluye CRUD de documentos, categorías y usuarios, con seguridad basada en roles.

---

## 🚀 Requisitos previos

* Java 11+
* Groovy
* MySQL 8+
* Maven o Gradle
* Git
* Portofino (última versión estable)
* Apache Tomcat 9

---

## ⚙️ Instalación y configuración

### 1. Clonar este repositorio

```bash
git clone https://github.com/Oscar-Echeverry/Prueba_tecnica.git
cd Prueba_tecnica
```

---

### 2. Crear la base de datos en MySQL

Ejecuta el script SQL incluido en este repositorio:

```bash
mysql -u root -p < database.sql
```
---

### 3. Copiar el proyecto en Tomcat/Portofino

Copia la carpeta `ROOT/` dentro de la carpeta `webapps/` de tu instalación de **Tomcat/Portofino**.

---

### 4. Levantar el servidor Tomcat

En Linux/Mac:

```bash
./bin/startup.sh
```

En Windows:

```powershell
.\bin\startup.bat
```

---

### 5. Acceder a la aplicación

Una vez iniciado el servidor, abre en tu navegador:

👉 [http://localhost:8080/](http://localhost:8080/)

---
## Sesión de preguntas teóricas – Groovy / Java con Portofino y MySQL

**1. ¿Qué es Portofino y en qué se diferencia de Spring Boot?**  
Portofino es un framework web que permite crear aplicaciones rápido, generando interfaces y funcionalidades automáticamente. A diferencia de Spring Boot, que requiere más configuración y código manual, Portofino automatiza muchas tareas comunes como CRUD y seguridad.

**2. CRUD declarativo en Portofino y su vínculo con MySQL**  
El CRUD declarativo permite crear, leer, actualizar y borrar datos sin escribir código. Portofino conecta cada entidad con su tabla MySQL correspondiente y genera automáticamente formularios y listas para manejar los datos.

**3. ¿Qué es un Groovy Template y cuándo se usa?**  
Es un archivo que mezcla Groovy con HTML para generar páginas dinámicas. Se usa en Portofino para personalizar la interfaz y mostrar datos de forma dinámica sin perder claridad entre diseño y lógica.

**4. Seguridad a nivel de página y campo**  
Portofino permite definir quién puede acceder a cada página y qué campos puede ver o editar cada usuario, dando control detallado sobre la información dentro de la aplicación.

**5. Flujo básico de conexión con MySQL**  
1. Configurar el datasource con los datos de MySQL.  
2. Portofino mapea las entidades a las tablas automáticamente.  
3. Las operaciones CRUD se ejecutan vía ORM interno.  
4. Los datos se muestran en la interfaz mediante formularios y listas generadas por el framework.
