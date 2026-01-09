# 🧪 Pipex Comprehensive Tester

Un tester exhaustivo para validar todas las funcionalidades del proyecto pipex (parte mandatory).

## 📋 Descripción

Este tester ejecuta **38 tests** que cubren todos los casos edge y escenarios posibles donde pipex puede fallar. Compara la salida de pipex con el comportamiento esperado de bash usando la sintaxis equivalente: `< infile cmd1 | cmd2 > outfile`

## 🚀 Uso

```bash
# Compilar pipex primero
make

# Ejecutar el tester
./pipex_tester.sh
```

## 🎯 Categorías de Tests

### 1. **Validación de Argumentos** (2 tests)
- ✅ Número incorrecto de argumentos (muy pocos)
- ✅ Número incorrecto de argumentos (demasiados)

### 2. **Funcionalidad Básica** (5 tests)
- ✅ `cat | wc -l` - Contar líneas
- ✅ `cat | grep pipex` - Filtrar con grep
- ✅ `cat | head -n 3` - Primeras líneas
- ✅ `cat | tail -n 2` - Últimas líneas
- ✅ `grep test | wc -l` - Combinar grep y wc

### 3. **Comandos con Opciones** (5 tests)
- ✅ `cat -e | head -n 3` - Opciones en primer comando
- ✅ `grep -i PIPEX | wc -l` - Búsqueda case-insensitive
- ✅ `head -n 5 | tail -n 2` - Encadenamiento de head/tail
- ✅ `cat | grep -v test` - Grep inverso
- ✅ `cat | sort -r` - Ordenamiento reverso

### 4. **Rutas Absolutas** (3 tests)
- ✅ `/bin/cat | wc -l` - Comando absoluto en cmd1
- ✅ `cat | /usr/bin/wc -l` - Comando absoluto en cmd2
- ✅ `/bin/cat | /usr/bin/grep pipex` - Ambos comandos absolutos

### 5. **Archivos Especiales** (3 tests)
- ✅ Archivo vacío
- ✅ Archivo de una sola línea
- ✅ Archivo con espacios múltiples

### 6. **Comandos Inexistentes** (2 tests)
- ✅ Primer comando no existe
- ✅ Segundo comando no existe

### 7. **Errores de Permisos** (3 tests)
- ✅ Archivo de entrada no existe
- ✅ Archivo de entrada sin permisos de lectura
- ✅ Directorio de salida sin permisos de escritura

### 8. **Comandos Complejos** (4 tests)
- ✅ `cat | grep -E 'test|pipex'` - Expresiones regulares
- ✅ `cat | awk '{print $1}'` - AWK processing
- ✅ `grep -i line | sort` - Grep + sort
- ✅ `cat | sed 's/test/TEST/g'` - Sustitución con sed

### 9. **Casos Edge** (4 tests)
- ✅ Grep sin coincidencias (output vacío)
- ✅ Comandos con múltiples espacios
- ✅ Archivo muy grande (10,000 líneas)
- ✅ Caracteres especiales en contenido ($, *, etc.)

### 10. **Escenarios del Mundo Real** (5 tests)
- ✅ Contar errores en logs
- ✅ Filtrar mensajes INFO
- ✅ Buscar por fecha
- ✅ Parsear archivo tipo /etc/passwd
- ✅ Extraer y ordenar nombres de usuario

### 11. **Manejo de Archivos de Salida** (2 tests)
- ✅ Sobrescribir archivo existente
- ✅ Crear archivo nuevo en directorio actual

## 📊 Output

El tester muestra:
- ✅ **Tests que pasan** en verde con la salida esperada
- ❌ **Tests que fallan** en rojo con comparación entre esperado y obtenido
- ⚠️ **Warnings** en amarillo para comportamientos aceptables pero no ideales
- 📈 **Estadísticas finales** con tasa de éxito

### Ejemplo de Output Exitoso:

```
╔═══════════════════════════════════════╗
║                                       ║
║     🎉 ALL TESTS PASSED! 🎉         ║
║                                       ║
╚═══════════════════════════════════════╝

Total tests:   38
Tests passed:  38
Tests failed:  0
Success rate:  100%
```

## 🔍 Qué Verifica el Tester

1. **Correctitud de Output**: Compara byte a byte con el comportamiento de bash
2. **Manejo de Errores**: Verifica que errores sean manejados gracefully
3. **File Descriptors**: Asegura que pipes y redirecciones funcionen correctamente
4. **Memory Leaks**: (Ejecuta valgrind si lo tienes instalado manualmente)
5. **Edge Cases**: Casos límite que estudiantes suelen olvidar

## 🐛 Tests Críticos

Los siguientes tests son especialmente importantes para el evaluador de 42:

- **Argumentos inválidos**: Debe retornar error y no crashear
- **Permisos de archivos**: Debe manejar errores de permisos correctamente
- **Comandos absolutos**: `/bin/cat` debe funcionar igual que `cat`
- **Comandos con espacios**: `head    -n   3` debe parsearse correctamente
- **Archivos vacíos**: No debe crashear con archivos vacíos

## 📝 Notas Importantes

1. El tester crea archivos temporales en `/tmp/pipex_test_$$`
2. Limpia automáticamente después de ejecutarse (trap EXIT)
3. No requiere instalación de dependencias adicionales
4. Compatible con bash 4.0+
5. Funciona en Linux (Ubuntu, Debian, etc.)

## 🔧 Troubleshooting

### Si algunos tests fallan:

1. **"command not found"**: Verifica que los comandos estén en PATH
   ```bash
   which cat grep wc head tail awk sed
   ```

2. **"Permission denied"**: El script necesita permisos de escritura en /tmp
   ```bash
   ls -ld /tmp
   ```

3. **Diferencias en output**: Algunos comandos tienen comportamientos diferentes según la versión
   - Revisa la versión de tus comandos: `cat --version`

4. **Valgrind (opcional)**: Para verificar memory leaks
   ```bash
   valgrind --leak-check=full ./pipex infile "cat" "wc -l" outfile
   ```

## 📚 Casos de Test Adicionales (Manual)

Algunos casos que debes probar manualmente:

```bash
# Test con comillas en argumentos (si implementas bonus)
./pipex infile "grep 'test file'" "wc -l" outfile

# Test con PATH vacío
env -i ./pipex infile "cat" "wc" outfile

# Test con CTRL+C (debe manejar señales correctamente)
# Ejecuta y presiona CTRL+C
./pipex infile "sleep 10" "cat" outfile
```

## 🎓 Recursos

- [Subject del proyecto](https://projects.intra.42.fr/projects/pipex)
- [Man pages relevantes](https://www.man7.org/): pipe(2), fork(2), execve(2), dup2(2), access(2)
- [Tutorial de pipes](https://www.youtube.com/watch?v=6u_iPGVkfZ4)

## ✅ Checklist Pre-Evaluación

Antes de tu evaluación, asegúrate de:

- [ ] Todos los 38 tests pasan
- [ ] No hay memory leaks (valgrind clean)
- [ ] Norminette pasa sin errores
- [ ] Makefile tiene las reglas requeridas (all, clean, fclean, re)
- [ ] No hay archivos innecesarios commiteados (.o, ejecutables)
- [ ] README explica el proyecto (opcional pero recomendado)

## 🙏 Créditos

Tester creado para ayudar a estudiantes de 42 a validar su implementación de pipex.

## 📄 Licencia

Este tester es de uso libre para estudiantes de 42. ¡Buena suerte con tu evaluación! 🚀
