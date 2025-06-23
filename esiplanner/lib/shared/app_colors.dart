import 'package:flutter/material.dart';

class AppColors {
  
  //MODO CLARO//
  // Color principal (azul)
  static const Color azulUCA = Color(0xFF005877);
  static const Color azul = Color(0xFF0D47A1); // Azul shade900
  static const Color azulIntermedioUCA = Color(0xFF3A7CA0);

  // Color secuandirio 1 (azul claro)
  static const Color azulClaroUCA1 = Color(0xFFBBDEFB); // shade100 aproximado
  static Color azulClaro1 = Colors.indigo.shade100;// Colors.blue.shade100

  // Color secuandirio 2 (azul claro)
  static const Color azulClaroUCA2 = Color(0xFFE3F2FD); // Colors.blue.shade50
  static Color azulClaro2 = Colors.indigo.shade50; // shade50 aproximado

  // Color secundario 3 (azul claro)
  static const Color azulClaro3 = Color(0xFF76A8C9);

  //MODO OSCURO//
  // Color primario (negro - gris)
  static const Color gris1 = Color(0xFF212121);   // Colors.grey.shade900
  static const Color gris2 = Color(0xFF424242);   // Crolos.grey.shade800
  static const Color gris1_2 = Color(0xFF303030); // Colors.grey.shade850

  // Color secundario (naranja)
  static const Color amarilloUCA = Color(0xFFE87B00);
  static const Color amarillo = Color(0xFFFBC02D); // Colors.yellow.shade700
  static const Color amarilloOscuro = Color(0xFFF9A825); // Colors.yellow.shade800
  static const Color amarilloClaro = Color(0xFFFDD835); // Colors.yellow.shade600

  
  //SIN MOODO//
  static const Color negro = Color(0xFF000000); // Colors.black
  static const Color blanco = Color(0xFFFFFFFF); // Colors.blanco


  //Colores dervados
  static const Color negro54 = Color(0x8A000000); // Colors.black54
  static const Color negro87 = Color(0xDD000000); // AppColors.negro87
  static const Color blanco70 = Color(0xB3FFFFFF); // blanco con 70% de opacidad
  static const Color blanco54 = Color(0x8AFFFFFF); // blanco con 54% de opacidad
}